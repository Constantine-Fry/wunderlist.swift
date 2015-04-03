//
//  Authorizer.swift
//  Wunderlist
//
//  Created by Constantine Fry on 04/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation
import UIKit

typealias AuthorizerClosure = (accessToken: String?, error: NSError?) -> Void


/** Responsiable for autherization process. Presentes login page and exchange access code to access token. */
class Authorizer: AuthorizationViewControllerDelegate {
    
    /** The view controller which is used for authorization. */
    var viewController: AuthorizationViewController?
    
    /** The configuration. */
    let configuration: Configuration
    
    /** The `state` parameter for authorization URL. */
    let authorizationState = NSUUID().UUIDString
    
    var completionHandler: AuthorizerClosure!
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    /** Starts authorization process by presenting view controller with login web page. */
    func authorize(onViewController: UIViewController, completionHandler: AuthorizerClosure) {
        cleanupCookiesForURL(configuration.server.baseAuthorizationURL)
        self.completionHandler = completionHandler
        let redirectURL = configuration.client.redirectURL
        let baseAuthorizationURL = configuration.server.baseAuthorizationURL
        let components = NSURLComponents(URL: baseAuthorizationURL, resolvingAgainstBaseURL: false)!
        let redictURLString = redirectURL.absoluteString
        components.queryItems  = [
            NSURLQueryItem(name: "client_id",       value: configuration.client.clientId),
            NSURLQueryItem(name: "redirect_uri",    value: redictURLString!),
            NSURLQueryItem(name: "state",           value: authorizationState)
        ]
        let authorizationURL = components.URL!
        viewController = AuthorizationViewController(authorizationURL: authorizationURL, redirectURL: redirectURL, delegate: self)
        let navigationController = UINavigationController(rootViewController: viewController!)
        onViewController.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    /** Continues authorization process. Exchanges access code to access token. */
    func authorizationController(controller: AuthorizationViewController, didReachRedirectURL redirectURL: NSURL) {
        println(redirectURL)
        let redirectComponents = NSURLComponents(URL: redirectURL, resolvingAgainstBaseURL: false)!
        var code: String?
        var state: String?
        
        for item in (redirectComponents.queryItems as [NSURLQueryItem]) {
            switch item.name {
                case "code":
                    code = item.value
                case "state":
                    state = item.value
            default:
                fatalError("Unknown parameter \(item.name)=\(item.value)")
            }
        }
        if state == authorizationState && code != nil {
            let components = NSURLComponents(URL: configuration.server.baseAccessTokenURL, resolvingAgainstBaseURL: false)!
            let parameters = [
                "client_id":        configuration.client.clientId,
                "client_secret":    configuration.client.clientSecret,
                "code":             code!
            ]
            let request = NSMutableURLRequest(URL: components.URL!)
            request.HTTPMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: .PrettyPrinted, error: nil)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {
                (response, data, error) -> Void in
                var resultError: NSError? = error
                var accessToken: String?
                let HTTPResponse = response as NSHTTPURLResponse?
                if data != nil && HTTPResponse?.MIMEType == "application/json" {
                    let JSONObject = NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments, error: &resultError) as [String:String]?
                    if let token = extractString(JSONObject, ["access_token"]) {
                        accessToken = token
                    } else {
                        var userInfo = [String: AnyObject]()
                        if JSONObject != nil {
                            userInfo["JSON"] = JSONObject
                        }
                        if HTTPResponse != nil {
                            resultError = NSError(domain: SessionHTTPErrorDomain, code: HTTPResponse!.statusCode, userInfo: userInfo)
                        }
                    }
                }
                controller.dismissViewControllerAnimated(true) {
                    () -> Void in
                    self.completionHandler(accessToken: accessToken, error: resultError)
                }
            }
        } else {
            completionHandler(accessToken:nil, error:nil)
        }
    }
    
    /** Called when user press cancel button. */
    func authorizationControllerUserDidCancel(controller: AuthorizationViewController) {
        controller.dismissViewControllerAnimated(true) {
            () -> Void in
            let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
            self.completionHandler(accessToken: nil, error: cancelError)
        }
    }
    
    /** 
        Removes cookies for specified URL. UIWebView stores user login in cookies,
        before new login we have to clean cookies storage.
    */
    private func cleanupCookiesForURL(URL: NSURL) {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if storage.cookies != nil {
            let cookies = storage.cookies as [NSHTTPCookie]
            for cookie in cookies {
                if cookie.domain == URL.host {
                    storage.deleteCookie(cookie as NSHTTPCookie)
                }
            }
        }
    }
    
}

func extractFrom(JSON: [String: AnyObject]?, keyPath: [String]) -> AnyObject? {
    var currentDictionary: [String: AnyObject]? = JSON
    for key in keyPath {
        if currentDictionary == nil {
            break
        }
        let value: AnyObject? = currentDictionary![key]
        if keyPath.last == key {
            // We reach the end. Return result.
            return value
        } else {
            currentDictionary = value as [String: AnyObject]?
        }
    }
    return nil
}

func extractDictionary(JSON: [String: AnyObject]?, keyPath: [String]) -> [String:AnyObject]? {
    return extractFrom(JSON, keyPath) as  [String:AnyObject]?
}

func extractString(JSON: [String: AnyObject]?, keyPath: [String]) -> String? {
    return extractFrom(JSON, keyPath) as String?
}

func extractInt(JSON: [String: AnyObject]?, keyPath: [String]) -> Int? {
    return extractFrom(JSON, keyPath) as Int?
}

