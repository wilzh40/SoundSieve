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
enum SoundSieveOptions {
    case startFromPreviewTime
    case startFromBeginning
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
   

    // Settings (first run)
    var token: String?
    var genres: NSMutableArray = ["Dance & Edm","Trap","House","Ambient","Pop","Indie"]
    var APIgenres: NSMutableArray = ["dance%20&%20edm","trap","house","ambient","pop","indie"]
    var selectedGenre: Int = 0
    var selectedSearchMethod: Bool = false
    var startTime = SoundSieveOptions.startFromPreviewTime
    
    
     func setupData() {
        // Load Settings from NSUserDefaults (after first run)
        selectedGenre = NSUserDefaults.standardUserDefaults().integerForKey("selectedGenre")
        selectedSearchMethod = NSUserDefaults.standardUserDefaults().boolForKey("selectedSearchMethod")
        token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
        // Get the initial track list
        ConnectionManager.getRandomTracks()
    }
    
    func saveData() {
        // Called by App Delegate when it is terminated
        NSUserDefaults.standardUserDefaults().setInteger(selectedGenre, forKey: "selectedGenre")
        NSUserDefaults.standardUserDefaults().setBool(selectedSearchMethod, forKey: "selectedSearchMethod")
        
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
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext)
        let track = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        // Set track properties
        track.setValue(thisTrack.title, forKey: "title")
        track.setValue(thisTrack.permalink_url, forKey: "link")
        
        // Check for errors, if it cannot save
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }

        // Add to savedTracks
        self.savedTracksAsCoreData.append(track)
        self.transferCoreDataTracksToSavedTracks()
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
            self.savedTracksAsCoreData = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        self.savedTracks = [];
        for coreTrack in self.savedTracksAsCoreData as [NSManagedObject]{
            var track = Track()
            track.title = coreTrack.valueForKey("title") as String
            track.permalink_url = coreTrack.valueForKey("link") as String
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
    
    func deleteSavedTrackAtIndex(index:Int) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext)
        managedContext.deleteObject(self.savedTracksAsCoreData[index])
        var error:NSError?
        managedContext.save(&error)
        if (error != nil) {
            println(error)
        }
        transferCoreDataTracksToSavedTracks()
        self.delegate?.reloadData!()
    }
}