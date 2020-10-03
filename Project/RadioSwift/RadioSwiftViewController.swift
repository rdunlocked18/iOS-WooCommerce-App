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
import FRadioPlayer
import MediaPlayer

final class RadioSwiftViewController: UIViewController, FRadioPlayerDelegate{

    var params: NSArray!
    let player = FRadioPlayer.shared
    
    @IBOutlet weak var imageView: UIImageView!
    var realImageView: UIImageView?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playButtonImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playPauseClicked(_ sender: Any) {
        if (player.isPlaying) {
            player.pause()
        } else {
            player.play()
        }
        updatePlayImage()
    }
    
    func updatePlayImage(){
        if (player.isPlaying){
            playButtonImage.image = UIImage(named: "pause.png")
        } else {
            playButtonImage.image = UIImage(named: "play.png")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        // Navigation Drawer
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.view.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        
        player.delegate = self
        player.radioURL = URL(string: params![0] as! String)
        player.enableArtwork = true
        player.artworkSize = 500
        player.play()
        
        playButton.round()
        styleImageView()
        setupAVAudioSession()
    }
    
    func styleImageView() {
        //Make elevation
        imageView.image = nil
        imageView.clipsToBounds = false
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.24
        imageView.layer.shadowOffset = CGSize(width: 0, height: 0)
        imageView.layer.shadowRadius = CGFloat(10)
        imageView.layer.shadowPath = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: 10).cgPath
        
        realImageView = UIImageView(frame: imageView.bounds)
        realImageView!.clipsToBounds = true
        realImageView!.layer.cornerRadius = 25
        
        imageView.addSubview(realImageView!)
    }
    
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        if (state == FRadioPlayerState.loading) {
            loadingIndicator.startAnimating()
            loadingIndicator.isHidden = false
        } else if (state == FRadioPlayerState.loadingFinished || state == FRadioPlayerState.readyToPlay) {
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
        }
    }
    
    private func setupAVAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("AVAudioSession is Active and Category Playback is set")
            
            //Do we ever need to unregister? I.e. when clicking pause
            UIApplication.shared.beginReceivingRemoteControlEvents()
            setupCommandCenter()
        } catch {
            debugPrint("Error: \(error)")
        }
    }
    
    private func setupCommandCenter() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: NSLocalizedString("radio_live", comment: "")]
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [self] (event) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            return .success
        }
        commandCenter.pauseCommand.addTarget { [self] (event) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            return .success
        }
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        updatePlayImage()
    }
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        if (UIScreen.main.nativeBounds.height > 1136) {
            self.artist.text = artistName
        } else {
            self.artist.text = ""
        }
        self.trackName.text = trackName
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: trackName ?? NSLocalizedString("radio_live", comment: ""), MPMediaItemPropertyArtist: artistName ?? ""]
    }
    
    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        if (realImageView == nil) { return }
        
        if (artworkURL != nil) {
            realImageView!.sd_setImage(with: artworkURL, completed: nil)
        } else {
            realImageView!.image = UIImage(named: "album_placeholder.png")
        }
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        realImageView?.frame = imageView.bounds
        imageView.layer.shadowPath = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: 10).cgPath
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
