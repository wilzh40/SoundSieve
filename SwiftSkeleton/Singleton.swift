//
//  Singleton.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//
import Foundation
import UIKit
import CoreData

class Singleton {
    
    // View Controllers
    var centerViewControllers: NSMutableArray = []
    var currentCenterViewController: Int = 0
    
    // Data 
    var savedTracksAsCoreData: [NSManagedObject] = []
    var savedTracks: NSMutableArray = []

    // Settings
    
    


    
     func setupData() {
         let storyBoard = UIStoryboard(name: "Main", bundle: nil)
         let mainVC = storyBoard.instantiateViewControllerWithIdentifier("Center") as UIViewController
         let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("Settings") as UIViewController
        self.centerViewControllers.addObject(mainVC)
        self.centerViewControllers.addObject(settingsVC)
        

    }
    
    
    
    
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    

}