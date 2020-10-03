//
//  TumblrProvider.swift
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation;
import SwiftyJSON;

class TumblrProvider: PhotosProvider {
    func getRequestUrl(params: [String], page: Int) -> String? {
        return String(format: "https://api.tumblr.com/v2/blog/%@.tumblr.com/posts?api_key=%@&type=photo&offset=%i&limit=%i", params[0], AppDelegate.TUMBLR_API, (page - 1) * 20, page * 20)
    }
    
    func parseRequest(params: [String], json: String) -> [Photo]? {
        let parseable = JSON.init(parseJSON: json)
        
        var results = [Photo]()
        
        if let photos = parseable["response"]["posts"].array {
            for photoJSON in photos {
                if (photoJSON["type"] == "photo") {
                    let result = Photo(tumblrPhotoJSON: photoJSON)
                    results.append(result)
                }
            }
        }
        
        return results
    }
}
