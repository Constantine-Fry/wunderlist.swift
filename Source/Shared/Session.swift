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
let SessionHTTPErrorDomain = "WunderlistHTTPErrorDomain"

let SessionErrorDomain = "WunderlistSessionErrorDomain"

enum SessionErrorCode: Int {
    case BackgroundTaskExpired
}

/** Posted on the `delegateQueue` right before calling completion handler,
    when session did become unauthorized due to HTTP status code 401 in reponse. */
let WunderlistSessionDidBecomeUnauthorizedNotification = "WunderlistSessionDidBecomeUnauthorizedNotification"

typealias WunderlistSessionAuthorizationClosure = (result: Bool, error: NSError?) -> Void

/** Shared instance of sesson. */
private var _wunderlistSharedSession: Session!

/** The wundurlist session. */
@objc class Session {
    
    /** The configuration for session. */
    let configuration           : Configuration
    
    /** Authorizer for session. If not nil then we are in authorization process. */
    private var authorizer      : Authorizer?
    
    /** The queue on which all completion handlers must be called. */
    let delegateQueue           : NSOperationQueue
    
    /** The URL session for API requests. */
    let URLSession              : NSURLSession
    
    /** Initializes session with given configuration and delegate queue. */
    init(configuration: Configuration, delegateQueue: NSOperationQueue =  NSOperationQueue.mainQueue()) {
        self.configuration = configuration
        let URLConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        URLSession = NSURLSession(configuration: URLConfiguration)
        self.delegateQueue = delegateQueue
    }
    
    class func setupSharedSession(configuration: Configuration) {
        if _wunderlistSharedSession == nil {
            _wunderlistSharedSession = Session(configuration: configuration)
        }
    }
    
    /** Returns shared session. You have to setup session befor using it. See `setupSharedSession` method. */
    class func sharedSession() -> Session {
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
    func authorize(onViewController: UIViewController, completionHandler: WunderlistSessionAuthorizationClosure) {
        if authorizer != nil {
            completionHandler(result: false, error: nil)
            return
        }
        authorizer = Authorizer(configuration: configuration)
        authorizer?.authorize(onViewController){
            (accessToken, error) -> Void in
            if accessToken != nil {
                // Store access token.
                let account = self.accountForKeychain()
                //Keychain.setPassword(accessToken!, forAccount: account)
            }
            NSOperationQueue.mainQueue().addOperationWithBlock {
                completionHandler(result: accessToken != nil, error: error)
            }
            self.authorizer = nil
        }
    }
    
    /** Deauthorizes the session. */
    func deauthorize() {
        let account = accountForKeychain()
        //Keychain.removePasswordForAccount(account)
    }
    
    /** Whether session is authorized or non. */
    func isAuthorized() -> Bool {
        return accessToken() != nil
    }
    
    /** Access token used by session. */
    func accessToken() -> String? {
        let account = accountForKeychain()
        return ""// Keychain.passwordForAccount(account)
    }
    
    /** The account name for keychain password. */
    private func accountForKeychain() -> String {
        let account = "io.fry.wunderlist." + configuration.client.clientId
        return account
    }
  
    
    
    lazy var files      : Files         = { return Files(session: self)     }()
    
    lazy var reminders  : Reminders     = { return Reminders(session: self) }()
    
    lazy var tasks      : Tasks         = { return Tasks(session: self)     }()
    
    lazy var uploads    : Uploads       = { return Uploads(session: self)   }()
    
    lazy var lists      : Lists         = { return Lists(session: self)     }()
    
    
}
