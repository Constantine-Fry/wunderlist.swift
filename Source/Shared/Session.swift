//
//  Session.swift
//  Wunderlist
//
//  Created by Constantine Fry on 04/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/**
    Error domain for errors HTTP errors.
    Not localized. Error code is HTTP status code.
*/
public let SessionHTTPErrorDomain = "WunderlistHTTPErrorDomain"

public let SessionErrorDomain = "WunderlistSessionErrorDomain"

public enum SessionErrorCode: Int {
    case BackgroundTaskExpired
}

/** Posted on the `delegateQueue` right before calling completion handler,
    when session did become unauthorized due to HTTP status code 401 in reponse. */
public let WunderlistSessionDidBecomeUnauthorizedNotification = "WunderlistSessionDidBecomeUnauthorizedNotification"

public typealias WunderlistSessionAuthorizationClosure = (result: Bool, error: NSError?) -> Void

/** Shared instance of sesson. */
private var _wunderlistSharedSession: Session!

/** The wundurlist session. */
public class Session {
    
    /** The configuration for session. */
    public let configuration    : Configuration
    
    /** Authorizer for session. If not nil then we are in authorization process. */
    private var authorizer      : Authorizer?
    
    /** The queue on which all completion handlers must be called. */
    let delegateQueue   : NSOperationQueue
    
    /** The URL session for API requests. */
    let URLSession              : NSURLSession
    
    private let keychain        : Keychain
    
    /** Initializes session with given configuration and delegate queue. */
    public init(configuration: Configuration, delegateQueue: NSOperationQueue =  NSOperationQueue.mainQueue()) {
        self.configuration = configuration
        let URLConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        URLSession = NSURLSession(configuration: URLConfiguration)
        self.delegateQueue = delegateQueue
        self.keychain = Keychain(configuration: configuration)
    }
    
    public class func setupSharedSession(configuration: Configuration) {
        if _wunderlistSharedSession == nil {
            _wunderlistSharedSession = Session(configuration: configuration)
        }
    }
    
    /** Returns shared session. You have to setup session befor using it. See `setupSharedSession` method. */
    public class func sharedSession() -> Session {
        if _wunderlistSharedSession != nil {
            return _wunderlistSharedSession
        }
        fatalError("One must setup session before using it.");
    }
    
    /** 
        Modally presents view controller on with web page to login.
        Can return following errors:
        {`NSCocoaErrorDomain` `NSUserCancelledError`} in case if user tapped cancel button. Shouldn't be shown in UI.
        `NSURLErrorDomain` in case of networking problems.
        
        Completion handler is always called on the main thread.
    */
    public func authorize(onViewController: UIViewController, completionHandler: WunderlistSessionAuthorizationClosure) {
        if authorizer != nil {
            completionHandler(result: false, error: nil)
            return
        }
        authorizer = Authorizer(configuration: configuration)
        authorizer?.authorize(onViewController){
            (accessToken, error) -> Void in
            if accessToken != nil {
                // Store access token.
                self.keychain.saveAccessToken(accessToken!)
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completionHandler(result: accessToken != nil, error: error)
            }
            self.authorizer = nil
        }
    }
    
    /** Deauthorizes the session. */
    public func deauthorize() {
        keychain.deleteAccessToken()
    }
    
    /** Whether session is authorized or non. */
    public func isAuthorized() -> Bool {
        return accessToken() != nil
    }
    
    /** Access token used by session. */
    public func accessToken() -> String? {
        let (accessToken, _) = keychain.accessToken()
        return accessToken
    }
    
  
    
    
    public lazy var files      : Files         = { return Files(session: self)     }()
    
    public lazy var reminders  : Reminders     = { return Reminders(session: self) }()
    
    public lazy var tasks      : Tasks         = { return Tasks(session: self)     }()
    
    public lazy var uploads    : Uploads       = { return Uploads(session: self)   }()
    
    public lazy var lists      : Lists         = { return Lists(session: self)     }()
    
    
}
