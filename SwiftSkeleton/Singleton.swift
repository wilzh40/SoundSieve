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
         let newsVC = storyBoard.instantiateViewControllerWithIdentifier("Center") as UIViewController
         let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("Settings") as UIViewController
        self.centerViewControllers.addObject(newsVC)
        self.centerViewControllers.addObject(settingsVC)


        

    }
    
    
    
    
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    

}