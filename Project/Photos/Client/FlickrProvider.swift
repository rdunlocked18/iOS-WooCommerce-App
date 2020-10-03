//
//  FlickrProvider.swift
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation;
import SwiftyJSON;
import Alamofire;

class FlickrProvider: PhotosProvider {
    func getRequestUrl(params: [String], page: Int) -> String? {
        let method = params[1]
        let galleryId = params[0]
        let pathMethod = !(method == "gallery") ? "photosets" : "galleries"
        let idMethod = !(method == "gallery") ? "photoset_id" : "gallery_id";
        
        return String(format:"https://api.flickr.com/services/rest/?method=flickr.%@.getPhotos&api_key=%@&%@=%@&format=json&extras=path_alias,url_o,url_c,url_b,url_z&per_page=20&page=%d", pathMethod, AppDelegate.FLICKR_API, idMethod, galleryId, page)
    }
    
    func parseRequest(params: [String], json: String) -> [Photo]? {
        var modifiedJson = json
        if (modifiedJson.contains("jsonFlickrApi(")) {
            modifiedJson = modifiedJson.replacingOccurrences(of: "jsonFlickrApi(", with: "")
            modifiedJson = String(modifiedJson.dropLast())
        }
        let method = params[1]
        
        let parseable = JSON.init(parseJSON: modifiedJson)
        var results = [Photo]()
        
        if let photos = parseable[!(method == "gallery") ? "photoset" : "photos"]["photo"].array {
            for photoJSON in photos {
                let result = Photo(flickrPhotoJSON: photoJSON)
                
                results.append(result)
            }
        }
        
        return results
    }
}
