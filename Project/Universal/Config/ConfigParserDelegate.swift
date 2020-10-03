//
//  ConfigParserDelegate.swift
//  Universal
//
//  Created by Mark on 26/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

protocol ConfigParserDelegate {
    func parseFailed(error:Error!)
    func parseSuccess(result:[Section]!)
    func parseOverviewSuccess(result:[Tab]!)
}


