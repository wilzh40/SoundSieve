//
//  WalkthroughViewController .swift
//  SoundSieve
//
//  Created by Wilson Zhao on 6/6/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
import DrawerController


class WalkthroughViewController: UIViewController {
    var window: UIWindow?
    var rmpvc: RMParallax?
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        var button   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        button.frame = CGRectMake(100, 100, 50, 50)
        button.backgroundColor = UIColor.greenColor()
        button.setTitle("Button", forState: UIControlState.Normal)
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(button) */
        
        
        let item1 = RMParallaxItem(image: UIImage(named: "Tut1")!, text: "BASICALLY TINDER FOR SOUNDCLOUD® (SWIPE FOR MORE INFO)")
        let item5 = RMParallaxItem(image: UIImage(named: "Tut5")!, text: "PREVIEW THE BEST PART OF THE SONG (BASED ON COMMENT DENSITY)")
        let item2 = RMParallaxItem(image: UIImage(named: "Tut2")!, text: "SWIPE LEFT TO SKIP THE SONG")
        let item3 = RMParallaxItem(image: UIImage(named: "Tut3")!, text: "SWIPE RIGHT IF YOU THINK ITS DOPE")
        let item4 = RMParallaxItem(image: UIImage(named: "Tut4")!, text: "(AND FAV IT IF YOU LINKED YOUR SOUNDCLOUD ACCOUNT)")
        
        
        let rmpvc = RMParallax(items: [item1, item5, item2, item3, item4], motion: false)
        
        rmpvc.completionHandler = {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                rmpvc.view.alpha = 0.0
                
                self.loadApp()
                Singleton.sharedInstance.settings.firstLaunch = false
            })
            
        }
        
        // Adding parallax view controller.
        self.addChildViewController(rmpvc)
        self.view.addSubview(rmpvc.view)
        rmpvc.didMoveToParentViewController(self)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func buttonAction(sender:UIButton!) {
        
        
    }
    func loadApp() {
        
        Singleton.sharedInstance.setupData()
        Singleton.sharedInstance.setupAudio()
        Singleton.sharedInstance.transferCoreDataTracksToSavedTracks()
        Singleton.sharedInstance.transferCoreDataTracksToPlayedTracks()
        
        
        
        // Connect to soundcloud to get OAuth Token if the user hasn't already
        
//        if Singleton.sharedInstance.token == nil {
//            ConnectionManager.authenticateSC()
//        } else {
//            // Load the lists of tracks
//            switch (Singleton.sharedInstance.settings.trackSource) {
//            case .Stream:
//                ConnectionManager.getUserStream()
//            case .Explore:
//                ConnectionManager.getRandomTracks()
//                
//            }
//        }
        
        switch (Singleton.sharedInstance.settings.trackSource) {
            case .Stream:
                ConnectionManager.getUserStream(true)
            case .Explore:
                ConnectionManager.getRandomTracks()
        }
        // Connect to soundcloud to get OAuth Token if the user hasn't already
        /* if Singleton.sharedInstance.token == nil {
        ConnectionManager.authenticateSC()
        }*/
        
        
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        var centerController = storyBoard.instantiateViewControllerWithIdentifier("Center") as! UIViewController
        
        
        var left = UINavigationController(rootViewController:SettingsViewController())
        var right = UINavigationController(rootViewController:SavedSongsViewController())
        
        
       
        // Singleton.sharedInstance.settingsVC = left.childViewControllers[0] as? SettingsViewController
        // Singleton.sharedInstance.savedSongsVC = right.childViewControllers[0] as? SavedSongsViewController
        
        left.view.layoutSubviews()
        right.view.layoutSubviews()
        Singleton.sharedInstance.settingsVC?.updateUsername()
        
        
        
        // var left = storyBoard.instantiateViewControllerWithIdentifier("Left") as! UIViewController
        // var right = storyBoard.instantiateViewControllerWithIdentifier("Right")as! UIViewController
        
        var drawerCon = DrawerController(centerViewController: centerController, leftDrawerViewController: left, rightDrawerViewController:right)
        drawerCon.openDrawerGestureModeMask = OpenDrawerGestureMode.BezelPanningCenterView
        drawerCon.closeDrawerGestureModeMask = CloseDrawerGestureMode.PanningCenterView
        
         // Add the refs for singleton
        
        Singleton.sharedInstance.settingsVC = (drawerCon.leftDrawerViewController?.childViewControllers[0] as! SettingsViewController)
        Singleton.sharedInstance.savedSongsVC = (drawerCon.rightDrawerViewController?.childViewControllers[0] as! SavedSongsViewController)
        Singleton.sharedInstance.settingsVC!.updateUsername()
        
        // self.window?.rootViewController = drawerCon
        // self.window?.makeKeyAndVisible()
        self.presentViewController(drawerCon, animated: false, completion: nil)
        
        SwiftSpinner.show("Initializing...")
        
    }
}
