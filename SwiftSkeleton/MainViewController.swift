//
//  NewsViewController .swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import CoreData
import DrawerController
import MDCSwipeToChoose

class MainViewController: CenterViewController, MDCSwipeToChooseDelegate,STKAudioPlayerDelegate{
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var pausePlayButton: AnimatedStartButton!
    @IBOutlet weak var waveformView: SiriWaveformView!
    
    let settings = Singleton.sharedInstance.settings
    let pulsingLayer = PulsingLayer()
    
    
    var noMoreTracksLabel: UILabel!
    var lastTrack: ChooseTrackView!
    var frontCardView: ChooseTrackView?
    var backCardView: ChooseTrackView?
    var currentTrack: Track?
    
    var animating: Bool = false
    
    //    override func prefersStatusBarHidden() -> Bool {
    //        return true
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings.firstLaunch = true
        // Check if its the first launch
        if settings.firstLaunch == true {
            //self.presentTutorial()
        }
        //  self.presentTutorial()
        ConnectionManager.sharedInstance.delegate = self
        Singleton.sharedInstance.audioPlayer.delegate = self
        
        // Start tracking audio
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.03, target: self, selector: #selector(MainViewController.meterAudio), userInfo: nil, repeats: true)
        waveformView.layer.transform = CATransform3DMakeScale(1,0.8,1)
        
        //self.view.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.85, alpha: 1.0)
        //load ID's
        if (Singleton.sharedInstance.username != nil) {
            ConnectionManager.initializeStream(false)
        }
    }
    
    
    func meterAudio() {
        
        let normalizedValue = pow(10, singleton.audioPlayer.averagePowerInDecibelsForChannel(0) / 20) + pow(10, singleton.audioPlayer.averagePowerInDecibelsForChannel(1) / 20) - 0.002
        
        // Fade in Title
        
        if normalizedValue == 0 {
            animating = false
            titleLabel?.alpha = 0.5
            userLabel?.alpha = 0
            waveformView?.alpha = 0.2
            //pausePlayButton?.alpha = 0.7
        } else {
            if (!animating) {
                self.frontCardView?.hideLoadingAnimation()
                UIView.animateWithDuration(0.8, animations: {
                    self.titleLabel.alpha = 1
                    self.waveformView?.alpha = 1
                    self.userLabel.alpha = 1
                    
                })
                animating = true
            }
        }

        // Animate waveform according to loudness while playing
        
        if !settings.waveform {
            // If there's no waveform just make it opaque
            waveformView.hidden = true
            
            // And screw the rest of the function here
            return
        } else {
            waveformView.hidden = false
        }
        
              if pausePlayButton.selected {
            waveformView.updateWithLevel(CGFloat(normalizedValue)/2)
        } else {
            waveformView.updateWithLevel(0.01)
        }
        
        if settings.waveformInFront {
            self.view.bringSubviewToFront(waveformView)
        } else {
            self.view.sendSubviewToBack(waveformView)
        }
        // If theres a lot of stuff happening change the waveform properties
        
        if normalizedValue > 1.9 {
            waveformView.waveColor = UIColor.ht_bitterSweetDarkColor()
            // waveformView.layer.transform = CATransform3DMakeScale(1.0,0.8,1.1)
            waveformView.primaryWaveLineWidth = 5
        } else {
            waveformView.waveColor = UIColor.blackColor()
            //   waveformView.layer.transform = CATransform3DMakeScale(1,0.8,1)
            waveformView.primaryWaveLineWidth = 3
            
        }
        
    }
    
    override func viewWillDisappear(animated:Bool) {
        super.viewWillDisappear(animated)
 
        print("Center View Will Disappear")
    }
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
      
        print("Center View Will Appear")
    }
    
    // Called when app recieves the list of songs from Kevin's backend
    
    func didGetTracks() {
        // Delete all the current tracks being displayed (when being called in from SideMenu)
        self.frontCardView?.removeFromSuperview()
        self.backCardView?.removeFromSuperview()
        
        // Init Code
        SwiftSpinner.hide()
        
        // If there's no more tracks just stop and drop everything
        if Singleton.sharedInstance.tracks.count <= 1 {
            self.frontCardView = ChooseTrackView(track: Track(), frame: self.frontCardViewFrame(), options: MDCSwipeToChooseViewOptions())
            noMoreTracksLabel = UILabel(frame: self.view.bounds)
            noMoreTracksLabel.font = UIFont(name: "Futura", size: CGFloat(15))
            noMoreTracksLabel.textAlignment = .Center;
            noMoreTracksLabel.text = "Enable duplicates or wait for tomorrow!"
            
            self.view.addSubview(noMoreTracksLabel)
            //self.view.bringSubviewToFront(noMoreTracksLabel)
            
            self.titleLabel?.text = "No more tracks :("
            Singleton.sharedInstance.audioPlayer.stop()
            
            return
            
        }
        
        self.frontCardView = self.popTrackWithFrame(self.frontCardViewFrame())
        self.view.addSubview(self.frontCardView!)
        self.backCardView = self.popTrackWithFrame(self.backCardViewFrame())
        self.view.insertSubview(self.backCardView!, belowSubview: self.frontCardView!)
        
        currentTrack = self.frontCardView?.track!
        if let track = self.frontCardView?.track {
            if let nextTrack = self.backCardView?.track {
                ConnectionManager.playStreamFromTrack(track,nextTrack:nextTrack)
            }
        }
        titleLabel.text = currentTrack?.title
        userLabel.text = currentTrack?.user
        singleton.audioPlayer.pause()
        
        // Add pulse animation
        /*let pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:20, position:pausePlayButton!.center)
        pausePlayButton.layer.insertSublayer(pulseEffect, below: pausePlayButton!.layer)*/
        
        
        //pulsingLayer.position = pausePlayButton.center
        //view.layer.insertSublayer(pulsingLayer, below: pausePlayButton.layer)
        //view.addSubview(waveformView)
        
        
        // Bring buttons to front
        
        self.view.bringSubviewToFront(xButton)
        self.view.bringSubviewToFront(checkButton)
        self.view.bringSubviewToFront(pausePlayButton)
        //self.view.bringSubviewToFront(userLabel)
        //self.view.bringSubviewToFront(waveformView)
        waveformView.userInteractionEnabled = false
        xButton.adjustsImageWhenHighlighted = true
        checkButton.adjustsImageWhenHighlighted = true
        
        //Play the song
        ConnectionManager.sharedInstance.delegate?.updatePausePlayButton!(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func popTrackWithFrame(frame:CGRect) -> ChooseTrackView? {
        // Creates a new chooseTrackView from tracks, and pops that track off the list
        
        // For duplicates, what happens when we run out tracks?
        // If there's still one track remaining,
        if Singleton.sharedInstance.tracks.count < 8 && settings.stream {
            ConnectionManager.loadAndAddNextTrackToQueue()
        }
        
        if (Singleton.sharedInstance.idsArray.count < Singleton.sharedInstance.idsArrayLimit/4 || Singleton.sharedInstance.idsArrayWithoutDuplicates.count < Singleton.sharedInstance.idsArrayLimit/4) && settings.stream {
            ConnectionManager.getNextStreamTrackIds(false)
        }
        
        if Singleton.sharedInstance.tracks.count == 1 && settings.stream == false {
            print("No more tracks")
            // Return a dummy view
            return ChooseTrackView(track: Track(), frame: self.frontCardViewFrame(), options: MDCSwipeToChooseViewOptions())
        }
        
        let options = MDCSwipeToChooseViewOptions()
        options.delegate = self
       // options.likedText = "dope!"
        options.likedColor = UIColor.clearColor()
        options.nopeColor = UIColor.clearColor()
        //options.nopeText = "nah...
        options.likedText = ""
        options.nopeText = ""
        options.threshold = 160 

        
        options.onPan = { state -> Void in
            let frame = self.backCardViewFrame()
            self.backCardView?.frame = CGRectMake(frame.origin.x,
                frame.origin.y - (state.thresholdRatio * 10),
                CGRectGetWidth(frame),
                CGRectGetHeight(frame))
            
            /*if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
            } else {
            }*/
        }
        
        let view = ChooseTrackView(track:Singleton.sharedInstance.tracks.objectAtIndex(0) as! Track, frame: frame, options: options)
        
        Singleton.sharedInstance.tracks.removeObjectAtIndex(0)
        //view.imageView.image = UIImage(named: "photo.png")
        
        return view
    }
    
    // This is called when a user didn't fully swipe left or right.
    func viewDidCancelSwipe(view: UIView) -> Void{
        //println("Couldn't decide, huh?")
        
    }
    
    // Sent before a choice is made. Cancel the choice by returning `false`. Otherwise return `true`.
     func view(view: UIView, shouldBeChosenWithDirection: MDCSwipeDirection) -> Bool{
        return true
    }
    
    // This is called then a user swipes the view fully left or right.
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        
        
        currentTrack = self.frontCardView?.track!
        if wasChosenWithDirection == MDCSwipeDirection.Left {
            print("Track deleted!")
        }else{
            print("Track saved!")
            if singleton.username != nil {
                ConnectionManager.favoriteTrack(currentTrack!)
            }
            singleton.addTrackToSavedTracks(currentTrack!)
        }
        
        singleton.addTrackToPlayedTracks(currentTrack!)
        self.appearNextCard()
    }
    
    
    func appearNextCard() {
        self.frontCardView = self.backCardView
        
        
        titleLabel.text = self.frontCardView?.track?.title
        userLabel.text = self.frontCardView?.track?.user
        
        // Animate the text
        titleLabel.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        titleLabel.alpha = 0
        userLabel.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        userLabel.alpha = 0
        
        UIView.animateWithDuration(0.25, animations: {
            self.titleLabel.layer.transform = CATransform3DMakeScale(1,1,1)
            self.titleLabel.alpha = 1
            self.userLabel.layer.transform = CATransform3DMakeScale(1,1,1)
            self.userLabel.alpha = 1
            
        })
        
        // Bring the backCard up
        
        let frame = self.backCardViewFrame()
        let newFrame = CGRectMake(frame.origin.x + 15,
            frame.origin.y - 500 ,
            CGRectGetWidth(frame),
            CGRectGetHeight(frame))
        
        
        if let newBackCard = self.popTrackWithFrame(newFrame){
            self.backCardView! = newBackCard
            self.backCardView!.frame = frame
            self.backCardView!.alpha = 0
            self.view.insertSubview(self.backCardView!, belowSubview: self.frontCardView!)
            UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {()->Void in self.backCardView!.alpha = 1}
                , completion: nil)
            
        }
        
        
        // Bring Buttons to the front
        self.view.bringSubviewToFront(xButton)
        self.view.bringSubviewToFront(checkButton)
        self.view.bringSubviewToFront(pausePlayButton)
        
        pausePlayButton.selected = true
        pausePlayButton.addTransforms()
        
        // Play new song and queue next song
        if let track = self.frontCardView?.track {
            if let nextTrack = self.backCardView?.track {
                //If last track, don't play
                if Singleton.sharedInstance.tracks.count != 0 {
                    ConnectionManager.playStreamFromTrack(track,nextTrack:nextTrack)
                    
                    //Autoplay functionality
                } else {
                    //In the case that it is the last song, stop next song from playing b/c app is loading next few songs from stream
                    updatePausePlayButton(false)
                }
            }
        }
    }
    
    // View frames
    
    func frontCardViewFrame() -> CGRect {
        let horizontalPadding: CGFloat = 16
        let topPadding: CGFloat = 120
        let bottomPadding: CGFloat = 220
        return CGRectMake(horizontalPadding, topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding*2),
            CGRectGetHeight(self.view.frame) - bottomPadding)
    }
    func backCardViewFrame() -> CGRect {
        let frontFrame = self.frontCardViewFrame()
        return CGRectMake(frontFrame.origin.x,
            frontFrame.origin.y + 10,
            CGRectGetWidth(frontFrame),CGRectGetHeight(frontFrame))
    }
    
    func updatePausePlayButton(play: Bool) {
        if (play) {
            pausePlayButton.selected = true
            singleton.audioPlayer.resume()
            singleton.audioPlayer.unmute()
        } else {
            pausePlayButton.selected = false
            singleton.audioPlayer.pause()
        }
    }
    
    // Pause play function
    @IBAction func buttonPressed(sender: AnimatedStartButton) {
        sender.selected = !sender.selected
        if(sender.selected) {
            singleton.audioPlayer.resume()
            singleton.audioPlayer.unmute()
        } else {
            singleton.audioPlayer.pause()
        }
    }
    
    // Right button
    @IBAction func checkButtonPressed(sender: UIButton) {
        UIView.animateWithDuration(0.3, animations:{
            sender.alpha = 0
        })
        UIView.animateWithDuration(0.3, animations:{
            sender.alpha = 1
        })
        self.evo_drawerController?.openDrawerSide(DrawerSide.Right, animated: true, completion: nil)
        
    }
    
    // Left button
    @IBAction func xButtonPressed(sender:UIButton) {
        UIView.animateWithDuration(0.3, animations:{
            sender.alpha = 0
        })
        UIView.animateWithDuration(0.3, animations:{
            sender.alpha = 1
        })
        
        self.evo_drawerController?.openDrawerSide(DrawerSide.Left, animated: true, completion: nil)
        //self.evo_drawerController?.leftDrawerViewController? as! GenresViewController
    }
    
    
    // Audio player delegate functions
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didCancelQueuedItems queuedItems: [AnyObject]!) {
        print("Cancelled queued items")
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject!) {
        print("Finished buffering source ID: \(queueItemId)")
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didFinishPlayingQueueItemId queueItemId: NSObject!, withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
        //println(stopReason.value)
     
        // When the current song finishes play the next song
        if stopReason.rawValue == 1 {
            if settings.autoplay == true {
                
                if settings.preview == true{
                    
                    if let trackStartTime = self.frontCardView?.track?.start_time {
                        // Mute the track giving it time to skip ahead
                        Singleton.sharedInstance.audioPlayer.volume = 0
                        // Adjust the progresss if the track skipped ahead
                        
                        var adjustedProgress: Double = progress
                        
                        if settings.preview == true {
                            adjustedProgress = progress + Double(trackStartTime/1000)
                        }
                        
                        print("Progress: \(progress) adjustedProgress: \(adjustedProgress) Duration: \(duration) ")
                        if fabs(duration - adjustedProgress) < 1 {
                            // If the song ends (or almost ends, its not extremely accurate) show the next card
                            self.frontCardView?.mdc_swipe(MDCSwipeDirection.Left)
                            //self.frontCardView?.removeFromSuperview()
                            //self.appearNextCard()
                            
                        }
                    }
                } else {
                    self.frontCardView?.mdc_swipe(MDCSwipeDirection.Left)
                    //self.frontCardView?.removeFromSuperview()
                    //self.appearNextCard()
                }
            }
        }
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, didStartPlayingQueueItemId queueItemId: NSObject!) {
        
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, logInfo line: String!) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer!, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        print(STKAudioPlayerErrorCode)
    }
}