//
//  RequestParams.swift
//  Hackers
//
//  Created by Mark on 20/11/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation

public class RequestParams {
    public var page: Int?
    public var perPage: Int?
    public var category: String?
    public var tag: String?
    public var searchQuery: String?
    
    public var categoryCount = 20
}
