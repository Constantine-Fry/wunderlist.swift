//
//  Tasks.swift
//  Wunderlist
//
//  Created by Constantine Fry on 05/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/**
    Represents Tasks endpoint on Wunderilst.
    https://developer.wunderlist.com/documentation/endpoints/task
*/
public class Tasks: Endpoint {
    override var endpoint: String {
        return "tasks"
    }
    
    public func createTask(listId: Int, title: String, dueDate: NSDate?, completionHandler: (task: Task?, error: NSError?) -> Void) -> SessionTask {
        var parameters = [
            "list_id"   : listId,
            "title"     : title
            ] as [String: AnyObject]
        if dueDate != nil {
            parameters["due_date"] = DateFormatter.sharedInstance().stringFromDate(dueDate!)
        }
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "POST", transformClosure: { Task(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(task: result as Task?, error: error)
        }
    }
    
    public func updateTask(taskId: Int, revision: Int, title: String?, dueDate: NSDate?, completionHandler: (task: Task?, error: NSError?) -> Void) -> SessionTask {
        var parameters = [String: AnyObject]()
        parameters["revision"] = revision
        if title != nil {
            parameters["title"] = title
        }
        if dueDate != nil {
            parameters["due_date"] = DateFormatter.sharedInstance().stringFromDate(dueDate!)
        }
        let path = String(taskId)
        return taskWithPath(path, parameters: parameters, HTTPMethod: "PATCH", transformClosure: { Task(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(task: result as Task?, error: error)
        }
    }
    
    public func getTaskWithId(taskId: Int, completionHandler: (task: Task?, error: NSError?) -> Void) -> SessionTask {
        let path = String(taskId)
        return taskWithPath(path, parameters: nil, HTTPMethod: "GET", transformClosure: { Task(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(task: result as Task?, error: error)
        }
    }
    
}
