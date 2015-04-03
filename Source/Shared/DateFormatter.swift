//
//  DateFormatter.swift
//  Wunderlist
//
//  Created by Constantine Fry on 10/12/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation

private let _sharedInstance = DateFormatter()

private struct DateFormatterConfiguration {
    /** The format for dates with time, used in Wunderlist API. */
    static let dateAndTimeFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    /** The format for dates. */
    static let dateFormat = "yyyy-MM-dd"
}

/**
    Thread-safe date formatter for date format used in Wunderlist API.
    All dates and times in the Wunderlist API are formatted as ISO-8601 strings. 
    All times are provided as UTC. 
    For example: 2013-10-09T23:34:11.000Z
*/
class DateFormatter {
    
    class func sharedInstance() -> DateFormatter {
        return _sharedInstance
    }
    
    private func formatterWithDateFormat(dateFormat: String)  -> NSDateFormatter {
        var dateFormatter = NSThread.currentThread().threadDictionary[dateFormat] as NSDateFormatter?
        if dateFormatter == nil {
            let newDateFormatter = NSDateFormatter()
            newDateFormatter.timeZone      = NSTimeZone(forSecondsFromGMT: 0)
            newDateFormatter.locale        = NSLocale(localeIdentifier:"en_US_POSIX")
            newDateFormatter.dateFormat    = dateFormat
            dateFormatter = newDateFormatter
            NSThread.currentThread().threadDictionary[dateFormat] = newDateFormatter
        }
        return dateFormatter!
    }
    
    /** Parses the string and returns date. */
    func dateFromString(string: String) -> NSDate? {
        var dateFormatter: NSDateFormatter!
        if string.hasSuffix("Z") {
            // To parse dates in format: 2013-10-09T23:34:11.000Z
            dateFormatter = formatterWithDateFormat(DateFormatterConfiguration.dateAndTimeFormat)
        } else {
            // To parse dates in format: 2013-10-09
            dateFormatter = formatterWithDateFormat(DateFormatterConfiguration.dateFormat)
        }
        let result = dateFormatter.dateFromString(string)
        if result == nil {
            fatalError("Date Formatter can't parse the date string: \(string)")
        }
        return result
    }
    
    /** Transforms date into string. */
    func stringFromDate(date: NSDate) -> String {
        let dateFormatter = formatterWithDateFormat(DateFormatterConfiguration.dateAndTimeFormat)
        let result = dateFormatter.stringFromDate(date)
        return result
    }
}
