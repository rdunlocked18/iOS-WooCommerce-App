//
//  NetworkManager.swift
//  Universal
//
//  Created by Mark on 11/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
    
    var manager: SessionManager?
    
    init() {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 20
        manager = Alamofire.SessionManager(configuration: sessionConfiguration)
    }
}
