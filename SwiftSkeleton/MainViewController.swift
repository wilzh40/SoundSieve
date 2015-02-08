//
//  NewsViewController .swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//import MDCSwipeToChoose
class MainViewController: CenterViewController, MDCSwipeToChooseDelegate, ConnectionProtocol{
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
        
    }
    
    func didGetTracks() {
        //init code
        var options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        
        //self.populateTracks()
        tracks = Singleton.sharedInstance.tracks
        self.frontCardView = self.popTrackWithFrame(self.frontCardViewFrame())
        self.view.addSubview(self.frontCardView!)
        self.backCardView = self.popTrackWithFrame(self.backCardViewFrame())
        self.view.addSubview(self.backCardView!)
        
        self.backCardView?.alpha = 0
        
        currentTrack = self.frontCardView?.track!
        
        
        
        
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
        if let track = self.backCardView?.track {
            ConnectionManager.playStreamFromTrack(track)
        }
        
        if wasChosenWithDirection == MDCSwipeDirection.Left {
            println("Track deleted!")
        }else{
            println("Track saved!")
        }
        currentTrack = self.frontCardView?.track!
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
        
        pausePlayButton.selected = true
        pausePlayButton.addTransforms()
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
    
    func addTrackToSavedTracks(thisTrack: Track) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext)
        let track = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        //set track properties
        track.setValue(thisTrack.title, forKey: "title")
        track.setValue(thisTrack.stream_url, forKey: "link")
        
        //check for errors, if it cannot save
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        //add to savedTracks
        singleton.savedTracksAsCoreData.append(track)
        transferCoreDataTracksToSavedTracks()
    }
    
    func transferCoreDataTracksToSavedTracks() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"SavedTracks")
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            singleton.savedTracksAsCoreData = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        singleton.savedTracks = [];
        for coreTrack in singleton.savedTracksAsCoreData as [NSManagedObject]{
            var track = Track()
            track.title = coreTrack.valueForKey("title") as String
            track.stream_url = coreTrack.valueForKey("link") as String
            singleton.savedTracks.addObject(track)
        }
    }
    
    func clearSavedTracks() {
        singleton.savedTracksAsCoreData = []
    }
    
    //Pause play function
    @IBAction func buttonPressed(sender: AnimatedStartButton) {
        sender.selected = !sender.selected
        if(sender.selected) {
            singleton.audioPlayer.resume()
        } else {
            singleton.audioPlayer.pause()
        }
    }

    
    @IBAction func checkButtonPressed(sender: UIButton) {
        self.frontCardView?.mdc_swipe(MDCSwipeDirection.Right)
        for t in singleton.savedTracks {
            println(t.title!)
        }
        addTrackToSavedTracks(currentTrack!)
        Singleton.sharedInstance.delegate?.reloadData!()
        
    }

    @IBAction func xButtonPressed(sender:UIButton) {
        self.frontCardView?.mdc_swipe(MDCSwipeDirection.Left)
    }
}