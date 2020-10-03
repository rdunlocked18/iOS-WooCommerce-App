//
//  TwitterClient.swift
//  Universal
//
//  Created by Mark on 10/03/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON
import Swifter

class TwitterProvider: SocialProvider {
    
    public func get(identifier: String, params: SocialRequestParams, completionHandler: @escaping (Bool, [SocialItem]?, String?) -> Void) {
        // Instantiation using Twitter's OAuth Consumer Key and secret
        let swifter = Swifter(consumerKey: AppDelegate.TWITTER_API, consumerSecret: AppDelegate.TWITTER_API_SECRET, oauthToken: AppDelegate.TWITTER_TOKEN, oauthTokenSecret: AppDelegate.TWITTER_TOKEN_SECRET)
        
        if let pageToken = params.nextPageToken {
            params.nextPageToken = String(Int(pageToken)! - 1)
        }
        
        if (identifier.starts(with: "?")) {
            let query = String(format: "%@ -filter:retweets",identifier.replacingOccurrences(of: "?", with: ""))
            
            swifter.searchTweet(using: query, geocode: nil, lang: nil, locale: nil, resultType: "mixed", count: 20, until: nil, sinceID: nil, maxID: params.nextPageToken, includeEntities: true, callback: nil, tweetMode: TweetMode.extended, success: { (json, meta) in
                
                print(meta)
                
                let json = SwiftyJSON.JSON(parseJSON:  json.description)
                let result = self.parseRequest(parseable: json)
                
                DispatchQueue.main.async {
                    completionHandler(true, result.0, result.1) //array of tweets, id of oldest tweet
                }
                
            }) { (error) in
                print("ErrorX")
                print(error)
                DispatchQueue.main.async {
                    completionHandler(false, nil, nil)
                }
            }
        } else {
            swifter.getTimeline(for: .screenName(identifier), customParam: ["screen_name":identifier], count: 20, sinceID: nil, maxID: params.nextPageToken, trimUser: false, excludeReplies: true, includeRetweets: false, contributorDetails: true, includeEntities: true, tweetMode: TweetMode.extended, success: { (json) in
                
                let json = SwiftyJSON.JSON(parseJSON:  json.description)
                let result = self.parseRequest(parseable: json)
                
                DispatchQueue.main.async {
                    completionHandler(true, result.0, result.1) //array of tweets, id of oldest tweet
                }
            }) { (error) in
                DispatchQueue.main.async {
                    completionHandler(false, nil, nil)
                }
            }
        }
    }
    
    func getRequestUrl(identifier: String, params: SocialRequestParams) -> String? {
        return nil
    }
    
   func parseRequest(parseable: SwiftyJSON.JSON) -> ([SocialItem]?, String?) {
        var results = [SocialItem]()
    
        if let tweets = parseable.array {
            for tweet in tweets {
                let result = SocialItem(tweet: tweet)
                results.append(result)
            }
        }
        
        let pageToken = results.last?.id
        
        return (results, pageToken)
    }
}
