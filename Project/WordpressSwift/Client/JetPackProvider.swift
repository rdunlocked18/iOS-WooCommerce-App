//
//  JetPackProvider.swift
//  Hackers
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation;
import SwiftyJSON;

class JetPackProvider: ContentProvider {
    func getRequestUrl(blogParam: String, forType: WPAbstract.Type, params: RequestParams) -> String? {
        if (forType is WPPost.Type) {
            var query = "https://public-api.wordpress.com/rest/v1.1/sites/" + blogParam + "/posts?fields=ID,author,title,URL,content,discussion,featured_image,post_thumbnail,tags,categories,discussion,date,attachments"
            
            if (params.page != nil){
                query += "&page=\(String(describing: params.page!))"
            }
            if (params.category != nil){
                query += "&category=\(params.category!))"
            }
            if (params.searchQuery != nil){
                query += "&search=\(String(describing: params.searchQuery!))"
            }
            if (params.tag != nil){
                query += "&tag=\(String(describing: params.tag!))"
            }
            
            return query;
        } else if (forType is WPCategory.Type) {
            var query = "https://public-api.wordpress.com/rest/v1.1/sites/" + blogParam + "/categories?order_by=count&order=DESC&fields=ID,slug,name,post_count"
            query += "&number=\(String(describing: params.categoryCount))"
            return query
        }
        return nil
    }
    
    
    func parseRequest<T:WPAbstract>(parseable: JSON, forType: WPAbstract.Type) -> [T]? {
        if (forType is WPPost.Type) { 
            var results = [WPPost]()
            
            if let posts = parseable["posts"].array {
                for post in posts {
                    let result = WPPost()
                    result.title = post["title"].string
                    result.id = post["ID"].int
                    result.date = post["date"].date
                    result.link = post["URL"].string
                    result.content = post["content"].string
                    
                    result.tags = post["tags"].dictionaryValue.values.map({$0["slug"].stringValue})
                    result.categories = post["categories"].dictionaryValue.values.map({$0["slug"].stringValue})
                    
                    result.author.name = post["author"]["name"].string
                    result.author.id = post["author"]["ID"].int
                    
                    result.comment_count = post["discussion"]["comment_count"].int
                    result.comment_open = post["discussion"]["comments_open"].bool
                    
                    result.featured_media.url = post["featured_image"].url
                    result.thumbnail.url = post["post_thumbnail"]["URL"].url
                    
                    for (_, attachmentJson) in post["attachments"] {
                        let attachment = WPAttachment()
                        if let attachmentId = attachmentJson["ID"].int {
                            attachment.id = attachmentId
                        }
                        if let attachmentUrl = attachmentJson["URL"].url {
                            attachment.url = attachmentUrl
                        }
                        if let attachmentMime = attachmentJson["mime_type"].string {
                            attachment.mime = attachmentMime
                        }
                        if let attachmentDescription = attachmentJson["description"].string {
                            attachment.description = attachmentDescription
                        }
                        if let attachmentLarge = attachmentJson["thumbnails"]["large"].url {
                            attachment.sizes.large = attachmentLarge
                        }
                        if let attachmentMedium = attachmentJson["thumbnails"]["medium"].url {
                            attachment.sizes.medium = attachmentMedium
                        }
                        if let attachmentThumbnail = attachmentJson["thumbnails"]["thumbnail"].url {
                            attachment.sizes.thumbnail = attachmentThumbnail
                        }
                        result.attachments.append(attachment)
                    }

                    results.append(result)
                }
            }
            
            return results as? [T]
        } else if (forType is WPCategory.Type) {
            var results = [WPCategory]()
    
            if let categories = parseable["categories"].array {
                for category in categories {
                    let result = WPCategory()
                    result.id = category["slug"].stringValue
                    result.name = category["name"].stringValue
                    result.count = category["post_count"].intValue
                    results.append(result)
                }
            }
            
            return results as? [T]
        }
        return nil
    }
}
