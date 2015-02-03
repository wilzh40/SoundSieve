//
//  Singleton.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//
import Foundation
import UIKit
class Singleton {
    
    // View Controllers
    var centerViewControllers:NSMutableArray = []

    
    


    
     func setupData() {
         let storyBoard = UIStoryboard(name: "Main", bundle: nil)
         let newsViewController = storyBoard.instantiateViewControllerWithIdentifier("Center") as NewsViewController
         let settingsViewController = storyBoard.instantiateViewControllerWithIdentifier("Settings") as SettingsViewController
        self.centerViewControllers.addObject(newsViewController)
        self.centerViewControllers.addObject(settingsViewController)


        

    }
    
    
    
    
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    

}