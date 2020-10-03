//
//  SoundCloudSong.swift
//  Universal
//
//  Created by Mark on 06/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON

class SoundCloudSong: NSObject {
    
    var title = ""
    var stream_url = ""
    var userDict: JSON?
    var userName = ""
    var artWorkURL: String?
    var artWorkURLHigh: String?
    var userAvatar: String?
    var trackID = ""
    var duration: Int?
    
    convenience init(json SoundCloudSongDict: JSON) {
        self.init()
        
        title = SoundCloudSongDict["title"].stringValue
        stream_url = SoundCloudSongDict["stream_url"].stringValue
        userDict = SoundCloudSongDict["user"]
        userName = userDict!["username"].stringValue
        artWorkURL = SoundCloudSongDict["artwork_url"].stringValue
        if let url = SoundCloudSongDict["artwork_url"].string {
            artWorkURLHigh = url.replacingOccurrences(of: "large.jpg", with: "t500x500.jpg")
        }
        trackID = SoundCloudSongDict["id"].stringValue
        userAvatar = userDict!["avatar_url"].stringValue
        duration = SoundCloudSongDict["duration"].intValue
    }
    
    class func parseJSONData(_ JSONData: Data?) -> [SoundCloudSong]? {
        var SoundCloudSongArray = [SoundCloudSong]()
        
        if let json = try? JSON(data: JSONData!) {
            if let jsonArray = json.array {
                for trackJson in jsonArray {
                    let soundCloudSong = SoundCloudSong(json: trackJson)
                    SoundCloudSongArray.append(soundCloudSong)
                }
            }
        }
        
        return SoundCloudSongArray
        
    }
}
