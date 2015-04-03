//
//  Endpoint.swift
//  Wunderlist
//
//  Created by Constantine Fry on 05/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

typealias JSONTransformClosure = ([String: AnyObject]) -> AnyObject
typealias CompletionClosure = (JSON: AnyObject?, error: NSError?) -> Void

/** Base class for all endpoints. */
public class Endpoint {
    
    /** Configuration of session. */
    weak var session: Session?
    
    /** Endpoint name. Subclasses must override this getter and provide specific name. */
    var endpoint: String {
        return ""
    }
    
    init(session: Session) {
        self.session = session
    }
    
    /** Creates and returns task. */
    func taskWithPath(path: String?, parameters: [String: AnyObject]?, HTTPMethod: String, transformClosure: JSONTransformClosure?, completionHandler: CompletionClosure) -> SessionTask {
        var URL = session!.configuration.server.baseURL.URLByAppendingPathComponent(endpoint)
        if path != nil {
            URL = URL.URLByAppendingPathComponent(path!)
        }
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod
        request.setValue(session!.accessToken(), forHTTPHeaderField: "X-Access-Token")
        request.setValue(session!.configuration.client.clientId, forHTTPHeaderField: "X-Client-ID")
        
        if parameters != nil {
            if HTTPMethod == "POST" || HTTPMethod == "PATCH" || HTTPMethod == "DELETE" {
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters!, options: .PrettyPrinted, error: nil)
            } else {
                fatalError("Is it possible?")
            }
        }
        
        return SessionTask(
            session: self.session,
            request: request,
            transformClosure: transformClosure,
            completionHandler: completionHandler)
    }
    
}

