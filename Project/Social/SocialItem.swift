//
//  Photo.swift
//  Universal
//
//  Created by Mark on 08/02/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON

public class SocialItem: NSObject {
    
    var itemKind: ItemKind?
    
    var imageUrls: [String]?
    var imageAspect: Float?
    var videoUrl: String?
    var authorName: String?
    var authorUserName: String?
    var authorImageUrl: String?
    var date: String?
    var url: String?
    var text: String?
    var id: String?
    
    var counterOneCount: Int?
    var counterTwoCount: Int?
    
    enum ItemKind {
        case facebook, instagram, pinterest, twitter
    }
    
    convenience init(facebookPost: JSON) {
        self.init()
    
        itemKind = ItemKind.facebook
        
        let attachment = facebookPost["attachments"]["data"][0];
        
        text = facebookPost["message"].string
        date = facebookPost["created_time"].date
        authorName = facebookPost["from"]["name"].string
        authorImageUrl = String(format:"https://graph.facebook.com/v4.0/%@/picture", facebookPost["from"]["id"].stringValue)
        counterOneCount = facebookPost["likes"]["summary"]["total_count"].int
        counterTwoCount = facebookPost["comments"]["summary"]["total_count"].int
        
        if let link = attachment["media"]["source"].string {
            url = link
        } else {
            url = String(format: "https://www.facebook.com/%@", facebookPost["id"].stringValue)
        }
        
        if let attachments = facebookPost["attachments"]["data"].array, attachments.count > 0 {
            var mediaAttachments = [JSON]()
            
            //Some attachments are media, some are attachments that have an array media
            for attachment in attachments {
                if let subAttachments = attachment["subattachments"]["data"].array {
                    mediaAttachments.append(contentsOf: subAttachments)
                } else if attachment["media"].exists() {
                    mediaAttachments.append(attachment)
                }
            }
            
            imageUrls = [String]()
            for mediaAttachment in mediaAttachments {
                if (!mediaAttachment["media"]["image"].exists()) { continue }
                //var description = attachment["description"]
                imageUrls!.append(mediaAttachment["media"]["image"]["src"].stringValue)
                
                if (mediaAttachments.firstIndex(of: mediaAttachment) == 0){
                    imageAspect = Float(mediaAttachment["media"]["image"]["width"].floatValue / mediaAttachment["media"]["image"]["height"].floatValue)
                }
            }
        } else if let fullPicture = facebookPost["full_picture"].string {
            imageUrls = [String]()
            imageUrls?.append(fullPicture)
        }
        
        if attachment["media_type"].stringValue == "video", let video = attachment["media"]["source"].string {
            videoUrl = video
        }
    }
    
    convenience init(instagramPost: JSON) {
        self.init()
        
        itemKind = ItemKind.instagram
        
        text = instagramPost["caption"].string
        date = instagramPost["timestamp"].date
        url = instagramPost["permalink"].string
        
        imageUrls = [String]()
        if let attachments = instagramPost["children"]["data"].array, attachments.count > 0 {
            
            for attachment in attachments {
                if (attachment["media_type"] != "IMAGE") { continue }
                imageUrls!.append(attachment["media_url"].stringValue)
            }
        } else if let image = instagramPost["thumbnail_url"].string {
            imageUrls?.append(image)
        } else if let image = instagramPost["media_url"].string {
            imageUrls?.append(image)
        }
        
        if instagramPost["media_type"].stringValue == "VIDEO", let video = instagramPost["media_url"].string {
            videoUrl = video
        }
        authorName = instagramPost["owner"]["name"].string
        authorUserName = instagramPost["username"].string
        authorImageUrl = instagramPost["owner"]["profile_picture_url"].string
        
        counterOneCount = instagramPost["like_count"].int
        counterTwoCount = instagramPost["comments_count"].int
    }
    
    convenience init(pinterestPost: JSON) {
        self.init()
        
        itemKind = ItemKind.pinterest
        
        text = pinterestPost["note"].string
        url = pinterestPost["original_link"].string
        date = pinterestPost["created_at"].date
        
        imageUrls = [String]()
        if let image = pinterestPost["image"]["original"]["url"].string {
            imageUrls?.append(image)
            imageAspect = Float(pinterestPost["image"]["original"]["width"].floatValue / pinterestPost["image"]["original"]["height"].floatValue)
        }
        
        authorName = pinterestPost["creator"]["first_name"].string
        authorImageUrl = pinterestPost["creator"]["image"]["60x60"]["url"].string
        
        counterOneCount = pinterestPost["counts"]["saves"].int
        counterTwoCount = pinterestPost["counts"]["comments"].int
    }
    
    convenience init(tweet: JSON) {
        self.init()
        
        itemKind = ItemKind.twitter
        
        id = tweet["id_str"].string
        text = tweet["full_text"].string
        url =  String(format: "https://twitter.com/%@/status/%@", tweet["user"]["screen_name"].stringValue, id!)
        date = tweet["created_at"].dateTweet
        
        if let attachments = tweet["extended_entities"]["media"].array, attachments.count > 0 {
            imageUrls = [String]()
            for attachment in attachments {
                imageUrls!.append(attachment["media_url_https"].stringValue)
                
                if (attachments.firstIndex(of: attachment) == 0){
                    imageAspect = Float(attachment["sizes"]["large"]["w"].floatValue / attachment["sizes"]["large"]["h"].floatValue)
                    
                    if (attachment["video_info"].exists() && attachment["video_info"]["variants"].array?.count ?? 0 > 0), let vid = attachment["video_info"]["variants"].array?[0], vid["content_type"].string?.contains("video") ?? false {
                        videoUrl = vid["url"].string
                        
                        break
                    }
                }
            }
        }

        authorName = tweet["user"]["name"].string
        authorUserName = tweet["user"]["screen_name"].string
        authorImageUrl = tweet["user"]["profile_image_url_https"].string
        
        counterOneCount = tweet["favorite_count"].int
        counterTwoCount = tweet["retweet_count"].int
    }
    
}
