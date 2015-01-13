//
//  Objects.swift
//  Wunderlist
//
//  Created by Constantine Fry on 08/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/** Base class for Wunderlist API objects. */
public class Object: Printable {
    public let identifier: Int
    
    init(identifier: Int) {
      self.identifier = identifier
    }
    
    init(JSON: [String: AnyObject]) {
        self.identifier = extractInt(JSON, ["id"])!
    }
    
    public var description: String { get {
        return "Object( \(identifier)))"
        }
    }
}

public class File: Object {
    public let filename: String?
    
    init(identifier: Int, filename: String) {
        self.filename = filename
        super.init(identifier: identifier)
    }
    
    override init(JSON: [String: AnyObject]) {
        self.filename = extractString(JSON, ["file_name"])
        super.init(JSON: JSON)
    }
}

public class List: Object {
    public let title: String?
    
    init(identifier: Int, title: String) {
        self.title = title
        super.init(identifier: identifier)
    }
    
    override init(JSON: [String: AnyObject]) {
        self.title = extractString(JSON, ["title"])
        super.init(JSON: JSON)
    }
}

public class Reminder: Object {
    public let date        : NSDate?
    public let taskId      : Int?
    
    init(identifier: Int, taskId: Int, date: NSDate) {
        self.date = date
        self.taskId = taskId
        super.init(identifier: identifier)
    }
    
    override init(JSON: [String: AnyObject]) {
        if let dateString = extractString(JSON, ["date"]) {
            self.date = DateFormatter.sharedInstance().dateFromString(dateString)
        }
        self.taskId = extractInt(JSON, ["task_id"])
        super.init(JSON: JSON)
    }
}

public  class Task: Object  {
    public let title: String?
    public let revision : Int?
    public let dueDate : NSDate?
    
    init(identifier: Int, title: String) {
        self.title = title
        super.init(identifier: identifier)
    }
    
    override init(JSON: [String: AnyObject]) {
        self.title = extractString(JSON, ["title"])
        self.revision = extractInt(JSON, ["revision"])
        if let dueDateString = extractString(JSON, ["due_date"]) {
            self.dueDate = DateFormatter.sharedInstance().dateFromString(dueDateString)
        }
        
        super.init(JSON: JSON)
    }
}

public  class UploadInfo: Object  {
    
    /** The URL where we should upload file. */
    public let uploadURL: NSURL?

    /** Receied from amazon. Should be added to HTTP header as `x-amz-date`. */
    public let date: String?
    
    /** Receied from amazon. Should be added to HTTP header as `Authorization`. */
    let authorization: String?
    
    /** Should be added to HTTP header as `Content-Type`. */
    let contentType = ""
    
    override init(JSON: [String: AnyObject]) {
        self.uploadURL = NSURL(string: extractString(JSON, ["part", "url"])!)
        self.date = extractString(JSON, ["part", "date"])
        self.authorization = extractString(JSON, ["part", "authorization"])
        super.init(JSON: JSON)
    }
}
