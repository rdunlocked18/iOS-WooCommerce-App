//
//  RssExtensions.swift
//  Universal
//
//  Created by Mark on 17/12/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import FeedKit

extension Date
{
    func toString() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }
    
}

extension RSSFeedItem
{
    func getImageUrl() -> String?
    {
        //TODO check if this works for feeds with properly attached images
        if ((self.media?.mediaBackLinks?.count ?? 0) > 0) {
            return self.media?.mediaBackLinks![0]
        } else {
            let regex = "(http[^\\s]+(jpg|jpeg|png|tiff)\\b)"
            let matches = self.matches(for: regex, in: self.description)
            return (matches.count > 0) ? matches[0] : nil
        }
    }
    
    private func matches(for regex: String!, in text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            if let nsString = text as NSString? {
                let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
                return results.map { nsString.substring(with: $0.range)}
            }
            return []
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
}
