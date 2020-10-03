//
//  PostCell.swift
//  Universal
//
//  Created by Mark on 09/12/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import FeedKit

protocol PostCell {
    var post: WPPost? {get set}
    var item: RSSFeedItem? {get set}
    var video: Video? {get set}
    var audio: SoundCloudSong?{get set}
}
