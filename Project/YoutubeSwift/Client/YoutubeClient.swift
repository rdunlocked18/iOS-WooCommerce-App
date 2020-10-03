//
//  YoutubeClient.swift
//  Universal
//
//  Created by Mark on 02/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class YoutubeClient: NSObject {
    
    public enum RequestType {
        case playlist
        case live
        case channel
        case query
        case related
    }
    
    static func getResults(parameter : String, type : RequestType, search: String?, pageToken : String?, completion:@escaping (_ success: Bool, _ nextPageToken : String?, _ items : [Video]) -> Void){
        
        var url: String?
        if (type == .query) {
            let queryReady = search!.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            url = "https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&channelId=\(parameter)&q=\(queryReady!)&maxResults=20&key=\(AppDelegate.YOUTUBE_CONTENT_KEY)&pageToken=\(pageToken ?? "")"
        } else if (type == .playlist) {
            url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=\(parameter)&maxResults=20&key=\(AppDelegate.YOUTUBE_CONTENT_KEY)&pageToken=\(pageToken ?? "")"
        } else if (type == .live) {
            url = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(parameter)&type=video&eventType=live&maxResults=20&key=\(AppDelegate.YOUTUBE_CONTENT_KEY)&pageToken=\(pageToken ?? "")"
        } else if (type == .channel) {
            url = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(parameter)&type=video&order=date&maxResults=20&key=\(AppDelegate.YOUTUBE_CONTENT_KEY)&pageToken=\(pageToken ?? "")"
        } else if (type == .related) {
            url = "https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=\(parameter)&type=video&key=\(AppDelegate.YOUTUBE_CONTENT_KEY)"
        }
        
        
        Alamofire.request(url!).validate().responseJSON { response in
            switch response.result {
            case .success(_):
                if let value = response.result.value {
                    let json = JSON(value)
                    //print("Response JSON: \(json)")
                    
                    if let array = json["items"].array{
                        parseSearch(objects: array, completion: { (items) -> Void in
                            let nextpagetoken = json["nextPageToken"].string
                            completion(true, nextpagetoken, items)
                        })
                        
                    }
                }
            case .failure(let error):
                print(error)
                completion(false, nil, [])
            }
        }
    }
    
    static func parseSearch(objects : [JSON], completion : (_ items : [Video]) -> Void){
        var items = [Video]()
        for object in objects{
            //Only add non-private videos (-> with a thumbnail)
            if (object["snippet"]["thumbnails"]["high"]["url"].string != nil) {
                items.append(parseVideo(object: object))
            }
        }
        
        completion(items)
    }
    
    static func parseVideo(object : JSON) -> Video {
        
        let video = Video()
        video.id = object["id"]["videoId"].string
        if (video.id == nil) {
            video.id = object["snippet"]["resourceId"]["videoId"].string
        }
        video.snippet.description = object["snippet"]["description"].string
        
        video.snippet.thumbnails.high.url = object["snippet"]["thumbnails"]["high"]["url"].string
        video.snippet.thumbnails.medium.url = object["snippet"]["thumbnails"]["medium"]["url"].string
        video.snippet.thumbnails.default.url = object["snippet"]["thumbnails"]["default"]["url"].string
        
        video.snippet.publishedAt = object["snippet"]["publishedAt"].date //Date extension  (in jetpack provider) doesn't support youtube yet
        video.snippet.channelTitle = object["snippet"]["channelTitle"].string
        video.snippet.title = object["snippet"]["title"].string
        
        return video
    }
    
}

public class Video {
    public var id: String?
    public var statistics = Statistics()
    public var snippet = Snippet()
    public var duration: String?
}


public class Snippet {
    public var description: String?
    public var channelID: String?
    public var categoryID: String?
    public var channelTitle: String?
    public var tags: [String]?
    public var publishedAt: String?
    public var thumbnails = Thumbnails()
    public var title: String?
    
    public init() {
    }
}

public class Statistics {
    public var dislikeCount: String?
    public var likeCount: String?
    public var commentCount: String?
    public var favoriteCount: String?
    public var viewCount: String?
    
    public init() {
    }
}

public class Thumbnails {
    public var  high = Default()
    public var  `default` = Default()
    public var  medium = Default()
    
    public struct Default {
        public var  url: String?
        public var  height: Int?
        public var  width: Int?
    }
    
    public init() {
    }
}
