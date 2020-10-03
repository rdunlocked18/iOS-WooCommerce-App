//
//  SoundCloudAPI.swift
//  Universal
//
//  Created by Mark on 06/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import Alamofire


class SoundCloudAPI {
    
    //Singleton Instance
    static let sharedInstanceVar: SoundCloudAPI? = {
        var sharedInstance = SoundCloudAPI.init()
        return sharedInstance
    }()
    
    class func sharedInstance() -> SoundCloudAPI? {
        // `dispatch_once()` call was converted to a static variable initializer
        return sharedInstanceVar
        
    }
    
    //Instantiating Session
    init() {
        
    }
    
    func searchSoundCloudSongs(_ searchTerm: String?, completionHandler: @escaping (_ resultArray: [AnyHashable]?, _ error: String?) -> Void) {
        
        let apiURL = "http://api.soundcloud.com/tracks?client_id=\(AppDelegate.SOUNDCLOUD_CLIENT)&q=\(searchTerm ?? "")&format=json"
        
        Alamofire.request(apiURL).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            
            switch response.result {
            case .success(_):
                if let value = response.data {
                    let resultArray = SoundCloudSong.parseJSONData(value)
                    OperationQueue.main.addOperation({
                        completionHandler(resultArray, nil)
                    })
                }
            case .failure(let error):
                print(error)
                completionHandler(nil, "no connection")
            }
        }
    }
    
    func soundCloudSongs(_ param: String?, type: String?, offset: Int, limit: Int, completionHandler: @escaping (_ resultArray: [AnyHashable]?, _ error: String?) -> Void) {
        
        var apiURL: String
        if type?.isEqual("user") ?? false {
            apiURL = String(format: "http://api.soundcloud.com/users/%@/tracks?client_id=%@&offset=%i&limit=%i&format=json", param ?? "", AppDelegate.SOUNDCLOUD_CLIENT, offset, limit)
        } else {
            apiURL = String(format: "http://api.soundcloud.com/playlists/%@/tracks?client_id=%@&offset=%i&limit=%i&format=json", param ?? "", AppDelegate.SOUNDCLOUD_CLIENT, offset, limit)
        }
        
        Alamofire.request(apiURL).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            
            switch response.result {
            case .success(_):
                if let value = response.data {
                    let resultArray = SoundCloudSong.parseJSONData(value)
                    OperationQueue.main.addOperation({
                        completionHandler(resultArray, nil)
                    })
                }
            case .failure(let error):
                print(error)
                completionHandler(nil, "no connection")
            }
        }
        
    }
}

extension Int {
    
    func makeMilisecondsRedeable () -> String {
        let totalDurationSeconds = self / 1000
        let min = totalDurationSeconds / 60
        let sec = totalDurationSeconds % 60
        
        return String(format: "%i:%02i",min,sec )
    }
}
