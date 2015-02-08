//
//  NewsViewController .swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
//import MDCSwipeToChoose
class MainViewController: CenterViewController, MDCSwipeToChooseDelegate {
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var xButton: UIButton!
    
    @IBOutlet weak var pausePlayButton: AnimatedStartButton!
    
    var tracks:NSMutableArray = []
    var frontCardView: ChooseTrackView?
    var backCardView: ChooseTrackView?
    var currentTrack: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
    
        
        //init code
        
        
        self.populateTracks()
        self.frontCardView = self.popTrackWithFrame(self.frontCardViewFrame())
        self.view.addSubview(self.frontCardView!)
        self.backCardView = self.popTrackWithFrame(self.backCardViewFrame())
        self.view.addSubview(self.backCardView!)
        
        self.backCardView?.alpha = 0

        
        
        
        
        //hacky part so navbar doesnt overshadow the cards
        if self.respondsToSelector(Selector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        //options
        //bring buttons to front
        self.view.bringSubviewToFront(xButton)
        self.view.bringSubviewToFront(checkButton)
        self.view.bringSubviewToFront(pausePlayButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func populateTracks() {
        for i in 0...5 {
            self.addTrack()
        }
        // Start with 5 tracks
    }
    
    func addTrack() {
        let track = Track()
        self.tracks.addObject(track)
    }
    
    func popTrackWithFrame(frame:CGRect) -> ChooseTrackView? {
        // Creates a new chooseTrackView from tracks, and pops that track off the list
        if self.tracks.count == 0 {
            println("No more tracks")
            return nil
        }
        var options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.likedText = "yas"
        options.likedColor = UIColor.whiteColor()
        options.nopeColor = UIColor.whiteColor()
        options.nopeText = "nah"
        options.onPan = { state -> Void in
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
                
            } else {
                
            }
        }
        
        var view = ChooseTrackView(track:tracks.objectAtIndex(0) as Track, frame: self.frontCardViewFrame(), options: options)
        tracks.removeObjectAtIndex(0)
        //view.imageView.image = UIImage(named: "photo.png")
        return view
    }
    
    
    // This is called when a user didn't fully swipe left or right.
    func viewDidCancelSwipe(view: UIView) -> Void{
        println("Couldn't decide, huh?")
    }
    
    // Sent before a choice is made. Cancel the choice by returning `false`. Otherwise return `true`.
    func view(view: UIView, shouldBeChosenWithDirection: MDCSwipeDirection) -> Bool{
        return true
        /*if (shouldBeChosenWithDirection == MDCSwipeDirection.Left) {
            return true;
        } else {
            // Snap the view back and cancel the choice.
            UIView.animateWithDuration(0.16, animations: { () -> Void in
                view.transform = CGAffineTransformIdentity
                view.center = view.superview!.center
            })
            return false;
        }*/
    }
    
    // This is called then a user swipes the view fully left or right.
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        
        // New song
        
        singleton.audioPlayer.queue("https://ec-media.soundcloud.com/fXy55cXpm5ax.128.mp3?f10880d39085a94a0418a7ef69b03d522cd6dfee9399eeb9a522039f6cffb63b4aaf59d35adcbcf0a635c59fe830592ee412cfa3ead70212788c30557704e7afd8133c08b4&AWSAccessKeyId=AKIAJNIGGLK7XA7YZSNQ&Expires=1423378760&Signature=EdSytuH9z%2FHN%2F%2FA3Hrc8BXyF9Og%3D#t=50", withQueueItemId: 0
        )
        singleton.audioPlayer.play("https://api.soundcloud.com/tracks/163564200/stream?client_id=6ec16ffb5ed930fce00949be480f746b&allows_redirect=false#t=50")
        
        
        if wasChosenWithDirection == MDCSwipeDirection.Left {
            println("Track deleted!")
        }else{
            println("Track saved!")
        }
        self.frontCardView = self.backCardView
        
  
        
        if let newBackCard = self.popTrackWithFrame(self.backCardViewFrame()){
            self.backCardView! = newBackCard
            self.backCardView!.alpha = 0
            self.view.insertSubview(self.backCardView!, belowSubview: self.frontCardView!)
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {()->Void in self.backCardView!.alpha = 1}
                , completion: nil)
        }
        
        //bring X, check, and playpause buttons to the front
        self.view.bringSubviewToFront(xButton)
        self.view.bringSubviewToFront(checkButton)
        self.view.bringSubviewToFront(pausePlayButton)
       /* if let self.backCardView = self.popTrackWithFrame(self.backCardViewFrame()) {
            self.backCardView?.alpha = 0
            self.view.insertSubview(self.backCardView!, belowSubview: self.frontCardView!)
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {()->Void in self.backCardView!.alpha = 1}
                , completion: nil)
        }*/
        
    }
    // View frames
    func frontCardViewFrame() -> CGRect {
        let horizontalPadding: CGFloat = 25
        let topPadding: CGFloat = 60
        let bottomPadding: CGFloat = 200
        return CGRectMake(horizontalPadding, topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding),
            CGRectGetHeight(self.view.frame) - bottomPadding)
    }
    func backCardViewFrame() -> CGRect {
        let frontFrame = self.frontCardViewFrame()
        return CGRectMake(frontFrame.origin.x,
            frontFrame.origin.y + 10,
            CGRectGetWidth(frontFrame),CGRectGetHeight(frontFrame))
        }
    
    @IBAction func buttonPressed(sender: AnimatedStartButton) {
        sender.selected = !sender.selected
    }
}