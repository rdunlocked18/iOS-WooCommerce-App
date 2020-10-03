//
//  PhotosProvider.swift
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol PhotosProvider {
    func getRequestUrl(params: [String], page: Int) -> String?
    func parseRequest(params: [String], json: String) -> [Photo]?
}
