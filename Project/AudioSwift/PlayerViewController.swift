//
//  PlayerViewController.swift
//  Universal
//
//  Created by Mark on 05/01/2019.
//  Copyright © 2019 Sherdle. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController {
    
    @IBOutlet weak var blurBgImage: UIImageView!
    
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var durationView: UILabel!
    @IBOutlet weak var timeView: UILabel!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playPauseButtonView: UIView!
    
    private var timer: Timer!
    
    static var player: AVPlayer?
    
    static var playArray: [SoundCloudSong]!
    static var playIndex: Int!
    var indexChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        // Do any additional setup after loading the view, typically from a nib.
        self.view.layoutIfNeeded()
        self.view.backgroundColor = UIColor.clear
        self.playPauseButtonView.round()
        self.progressSlider.addTarget(self, action: #selector(PlayerViewController.userSeek), for: UIControl.Event.valueChanged)
        
        self.imageview.image = UIImage(named: "album_placeholder.png")
        self.progressSlider.value = 0.0
        
        setupAVAudioSession()
        
        if (indexChanged) {
            playSongAt(index: PlayerViewController.playIndex)
        } else {
            showUIForSongAt(index: PlayerViewController.playIndex)
            start()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.makeItRounded(view: imageview, newSize: self.imageview.frame.width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showUIForSongAt(index: Int){
        self.progressSlider.value = 0.0
        
        if let artworkUrlHigh = PlayerViewController.playArray[index].artWorkURLHigh {
            self.imageview.sd_setImage(with: URL(string: artworkUrlHigh)!)
        }
        self.titleLabel.text = PlayerViewController.playArray![PlayerViewController.playIndex].title
        self.subtitleLabel.text = PlayerViewController.playArray![PlayerViewController.playIndex].userName
        updateButtons()
    }
    
    func playSongAt(index: Int){
        self.activityIndicator.isHidden = false
        MPNowPlayingInfoCenter.default().nowPlayingInfo =
            [MPMediaItemPropertyTitle: PlayerViewController.playArray![PlayerViewController.playIndex].title,
             MPMediaItemPropertyArtist: PlayerViewController.playArray![PlayerViewController.playIndex].userName]

        if (PlayerViewController.player != nil) {
            PlayerViewController.player!.pause()
        }
        let streamUrlSoundCloud = "\(PlayerViewController.playArray[index].stream_url)?client_id=\(AppDelegate.SOUNDCLOUD_CLIENT)"
        let playerItem = AVPlayerItem(url: URL(string: streamUrlSoundCloud)!)
        PlayerViewController.player = AVPlayer(playerItem:playerItem)
        PlayerViewController.player!.volume = 1.0
        PlayerViewController.player!.play()
        self.start()
        
        showUIForSongAt(index: PlayerViewController.playIndex)
    }
    
    func updateButtons(){
        if PlayerViewController.isPlaying() {
            self.playButton.isHidden = true
            self.pauseButton.isHidden = false
        } else {
            self.playButton.isHidden = false
            self.pauseButton.isHidden = true
        }
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        PlayerViewController.player?.play()
        self.start()
        
        updateButtons()
        
    }
    
    @IBAction func pauseButtonTapped(_ sender: UIButton) {
        
        PlayerViewController.player?.pause()
        self.stop()
        
        updateButtons()
    }
    
    @objc func userSeek(){
        let value = self.progressSlider.value
        if (PlayerViewController.player != nil && PlayerViewController.player?.currentTime() != nil) {
            PlayerViewController.player?.seek(to: CMTime(seconds: Double(value), preferredTimescale: (PlayerViewController.player?.currentTime().timescale)!))
        }
    }
    
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(PlayerViewController.updateTime), userInfo: nil, repeats: true)
    }
    
    private func stopTimer(){
        
        if(timer != nil) {
            timer.invalidate()
            timer = nil
        }
        
    }
    
    @objc func updateTime(){
        
        if (PlayerViewController.player != nil && !(PlayerViewController.player?.currentItem?.duration.seconds.isNaN)!) {
            self.progressSlider.maximumValue = Float((PlayerViewController.player?.currentItem?.duration.seconds)!)
            self.progressSlider.value = Float((PlayerViewController.player?.currentTime().seconds)!)
        }
        let totalDuration = Int(self.progressSlider.value)
        let min = totalDuration / 60
        let sec = totalDuration % 60
        
        timeView.text = NSString(format: "%i:%02i",min,sec ) as String
        updateDuration()
        
        if(self.progressSlider.value  >= self.progressSlider.maximumValue)
        {
            stopTimer()
            self.nextTapped(sender: nil)
        }
        if (self.progressSlider.value > 0.0){
            self.activityIndicator.isHidden = true
        }
        
    }
    
    func updateDuration(){
        if (self.progressSlider.maximumValue.isNaN) { return }
        
        let totalDuration = Int(self.progressSlider.maximumValue)
        let min = totalDuration / 60
        let sec = totalDuration % 60
        
        durationView.text = NSString(format: "%i:%02i",min,sec ) as String
    }
    
    /* Start timer and animation */
    @objc func start(){
        self.startTimer()
    }
    
    /* Stop timer and animation */
    func stop(){
        self.stopTimer()
    }
    
    
    @IBAction func nextTapped(sender: AnyObject?) {
        if (PlayerViewController.playIndex < PlayerViewController.playArray.count - 1) {
            PlayerViewController.playIndex = PlayerViewController.playIndex + 1
            self.playSongAt(index: PlayerViewController.playIndex)
        }
    }
    
    @IBAction func previousTapped(sender: AnyObject?) {
        if (PlayerViewController.playIndex > 0) {
            PlayerViewController.playIndex = PlayerViewController.playIndex - 1
            self.playSongAt(index: PlayerViewController.playIndex)
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
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: NSLocalizedString("audio_playing", comment: "")]
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (MPRemoteCommandHandlerStatus) -> MPRemoteCommandHandlerStatus in
            PlayerViewController.player!.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { (MPRemoteCommandHandlerStatus) -> MPRemoteCommandHandlerStatus in
            PlayerViewController.player!.pause()
            return .success
        }
    }
    

    func makeItRounded(view : UIView!, newSize : CGFloat!){
        let saveCenter : CGPoint = view.center
        let newFrame : CGRect = CGRect(x: view.frame.origin.x,y: view.frame.origin.y,width: newSize,height : newSize)
        view.frame = newFrame
        view.layer.cornerRadius = newSize / 2.0
        view.clipsToBounds = true
        view.center = saveCenter
        
    }
    
    static func isPlaying() -> Bool{
        return (PlayerViewController.player != nil) && (PlayerViewController.player!.rate != 0) && (PlayerViewController.player!.error == nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
