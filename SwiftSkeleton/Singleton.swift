//
//  Singleton.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//
import Foundation
import UIKit
import AVFoundation
import AVKit
import CoreData

class Singleton {
    
    // View Controllers
    var centerViewControllers: NSMutableArray = []
    var currentCenterViewController: Int = 0
    let audioPlayer:STKAudioPlayer = STKAudioPlayer()
    
    // Data 

    var tracks: NSMutableArray = []
    var savedTracksAsCoreData: [NSManagedObject] = []
    var savedTracks: NSMutableArray = []

    // Settings
    
    

    
    
     func setupData() {
        //RandomTracks
        ConnectionManager.getRandomTracks("techno", limit: 100)
        
        //VCs
         let storyBoard = UIStoryboard(name: "Main", bundle: nil)
         let mainVC = storyBoard.instantiateViewControllerWithIdentifier("Center") as UIViewController
         let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("Settings") as UIViewController
        self.centerViewControllers.addObject(mainVC)
        self.centerViewControllers.addObject(settingsVC)
        

    }
    func setupAudio() {
        var error:NSErrorPointer = nil
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: error)
        AVAudioSession.sharedInstance().setActive(true, error: error)
        
      
        audioPlayer.meteringEnabled = true
        audioPlayer.volume = 1
       // audioPlayer.play("https://api.soundcloud.com/tracks/189594894/stream?client_id=6ec16ffb5ed930fce00949be480f746b&allows_redirect=false")

        
        
        var bufferLength = 0.1

        
        

    }
    
    
    
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    

}