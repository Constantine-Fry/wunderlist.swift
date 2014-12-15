//
//  Lists.swift
//  Wunderlist
//
//  Created by Constantine Fry on 05/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/**
    Represents Lists endpoint on Wunderilst.
    https://developer.wunderlist.com/documentation/endpoints/list
*/
@objc class Lists: Endpoint {
    override var endpoint: String {
        return "lists"
    }
    
    func get(completionHandler: (lists: [List]?, error: NSError?) -> Void) -> SessionTask {
        return taskWithPath(nil, parameters: nil, HTTPMethod: "GET", transformClosure: { List(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(lists: result as [List]?, error: error)
        }
    }
    
    func create(title: String, completionHandler: (list: List?, error: NSError?) -> Void) -> SessionTask {
        let parameters = ["title" : title]
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "POST", transformClosure: { List(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(list: result as List?, error: error)
        }
    }

}

