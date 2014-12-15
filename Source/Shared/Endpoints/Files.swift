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
@objc class Files: Endpoint {
    override var endpoint: String {
        return "files"
    }
    
    
    func createFile(uploadId: Int, taskId: Int, creationDate:NSDate?, completionHandler: (file: File?, error: NSError?) -> Void)  -> SessionTask {
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
    
    func deleteFile(fileId: Int, revision: Int,  completionHandler: (result: Bool, error: NSError?) -> Void) -> SessionTask {
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
