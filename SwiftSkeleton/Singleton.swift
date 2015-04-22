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
    
    // Audio Player
    let equalizerB:(Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32) = (50, 100, 200, 400, 800, 600, 2600, 16000, 0, 0, 0, 0, 0, 0 , 0, 0, 0, 0, 0, 0, 0, 0 , 0, 0 )
    let audioPlayer:STKAudioPlayer = STKAudioPlayer(options: STKAudioPlayerOptions(flushQueueOnSeek: false, enableVolumeMixer: true, equalizerBandFrequencies:(50, 100, 200, 400, 800, 600, 2600, 16000, 0, 0, 0, 0, 0, 0 , 0, 0, 0, 0, 0, 0, 0, 0 , 0, 0 ),readBufferSize: 0, bufferSizeInSeconds: 0, secondsRequiredToStartPlaying: 0.1, gracePeriodAfterSeekInSeconds: 0, secondsRequiredToStartPlayingAfterBufferUnderun: 0))
    
    // Data

    var tracks: NSMutableArray = []
    var savedTracksAsCoreData: Array<NSManagedObject> = []
    var savedTracks: NSMutableArray = []

  
    

    // Settings
    var settings: Settings = Settings()
    var token: String?
    var genres: NSMutableArray = ["Dance & Edm","Trap","House","Ambient","Pop","Indie"]
    var APIgenres: NSMutableArray = ["dance%20&%20edm","trap","house","ambient","pop","indie"]
    
    /*
    var selectedSearchMethod : SearchMethod = .Random {
        didSet {
            if selectedSearchMethod != oldValue {
                switch selectedSearchMethod {
                case .Random :
                case .Hot:
                }
            }
        }
    }*/
    
    // Core Data
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var managedContext: NSManagedObjectContext?
    var entity: NSEntityDescription?

    
     func setupData() {
        
        //Core Data shit
        self.managedContext = appDelegate.managedObjectContext!
        self.entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext!)
        
        
        // Load Settings from NSUserDefaults (after first run)
        if let data: NSData = NSUserDefaults.standardUserDefaults().objectForKey("settings") as? NSData
        {
            self.settings = NSKeyedUnarchiver.unarchiveObjectWithData(data) as Settings
        } else {
            self.settings = Settings()
        }
        token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
        // Get the initial track list
        //ConnectionManager.getRandomTracks()
    }
    
    func saveData() {
        // Called by App Delegate when it is terminated
        // Converting the object into NSData
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(self.settings), forKey: "settings")
        
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
        
    }
    
    func setupAudio() {
        var error: NSErrorPointer = nil
        var bufferLength: NSTimeInterval = 0.1

        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: error)
        AVAudioSession.sharedInstance().setActive(true, error: error)
        AVAudioSession.sharedInstance().setPreferredIOBufferDuration(bufferLength, error:error)

        audioPlayer.meteringEnabled = true
        audioPlayer.volume = 1
        audioPlayer.equalizerEnabled = true

      
    }
    
    func addTrackToSavedTracks(thisTrack: Track) {
        let track = NSManagedObject(entity: self.entity!, insertIntoManagedObjectContext: managedContext)
        
        // Set track properties
        track.setValue(thisTrack.title, forKey: "title")
        track.setValue(thisTrack.permalink_url, forKey: "link")
        track.setValue(thisTrack.artwork_url, forKey: "artwork_url")
        
        // Check for errors, if it cannot save
        var error: NSError?
        if !self.managedContext!.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }

        // Add to savedTracks
        self.savedTracksAsCoreData.append(track)
        self.transferCoreDataTracksToSavedTracks()
    }

    
    func transferCoreDataTracksToSavedTracks() {
        let fetchRequest = NSFetchRequest(entityName:"SavedTracks")
        var error: NSError?
        
        let fetchedResults =
        self.managedContext!.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            self.savedTracksAsCoreData = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        self.savedTracks = [];
        for coreTrack in self.savedTracksAsCoreData as [NSManagedObject]{
            var track = Track()
            track.title = coreTrack.valueForKey("title") as String
            track.permalink_url = coreTrack.valueForKey("link") as String
            track.artwork_url = coreTrack.valueForKey("artwork_url") as? String
            self.savedTracks.addObject(track)
        }
    }
    
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    
    func clearSavedTracks() {
        var count = savedTracksAsCoreData.count
        for var i = 0; i < count; i++ {
            self.managedContext!.deleteObject(self.savedTracksAsCoreData[0])
            savedTracksAsCoreData.removeAtIndex(0)
        }
        self.managedContext!.save(nil)
        self.savedTracksAsCoreData = []
        self.savedTracks = []
        self.delegate?.reloadData!()
    }
    
    func deleteSavedTrackAtIndex(index:Int) {
        self.managedContext!.deleteObject(self.savedTracksAsCoreData[index])
        var error:NSError?
        self.managedContext!.save(&error)
        if (error != nil) {
            println(error)
        }
        
        self.savedTracksAsCoreData.removeAtIndex(index)
        self.savedTracks.removeObjectAtIndex(index)
    }
}