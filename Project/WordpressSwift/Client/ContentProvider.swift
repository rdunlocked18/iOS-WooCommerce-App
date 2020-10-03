//
//  ContentProvider.swift
//  Hackers
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol ContentProvider {
    func getRequestUrl(blogParam: String, forType: WPAbstract.Type, params: RequestParams) -> String?
    func parseRequest<T:WPAbstract>(parseable: JSON, forType: WPAbstract.Type) -> [T]?
}
