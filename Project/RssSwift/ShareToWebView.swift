//
//  ShareToWebView.swift
//  Universal
//
//  Created by Mark on 27/09/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation

final class ShareToWebView: UIActivity {
    var url: String?
    var navController: UINavigationController?

    override var activityImage: UIImage? {
        return UIImage(named: "btn_post")!
    }

    override var activityTitle: String? {
        return NSLocalizedString("open", comment:"")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            self.url = (item as! String)
        }
    }

    override func perform() {
        let completed = false

        if let url = self.url {
            AppDelegate.openUrl(url: url, withNavigationController: self.navController)
        }

        activityDidFinish(completed)
    }
}
