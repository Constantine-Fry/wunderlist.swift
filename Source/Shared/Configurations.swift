//
//  Configurations.swift
//  Wunderlist
//
//  Created by Constantine Fry on 05/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/** The client information for oauth process. */
public struct Client {
    /** The client ID for oauth process. */
    let clientId        : String
    
    /** The client sercet for oauth process. */
    let clientSecret    : String
    
    /** The redirect URL for oauth process. */
    let redirectURL     : NSURL
    
    public init(clientId: String, clientSecret: String, redirectURL: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURL = NSURL(string: redirectURL)!
    }
}

/** The server information. */
struct Server {
    
    /** The URL to oauth login page. */
    let baseAuthorizationURL = NSURL(string: "https://www.wunderlist.com/oauth/authorize")!
    
    /** The URL to exchange access code to access token. */
    let baseAccessTokenURL = NSURL(string: "https://www.wunderlist.com/oauth/access_token")!
    
    /** The URL for all API requests. */
    let baseURL = NSURL(string: "https://a.wunderlist.com/api/v1")!
}

/** Session configuratuon. */
public struct Configuration {
    let client: Client
    let server: Server
    
    public init(client: Client) {
        self.client = client
        self.server = Server()
    }
}
