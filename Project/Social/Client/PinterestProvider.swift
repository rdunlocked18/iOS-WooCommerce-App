//
//  PinterestProvider.swift
//  Hackers
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation;
import SwiftyJSON;

class PinterestProvider: SocialProvider {
    func getRequestUrl(identifier: String, params: SocialRequestParams) -> String? {
        var query = ""
        if let nextPageUrl = params.nextPageToken {
            query = nextPageUrl
        } else {
            query = String(format: "https://api.pinterest.com/v1/boards/%@/pins/?fields=id,original_link,note,image,media,attribution,created_at,creator(image,first_name),counts&limit=100&access_token=%@", identifier, AppDelegate.PINTEREST_ACCESS_TOKEN)
        }
        
        return query
    }
    
    
    func parseRequest(parseable: JSON) -> ([SocialItem]?, String?) {
        var results = [SocialItem]()
        
        if let posts = parseable["data"].array {
            for post in posts {
                let result = SocialItem(pinterestPost: post)
                results.append(result)
            }
        }
        
        let pageToken = parseable["page"]["next"].string
                
        return (results, pageToken)
    }
}
