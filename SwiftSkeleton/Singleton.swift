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
    let equalizerB:(Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32, Float32) = (50, 100, 200, 400, 800, 600, 2600, 16000, 0, 0, 0, 0, 0, 0 , 0, 0, 0, 0, 0, 0, 0, 0 , 0, 0 )
    let audioPlayer:STKAudioPlayer = STKAudioPlayer(options: STKAudioPlayerOptions(flushQueueOnSeek: true, enableVolumeMixer: true, equalizerBandFrequencies:(50, 100, 200, 400, 800, 600, 2600, 16000, 0, 0, 0, 0, 0, 0 , 0, 0, 0, 0, 0, 0, 0, 0 , 0, 0 ),readBufferSize: 0, bufferSizeInSeconds: 0, secondsRequiredToStartPlaying: 0, gracePeriodAfterSeekInSeconds: 0, secondsRequiredToStartPlayingAfterBufferUnderun: 0))
    
    // Data

    var tracks: NSMutableArray = []
    var savedTracksAsCoreData: [NSManagedObject] = []
    var savedTracks: NSMutableArray = []
    var genres: NSMutableArray = ["Dance & Edm","Trap","House","Ambient","Pop","Indie"]
    var APIgenres: NSMutableArray = ["dance%20&%20edm","trap","house","ambient","pop","indie"]
    var selectedGenre:Int = 0
    var selectedSearchMethod:Bool = false

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
    
    func addTrackToSavedTracks(thisTrack: Track) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext)
        let track = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        //set track properties
        track.setValue(thisTrack.title, forKey: "title")
        track.setValue(thisTrack.permalink_url, forKey: "link")
        
        //check for errors, if it cannot save
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        //add to savedTracks
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
}