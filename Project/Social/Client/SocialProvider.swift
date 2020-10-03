//
//  SocialProvider.swift
//  Hackers
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol SocialProvider {
    func getRequestUrl(identifier: String, params: SocialRequestParams) -> String?
    func parseRequest(parseable: JSON) -> ([SocialItem]?, String?)
}
