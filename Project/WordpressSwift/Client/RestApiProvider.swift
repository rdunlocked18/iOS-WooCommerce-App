//
//  JetPackProvider.swift
//  Hackers
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation;
import SwiftyJSON;
import Alamofire;

class RestApiProvider: ContentProvider {
    func getRequestUrl(blogParam: String, forType: WPAbstract.Type, params: RequestParams) -> String? {
        if (forType is WPPost.Type) {
            var query = blogParam + "posts?_embed=1"
            
            if (params.page != nil){
                query += "&page=\(String(describing: params.page!))"
            }
            if (params.category != nil){
                query += "&categories=\(params.category!)"
            }
            if (params.searchQuery != nil){
                query += "&search=\(String(describing: params.searchQuery!))"
            }
            if (params.tag != nil){
                query += "&tags=\(String(describing: params.tag!))"
            }
            
            return query;
        } else if (forType is WPCategory.Type) {
            var query = blogParam + "categories?orderby=count&order=desc"
            query += "&per_page=\(params.categoryCount)"
            
            return query
        }
        return nil
    }
    
    
    func parseRequest<T:WPAbstract>(parseable: JSON, forType: WPAbstract.Type) -> [T]? {
        if (forType is WPPost.Type) { 
            var results = [WPPost]()
            
            if let posts = parseable.array {
                for post in posts {
                    let result = WPPost()
                    result.title = post["title"]["rendered"].string
                    result.id = post["id"].int
                    result.date = post["date"].date
                    result.link = post["link"].string
                    result.content = post["content"]["rendered"].string
                    
                    result.tags = post["tags"].arrayValue.map({$0.stringValue})
                    result.categories = post["categories"].arrayValue.map({$0.stringValue})
                    
                    result.author.name = post["_embedded"]["author"].arrayValue[0]["name"].string
                    result.author.id = post["_embedded"]["author"].arrayValue[0]["id"].int
                    
                    result.comment_count = post["replies"].arrayValue.count
                    result.comment_open = post["comment_status"].string == "open"
                    
                    result.featured_media.url = post["_embedded"]["wp:featuredmedia"].array?[0]["source_url"].url
                    result.thumbnail.url = post["_embedded"]["wp:featuredmedia"].array?[0]["media_details"]["sizes"]["medium"]["source_url"].url
                    
                    result.attachmentsIncomplete = true
                    if let attachmentsUrl = post["_links"]["wp:attachment"].array?[0]["href"].string {
                        Alamofire.request(attachmentsUrl).responseJSON { (responseData) -> Void in

                            if((responseData.result.value) != nil) {
                                let attachments = JSON(responseData.result.value!)
                                for attachmentJson in attachments.arrayValue {
                                    let attachment = WPAttachment()
                                    if let attachmentId = attachmentJson["id"].int {
                                        attachment.id = attachmentId
                                    }
                                    if let attachmentUrl = attachmentJson["media_details"]["sizes"]["full"]["source_url"].url {
                                        attachment.url = attachmentUrl
                                    }
                                    if let attachmentMime = attachmentJson["mime_type"].string {
                                        attachment.mime = attachmentMime
                                        
                                        attachment.url = attachmentJson["source_url"].string?.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
                                                                                
                                        if (attachmentMime.contains("audio/")){
                                            let details = attachmentJson["media_details"]
                                            let artist = details["artist"].stringValue
                                            let album = details["album"].stringValue
                                            let length = details["length"].intValue * 1000
                                            
                                            let meta = WPAttachment.AudioMeta.init()
                                            meta.artist = artist
                                            meta.album = album
                                            meta.length = length
                                            attachment.audio_meta = meta
                                        }
                                    }
                                    if let attachmentDescription = attachmentJson["description"]["rendered"].string {
                                        attachment.description = attachmentDescription
                                    }
                                    if let attachmentLarge = attachmentJson["thumbnails"]["large"].url {
                                        attachment.sizes.large = attachmentLarge
                                    }
                                    if let attachmentMedium = attachmentJson["media_details"]["sizes"]["medium"]["source_url"].url {
                                        attachment.sizes.medium = attachmentMedium
                                    }
                                    if let attachmentThumbnail = attachmentJson["media_details"]["sizes"]["thumbnail"]["source_url"].url {
                                        attachment.sizes.thumbnail = attachmentThumbnail
                                    }
                                    if (attachment.url != nil ) {
                                        result.attachments.append(attachment)
                                    }
                                }
                            }
                            result.attachmentsIncomplete = false
                            if let completed = result.completedAction {
                                completed("abc")
                            }
                        }
                    }
                    

                    results.append(result)
                }
            }
            
            return results as? [T]
        } else if (forType is WPCategory.Type) {
            var results = [WPCategory]()
            
            if let categories = parseable.array {
                for category in categories {
                    let result = WPCategory()
                    
                    result.id = category["id"].stringValue
                    result.name = category["name"].stringValue
                    result.count = category["count"].intValue
                    results.append(result)
                }
            }
                    
            return results as? [T]
        }
        return nil
    }
}
