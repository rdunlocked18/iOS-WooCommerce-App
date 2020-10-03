//
//  Photo.swift
//  Universal
//
//  Created by Mark on 08/02/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON

public class Photo: NSObject {
    
    var url_full: String?
    var url_thumbnail: String?
    
    convenience init(tumblrPhotoJSON: JSON) {
        self.init()
        
        url_full = tumblrPhotoJSON["photos"].arrayValue[0]["original_size"]["url"].stringValue
        for photo in tumblrPhotoJSON["photos"].arrayValue[0]["alt_sizes"].arrayValue {
            if (photo["width"].intValue == 640) {
                url_thumbnail = photo["url"].stringValue
            }
        }
        if (url_thumbnail == nil) {
            url_thumbnail = url_full
        }
        
    }
    
    convenience init(flickrPhotoJSON: JSON) {
        self.init()
        
        //use url_o for url of true full imagery, however for very large source images, this results in unstable behavior.
        url_full = flickrPhotoJSON["url_c"].stringValue
        url_thumbnail = flickrPhotoJSON["url_c"].stringValue
        
    }
}
