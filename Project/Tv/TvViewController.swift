//
//  WordpressSwiftViewController.swift
//  Universal
//
//  Created by Mark on 03/03/2018.
//  Copyright © 2018 Sherdle. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import BMPlayer

final class TvViewController: UIViewController, BMPlayerDelegate{
    
    @IBOutlet weak var player: BMPlayer!
    var params: NSArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation Drawer
        self.player.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        BMPlayerConf.topBarShowInCase = .none
        BMPlayerConf.enableChooseDefinition = false
        
        view.addSubview(player)
        let url = params![0] as! String
        let asset = BMPlayerResource(url: URL(string: url)!, name: "Video")
        player.setVideo(resource: asset)
        
        player.delegate = self
    }
    
    //Does not work: https://stackoverflow.com/a/32808743/1683141
    override func viewWillDisappear(_ animated: Bool) {
        let nc = self.navigationController as! TabNavigationController
        nc.setStatusBar(hidden: false)
        super.viewWillDisappear(animated)
    }
    
    
    func bmPlayer(player: BMPlayer, playerStateDidChange state: BMPlayerState) {
        
    }
    
    func bmPlayer(player: BMPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        
    }
    
    func bmPlayer(player: BMPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        
    }
    
    func bmPlayer(player: BMPlayer, playerIsPlaying playing: Bool) {
        
    }
    
    func bmPlayer(player: BMPlayer, playerOrientChanged isFullscreen: Bool) {
        if (isFullscreen) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    @objc public static func initPlayer(){
        BMPlayerConf.topBarShowInCase = .none
        BMPlayerConf.enableChooseDefinition = false
    }
}

