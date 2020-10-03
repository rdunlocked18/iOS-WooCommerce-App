//
//  SocialClient.swift
//
//  Created by Sherdle
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Swifter

public class SocialClient {
    
    public init(){}
    
    public func get(identifier: String, params: SocialRequestParams, provider: SocialProvider, completionHandler: @escaping (Bool, [SocialItem]?, String?) -> Void) {
        
        if let provider: TwitterProvider = provider as? TwitterProvider {
            provider.get(identifier: identifier, params: params, completionHandler: completionHandler)
        } else {
            var result: ([SocialItem]?, String?)

            let requestUrl = provider.getRequestUrl(identifier: identifier, params: params)!
            print(requestUrl)
            Alamofire.request(requestUrl).responseJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Result: \(String(describing: response.result.value))")                   // response serialization result
                
                if (response.result.isFailure){
                     completionHandler(false, nil, nil)
                    return
                }

                DispatchQueue.global(qos: .background).async {
                    let swiftyJsonVar = SwiftyJSON.JSON(response.result.value!)
                    result = provider.parseRequest(parseable: swiftyJsonVar)
                    
                    DispatchQueue.main.async {
                        completionHandler(true, result.0, result.1)
                    }
                }
            }
        }
        
    }
}
