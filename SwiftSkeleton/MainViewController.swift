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

//import MDCSwipeToChoose
class MainViewController: CenterViewController, MDCSwipeToChooseDelegate, ConnectionProtocol{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var pausePlayButton: AnimatedStartButton!
    
    var tracks:NSMutableArray = []
    var frontCardView: ChooseTrackView?
    var backCardView: ChooseTrackView?
    var currentTrack: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConnectionManager.sharedInstance.delegate = self;
        //self.view.backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.85, alpha: 1.0)
    }
    override func viewWillDisappear(animated:Bool) {
        super.viewWillDisappear(animated)
        self.frontCardView?.userInteractionEnabled = false
    }
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        self.frontCardView?.userInteractionEnabled = true
    }
    
    // Called when app recieves the list of songs from Kevin's backend
    
    func didGetTracks() {
        // Init Code
        
        SwiftSpinner.hide()
        tracks = Singleton.sharedInstance.tracks
        
        self.frontCardView = self.popTrackWithFrame(self.frontCardViewFrame())
        self.view.addSubview(self.frontCardView!)
        self.backCardView = self.popTrackWithFrame(self.backCardViewFrame())
        self.view.insertSubview(self.backCardView!, belowSubview: self.frontCardView!)
       
        currentTrack = self.frontCardView?.track!
        if currentTrack != nil {
            ConnectionManager.playStreamFromTrack(currentTrack!)
        }
        titleLabel.text = currentTrack?.title
        singleton.audioPlayer.pause()

      
        // Bring buttons to front

       
        self.view.bringSubviewToFront(xButton)
        self.view.bringSubviewToFront(checkButton)
        self.view.bringSubviewToFront(pausePlayButton)
        
        
        //hacky part so navbar doesnt overshadow the cards
        /*if self.respondsToSelector(Selector("edgesForExtendedLayout")) {
        self.edgesForExtendedLayout = UIRectEdge.None
        }
        */
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func popTrackWithFrame(frame:CGRect) -> ChooseTrackView? {
        // Creates a new chooseTrackView from tracks, and pops that track off the list
        if self.tracks.count == 0 {
            println("No more tracks")
            return nil
        }
        
        var options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.likedText = "dope!"
        options.likedColor = UIColor.whiteColor()
        options.nopeColor = UIColor.redColor()
        options.nopeText = "nah..."
        options.threshold = 160

        options.onPan = { state -> Void in
            let frame = self.backCardViewFrame()
            self.backCardView?.frame = CGRectMake(frame.origin.x,
                frame.origin.y - (state.thresholdRatio * 10),
                CGRectGetWidth(frame),
                CGRectGetHeight(frame))
            
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
            } else {
            }
        }

        var view = ChooseTrackView(track:tracks.objectAtIndex(0) as Track, frame: frame, options: options)
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
        if let track = self.backCardView?.track {
            ConnectionManager.playStreamFromTrack(track)
        }
        currentTrack = self.frontCardView?.track!
        if wasChosenWithDirection == MDCSwipeDirection.Left {
            println("Track deleted!")
        }else{
            println("Track saved!")
            singleton.addTrackToSavedTracks(currentTrack!)
        }
        
        self.frontCardView = self.backCardView
        
        
        titleLabel.text = self.frontCardView?.track?.title
        
        // Animate the text
        titleLabel.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        titleLabel.alpha = 0
        UIView.animateWithDuration(0.25, animations: {
            self.titleLabel.layer.transform = CATransform3DMakeScale(1,1,1)
            self.titleLabel.alpha = 1
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
            UIView.animateWithDuration(0.5, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {()->Void in self.backCardView!.alpha = 1}
                , completion: nil)
            
        }
        
        // Bring Buttons to the front
        self.view.bringSubviewToFront(xButton)
        self.view.bringSubviewToFront(checkButton)
        self.view.bringSubviewToFront(pausePlayButton)
    
        pausePlayButton.selected = true
        pausePlayButton.addTransforms()
        
        
    }
    // View frames
    func frontCardViewFrame() -> CGRect {
        let horizontalPadding: CGFloat = 20
        let topPadding: CGFloat = 100
        let bottomPadding: CGFloat = 200
        return CGRectMake(horizontalPadding, topPadding,CGRectGetWidth(self.view.frame) - (horizontalPadding*2),
            CGRectGetHeight(self.view.frame) - bottomPadding)
    }
    func backCardViewFrame() -> CGRect {
        let frontFrame = self.frontCardViewFrame()
        return CGRectMake(frontFrame.origin.x,
            frontFrame.origin.y + 10,
            CGRectGetWidth(frontFrame),CGRectGetHeight(frontFrame))
        }
    
        

    // Pause play function
    @IBAction func buttonPressed(sender: AnimatedStartButton) {
        sender.selected = !sender.selected
        if(sender.selected) {
            singleton.audioPlayer.resume()
        } else {
            singleton.audioPlayer.pause()
        }
    }

    // Right button
    @IBAction func checkButtonPressed(sender: UIButton) {
        //self.frontCardView?.mdc_swipe(MDCSwipeDirection.Right)
        self.evo_drawerController?.openDrawerSide(DrawerSide.Right, animated: true, completion: nil)
    }

    // Left button
    @IBAction func xButtonPressed(sender:UIButton) {
        //self.frontCardView?.mdc_swipe(MDCSwipeDirection.Left)
        self.evo_drawerController?.openDrawerSide(DrawerSide.Left, animated: true, completion: nil)
    }
}