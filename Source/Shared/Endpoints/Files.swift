//
//  Files.swift
//  Wunderlist
//
//  Created by Constantine Fry on 05/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/**
    Represents Files endpoint on Wunderilst.
    https://developer.wunderlist.com/documentation/endpoints/file
*/
public class Files: Endpoint {
    override var endpoint: String {
        return "files"
    }
    
    public func getFilesForList(listId: Int,
        completionHandler: (files: [File]?, error: NSError?) -> Void) -> SessionTask {
            
        var parameters = [
        "list_id" : listId,
        ] as [String: AnyObject]
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "GET", transformClosure: { File(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(files: result as [File]?, error: error)
        }
    }
    
    public func getFilesForTask(taskId: Int,
        completionHandler: (files: [File]?, error: NSError?) -> Void) -> SessionTask {
            
        var parameters = [
            "task_id" : taskId,
            ] as [String: AnyObject]
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "GET", transformClosure: { File(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(files: result as [File]?, error: error)
        }
    }
    
    public func getFile(fileId: Int,
        completionHandler: (file: File?, error: NSError?) -> Void) -> SessionTask {
            let path = String(fileId)
            return taskWithPath(path, parameters: nil, HTTPMethod: "GET", transformClosure: { File(JSON: $0) }) {
                (result, error) -> Void in
                completionHandler(file: result as File?, error: error)
            }
    }
    
    public func createFile(uploadId: Int, taskId: Int, creationDate:NSDate?,
        completionHandler: (file: File?, error: NSError?) -> Void)  -> SessionTask {
            
        var parameters = [
            "upload_id" : uploadId,
            "task_id"   : taskId
        ] as [String: AnyObject]
        if creationDate != nil {
            parameters["local_created_at"] = creationDate
        }
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "POST", transformClosure: { File(JSON: $0) }) {
            (result, error) -> Void in
            completionHandler(file: result as File?, error: error)
        }
    }
    
    public func deleteFile(fileId: Int, revision: Int,
        completionHandler: (result: Bool, error: NSError?) -> Void) -> SessionTask {
            
        var parameters = [
            "revision"  : String(revision),
            ] as [String: AnyObject]
        let path = String(fileId)
        return taskWithPath(path, parameters: parameters, HTTPMethod: "DELETE", transformClosure: nil) {
            (result, error) -> Void in
            completionHandler(result: error == nil, error: error)
        }
    }
    
}
