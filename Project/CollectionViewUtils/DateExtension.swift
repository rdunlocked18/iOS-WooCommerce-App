//
//  DateExtension.swift
//  Universal
//
//  Created by Mark on 04/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    public var date: String? {
        get {
            if let intVal = self.int {
                let date = Date(timeIntervalSince1970: TimeInterval(intVal))
                return dateToString(date: date)
            } else if let str = self.string {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = (str.range(of:"+") != nil || str.range(of:"-") != nil) ?
                    "yyyy-MM-dd'T'HH:mm:ssZZZZZ" : ((str.range(of:"Z") != nil) ? "yyyy-MM-dd'T'HH:mm:ss.sZ" : "yyyy-MM-dd'T'HH:mm:ss")
                dateFormatter.timeZone = TimeZone.autoupdatingCurrent
                
                if let date = dateFormatter.date(from: str) {
                    return dateToString(date: date)
                } else {
                    return str
                }
            }
            return nil
        }
    }
    
    public var url: String? {
        return self.string?.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
    }
    
    public var dateTweet: String? {
        get {
            if let str = self.string {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
                dateFormatter.timeZone = TimeZone.autoupdatingCurrent
                
                if let date = dateFormatter.date(from: str) {
                    return dateToString(date: date)
                } else {
                    return str
                }
            }
            return nil
        }
    }
    
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.short
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
    
}
