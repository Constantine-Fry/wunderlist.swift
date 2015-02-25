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

public class RevisionedObject: Object {
    public let revision: Int?
    
    override init(JSON: [String: AnyObject]) {
        self.revision = extractInt(JSON, ["revision"])!
        super.init(JSON: JSON)
    }
    
}

public class File: RevisionedObject {
    public let filename: String?
    
    override init(JSON: [String: AnyObject]) {
        self.filename = extractString(JSON, ["file_name"])
        super.init(JSON: JSON)
    }
}

public class List: RevisionedObject {
    public let title: String?
    
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

public  class Task: RevisionedObject  {
    public let title: String?
    public let dueDate : NSDate?
    
    override init(JSON: [String: AnyObject]) {
        self.title = extractString(JSON, ["title"])
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

public class TasksCount: Object {
    public let completedCount: Int
    public let uncompletedCount: Int
    
    override init(JSON: [String: AnyObject]) {
        self.completedCount = extractInt(JSON, ["completed_count"])!
        self.uncompletedCount = extractInt(JSON, ["uncompleted_count"])!
        super.init(JSON: JSON)
    }
}
