//
//  WordpressSwift.swift
//  Wordpress Swift
//
//  Created by Sherdle on 4/3/18.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class WPAbstract {
    init() {}
}

public class WPPost: WPAbstract {
    
    public class Author {
        public var name: String?
        public var id: Int?
    }
    
    public var id: Int?
    public var date: String?
    public var date_gmt: String?
    public var modified: String?
    public var modified_gmt: String?
    public var slug: String?
    public var status: String?
    public var type: String?
    public var link: String?
    public var title: String?
    public var content: String?
    public var author = Author()
    public var featured_media = WPAttachment()
    public var thumbnail = WPAttachment()
    public var attachments = [WPAttachment]()
    public var comment_count: Int?
    public var comment_open: Bool?
    public var ping_status: String?
    public var sticky: Bool?
    public var template: String?
    public var format: String?
    public var categories: [String]?
    public var tags: [String]?
    
    public var attachmentsIncomplete = false
    public var completedAction: ((_ value : String) -> Void)? = nil
    
}

public protocol AttachmentsObserver{
    var id : Int{ get }
    func attachmentsCompleted()
}

public class WPCategory: WPAbstract {
    
    public var id: String? //Can also be slug
    public var count: Int?
    public var description: String?
    public var link: String?
    public var name: String?
    public var taxonomy: String?
    public var parent: Int?
}

public class WPAttachment: WPAbstract {
    
    public class Sizes {
        public var thumbnail: String?
        public var medium: String?
        public var large: String?
    }
    
    public class AudioMeta {
        public var artist: String?
        public var album: String?
        public var length: Int?
    }
    
    public var id: Int?
    public var url: String?
    public var mime: String?
    public var description: String?
    public var audio_meta: AudioMeta?
    public var sizes = Sizes()
    
}

public class WordpressSwift {
    
    public init(){}
    
    /**
    Get posts published on Wordpress blog
     - parameter blogURL: API baseurl or site identifier
     - parameter params: RequestParameters
     - parameter forType: Type that you want to fetch, for example posts
     - parameter completionHandler: Fetched content
     */
    public func get<T:WPAbstract>(blogURL: String, params: RequestParams, forType: WPAbstract.Type, completionHandler: @escaping (Bool, [T]?) -> Void) {
        
        var result: [T]?
        
        var provider: ContentProvider?
        if (blogURL.range(of: "/wp-json/wp/v2/") != nil) {
            provider = RestApiProvider()
        } else if (blogURL.range(of: "http") != nil)  {
            print("The JSON API is no longer supported! Migrate to another API");
        } else {
            provider = JetPackProvider()
        }

        Alamofire.request(provider!.getRequestUrl(blogParam: blogURL, forType: forType, params: params)!).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            //print("Result: \(String(describing: response.result.value))")                   // response serialization result
            
            if (response.result.isFailure){
                 completionHandler(false, nil)
                return
            }

            DispatchQueue.global(qos: .background).async {
                let swiftyJsonVar = JSON(response.result.value!)
                result = provider!.parseRequest(parseable: swiftyJsonVar, forType: forType) as? [T]
                
                DispatchQueue.main.async {
                    completionHandler(true, result!)
                }
            }
        }
        
    }
    
    
    
    /**
    public func featuredImage(blogURL: String, post: WPPost, completionHandler: @escaping (WPFeaturedImage) -> Void) {
        
        let baseURL = blogURL + "/wp-json/wp/v2/media/" + "\(post.featured_media)"
        
        guard let url = URL(string: baseURL) else {
            
            print("ERROR: Please, type a correct URL, like:  http://myblog.com")
            return
            
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else { return }
            do {
                
                let image = try JSONDecoder().decode(WPFeaturedImage.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(image)
                }
                
            } catch {
                print("ERROR")
            }
            
            }.resume()
        
        
    }
    */
}

extension String {
    
    init?(htmlEncodedString: String) {
        
        guard let data = htmlEncodedString.data(using: .utf8) else {
            return nil
        }
        
        
        guard let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil) else {
            return nil
        }
        
        self.init(attributedString.string)
    }
    
}
