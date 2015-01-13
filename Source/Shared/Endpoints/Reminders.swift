//
//  Reminders.swift
//  Wunderlist
//
//  Created by Constantine Fry on 05/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

/**
    Represents Reminders endpoint on Wunderilst.
    https://developer.wunderlist.com/documentation/endpoints/reminder
*/
public class Reminders: Endpoint {
    override var endpoint: String {
        return "reminders"
    }
    
    public func createReminder(taskId: Int, date: NSDate, complectionHandler: (reminder: Reminder?, error: NSError?) -> Void) -> SessionTask {
        var dateString = DateFormatter.sharedInstance().stringFromDate(date)
        let parameters = [
            "task_id"   : taskId,
            "date"      : dateString
        ] as [String: AnyObject]
        
        return taskWithPath(nil, parameters: parameters, HTTPMethod: "POST", transformClosure: { Reminder(JSON: $0) }) {
            (result, error) -> Void in
            complectionHandler(reminder: result as Reminder?, error: error)
        }
    }
}

