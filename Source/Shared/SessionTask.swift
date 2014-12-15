//
//  SessionTask.swift
//  Wunderlist
//
//  Created by Constantine Fry on 09/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/** Task to perform network request. */
@objc class SessionTask {
    
    /** The request which task will execute. */
    internal let request: NSURLRequest
    
    /** The session. */
    private weak var session: Session?
    
    /** Closure to transform JSON dictionary into Wunderlist object.*/
    private let transformClosure: JSONTransformClosure?
    
    /** The completion handler to call. */
    private var completionHandler: CompletionClosure?
    
    /** The URL session task, which we are executing now. */
    private var task: NSURLSessionTask?
    
    /** Initializes task. */
    init(session: Session?, request: NSURLRequest, transformClosure: JSONTransformClosure?, completionHandler: CompletionClosure) {
        self.session = session
        self.request = request
        self.completionHandler = completionHandler
        self.transformClosure = transformClosure
    }
    
    /** 
        Starts the task.
        One can repeat the task as many times as he wants.
    */
    func start() {
        if self.task == nil {
            let backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler{
                () -> Void in
                self.session?.delegateQueue.addOperationWithBlock {
                    () -> Void in
                    let error = NSError(
                        domain: SessionErrorDomain,
                        code:   SessionErrorCode.BackgroundTaskExpired.rawValue,
                        userInfo: nil)
                    self.completionHandler?(JSON: nil, error: error)
                }
                return Void()
            }
            
            self.task = session?.URLSession.dataTaskWithRequest(request) {
                (data, response, error) -> Void in
                let HTTPResponse = response as NSHTTPURLResponse?
                var resultError: NSError? = error
                var result: AnyObject?
                
                if HTTPResponse != nil && data != nil {
                    var JSON: AnyObject?
                    if HTTPResponse?.MIMEType == "application/json" {
                       JSON = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &resultError)
                    }
                    if HTTPResponse!.statusCode >= 200 && HTTPResponse!.statusCode <= 399 && JSON != nil {
                        if self.transformClosure != nil {
                            if let JSONObject = JSON as? [[String: AnyObject]] {
                                result = JSONObject.map { self.transformClosure!($0) }
                            } else if let JSONObject = JSON as? [String: AnyObject] {
                                if JSONObject.count > 0 {
                                    result = self.transformClosure!(JSONObject)
                                }
                            }
                        } else {
                            result = JSON
                        }
                    } else if resultError == nil {
                        var userInfo: [String: AnyObject]?
                        if JSON != nil {
                            userInfo = ["JSON": JSON!]
                        }
                        resultError = NSError(domain: SessionHTTPErrorDomain, code: HTTPResponse!.statusCode, userInfo: userInfo)
                    }
                }
                
                self.session?.delegateQueue.addOperationWithBlock {
                    if let session = self.session {
                        if resultError?.domain == SessionHTTPErrorDomain && resultError?.code == 401 {
                            if session.isAuthorized() {
                                session.deauthorize()
                                let center = NSNotificationCenter.defaultCenter()
                                center.postNotificationName(WunderlistSessionDidBecomeUnauthorizedNotification, object: session)
                            }
                        }
                    }
                    self.completionHandler?(JSON: result, error: resultError)
                    UIApplication.sharedApplication().endBackgroundTask(backgroundTask)
                }
                self.task = nil
            }
            task?.resume()
        }
    }
    
    /**
        Marks the task as cancelled.
        Error value of { NSURLErrorDomain, NSURLErrorCancelled } will be passed in completion handler.
    */
    func cancel() {
        self.task?.cancel()
    }
    
}

/** The task to upload a file. */
@objc class SessionUploadTask {
    /** The session. */
    weak var session: Session?
    
    /** The upload request. */
    let request: NSURLRequest
    
    /** The URL session task. */
    var task: NSURLSessionTask?
    
    /** The URL to file which will be uploaded. */
    let fileURL: NSURL
    
    /** The completion handler to call. */
    let completionHandler: ((fineshed: Bool, error: NSError?) -> Void)?
    
    /** Initializet session. */
    init(session: Session?, fileURL: NSURL, request: NSURLRequest, completionHandler: ((fineshed: Bool, error: NSError?) -> Void)?) {
        self.session = session
        self.fileURL = fileURL
        self.completionHandler = completionHandler
        self.request = request
    }
    
    /** Starts uploading. */
    func start() {
        if self.task == nil {
            self.task = session?.URLSession.uploadTaskWithRequest(request, fromFile: fileURL) {
                (data, response, error) -> Void in
                let HTTPResponse = response as NSHTTPURLResponse?
                var resultError: NSError? = error
                if HTTPResponse != nil {
                    if HTTPResponse!.statusCode < 200 && HTTPResponse!.statusCode > 399 && resultError == nil {
                        resultError = NSError(domain: SessionHTTPErrorDomain, code: HTTPResponse!.statusCode, userInfo: nil)
                    }
                }
                self.session?.delegateQueue.addOperationWithBlock {
                    self.completionHandler?(fineshed: error == nil, error: error)
                    return Void()
                }
            }
            task?.resume()
        }
    }
    
    /** 
        Marks the task as cancelled.
        Error value of { NSURLErrorDomain, NSURLErrorCancelled } will be passed in completion handler.
    */
    func cancel() {
        self.task?.cancel()
    }
    
}
