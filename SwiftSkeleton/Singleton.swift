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

@objc protocol SavedSongsDelegate {
    optional func reloadData()
}


class Singleton {
    var delegate: SavedSongsDelegate?
    // View Controllers
    var centerViewControllers: NSMutableArray = []
    var currentCenterViewController: Int = 0
    let audioPlayer:STKAudioPlayer = STKAudioPlayer()
    
    // Data 

    var tracks: NSMutableArray = []
    var savedTracksAsCoreData: [NSManagedObject] = []
    var savedTracks: NSMutableArray = []
    var genres: NSMutableArray = ["dance","trap","rap","house","ambient"]
    var selectedGenre:Int = 0

    // Settings
    
    

    
    
     func setupData() {
        //RandomTracks
        ConnectionManager.getRandomTracks("dance%20&%20edm", limit: 100)
        
        //VCs
        /* let storyBoard = UIStoryboard(name: "Main", bundle: nil)
         let mainVC = storyBoard.instantiateViewControllerWithIdentifier("Center") as UIViewController
         let settingsVC = storyBoard.instantiateViewControllerWithIdentifier("Settings") as UIViewController
        self.centerViewControllers.addObject(mainVC)
        self.centerViewControllers.addObject(settingsVC) */
        

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
    
    func clearSavedTracks() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext)
        var count = savedTracksAsCoreData.count
        for var i = 0; i < count; i++ {
            managedContext.deleteObject(self.savedTracksAsCoreData[0])
            savedTracksAsCoreData.removeAtIndex(0)
        }
        managedContext.save(nil)
        self.savedTracksAsCoreData = []
        self.savedTracks = []
        self.delegate?.reloadData!()
    }
}