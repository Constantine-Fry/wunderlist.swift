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
public class Lists: Endpoint {
    override var endpoint: String {
        return "lists"
    }
    
    public func getLists(completionHandler: (lists: [List]?, error: NSError?) -> Void) -> SessionTask {
        return taskWithPath(nil, parameters: nil, HTTPMethod: "GET", transformClosure: { List(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(lists: result as [List]?, error: error)
        }
    }
    
    public func getList(listId: Int, completionHandler: (list: List?, error: NSError?) -> Void) -> SessionTask {
        let path = String(listId)
        return taskWithPath(path, parameters: nil, HTTPMethod: "GET", transformClosure: { List(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(list: result as List?, error: error)
        }
    }
    
    public func getListTasksCount(listId: Int,
        completionHandler: (count: TasksCount?, error: NSError?) -> Void) -> SessionTask {
            let path = "tasks_count"
            let parameters = ["list_id" : listId]
            return taskWithPath(path, parameters: parameters, HTTPMethod: "GET",
                transformClosure: { TasksCount(JSON: $0) }) {
                    (result, error) -> Void in
                    completionHandler(count: result as TasksCount?, error: error)
            }
    }
    
    public func createList(title: String, completionHandler: (list: List?, error: NSError?) -> Void) -> SessionTask {
        let parameters = ["title" : title]
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "POST", transformClosure: { List(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(list: result as List?, error: error)
        }
    }
    
    public func updateList(listId: Int, title: String, revision: Int,
        completionHandler: (list: List?, error: NSError?) -> Void) -> SessionTask {
            let path = String(listId)
            let parameters = [
                "revision"  : revision,
                "title"     : title
                ] as [String: AnyObject]
            return taskWithPath(path, parameters: parameters, HTTPMethod: "PATCH",
                transformClosure: { List(JSON: $0) }) {
                    (result, error) -> Void in
                    completionHandler(list: result as List?, error: error)
            }
    }
    
    public func updateList(listId: Int, isPublic: Bool, revision: Int,
        completionHandler: (list: List?, error: NSError?) -> Void) -> SessionTask {
            let path = String(listId)
            let parameters = [
                "revision"  : revision,
                "public"    : isPublic
                ] as [String: AnyObject]
            return taskWithPath(path, parameters: parameters, HTTPMethod: "PATCH",
                transformClosure: { List(JSON: $0) }) {
                    (result, error) -> Void in
                    completionHandler(list: result as List?, error: error)
            }
    }
    
    public func deleteList(listId: Int, revision: Int,
        completionHandler: (result: Bool, error: NSError?) -> Void) -> SessionTask {
            let path = String(listId)
            let parameters = [
                "revision"  : revision,
                ] as [String: AnyObject]
            return taskWithPath(path, parameters: parameters, HTTPMethod: "PATCH",
                transformClosure: { List(JSON: $0) }) {
                    (result, error) -> Void in
                    completionHandler(result: error == nil, error: error)
            }
    }
}

