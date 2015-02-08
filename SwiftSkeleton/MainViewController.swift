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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hacky part so navbar doesnt overshadow the thing
        if self.respondsToSelector(Selector("edgesForExtendedLayout")) {
            self.edgesForExtendedLayout = UIRectEdge.None
        }
        
        var options = MDCSwipeToChooseViewOptions()
        options.delegate = self
        options.likedText = "Keep"
        options.likedColor = UIColor.blueColor()
        options.nopeText = "Delete"
        options.onPan = { state -> Void in
            if state.thresholdRatio == 1 && state.direction == MDCSwipeDirection.Left {
                println("Photo deleted!")
            }
        }
        var track = Track()
        var view = ChooseTrackView(track:track, frame: self.view.bounds, options: options)
        //view.imageView.image = UIImage(named: "photo.png")
        self.view.addSubview(view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // This is called when a user didn't fully swipe left or right.
    func viewDidCancelSwipe(view: UIView) -> Void{
        println("Couldn't decide, huh?")
    }
    
    // Sent before a choice is made. Cancel the choice by returning `false`. Otherwise return `true`.
    func view(view: UIView, shouldBeChosenWithDirection: MDCSwipeDirection) -> Bool{
        if (shouldBeChosenWithDirection == MDCSwipeDirection.Left) {
            return true;
        } else {
            // Snap the view back and cancel the choice.
            UIView.animateWithDuration(0.16, animations: { () -> Void in
                view.transform = CGAffineTransformIdentity
                view.center = view.superview!.center
            })
            return false;
        }
    }
    
    // This is called then a user swipes the view fully left or right.
    func view(view: UIView, wasChosenWithDirection: MDCSwipeDirection) -> Void{
        if wasChosenWithDirection == MDCSwipeDirection.Left {
            println("Photo deleted!")
        }else{
            println("Photo saved!")
        }
    }

}