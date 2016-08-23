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
    var playedTracksAsCoreData: Array<NSManagedObject> = []
    var playedTracks: NSMutableArray = []

    // Refs to VCS
    
    var settingsVC: SettingsViewController?
    var savedSongsVC: SavedSongsViewController?
  
    

    // Settings
    var settings: Settings = Settings()
    var token: String?
    var username: String?
    var genres: NSMutableArray = ["Dance & Edm","Trap","Hip Hop and Rap","House","Ambient","Pop","Indie"]
    var APIgenres: NSMutableArray = ["dance%20%26%20edm","trap","hip%20hop%20%26%20rap","house","ambient","pop","indie"]
    
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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var managedContext: NSManagedObjectContext?
    var entity: NSEntityDescription?
    
    //User Stream Stuff
    var userStreamNextHrefUrl:String?
    var idsArray: NSMutableArray = []
    var idsArrayWithoutDuplicates: NSMutableArray = []
    var nextTrackIdToBeBuffered: Int?
    var streamIsBuffering: Bool = false
    var idsArrayLimit:Int = 100
    var idsArrayIndex:Int = 0

    func visualize() {
        
    }
    
     func setupData() {
        //Core Data shit
        self.managedContext = appDelegate.managedObjectContext!
        self.entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext!)
        
        
        // Load Settings from NSUserDefaults (after first run)
        if let data: NSData = NSUserDefaults.standardUserDefaults().objectForKey("settings") as? NSData
        {
            self.settings = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Settings
        } else {
            self.settings = Settings()
        }
        self.token = NSUserDefaults.standardUserDefaults().objectForKey("token") as? String
        self.username = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        //self.settings.trackSource = .Stream
        // Get the initial track list
        // ConnectionManager.getRandomTracks()
    }
    
    func saveData() {
        // Called by App Delegate when it is terminated
        // Converting the object into NSData
        NSUserDefaults.standardUserDefaults().setObject(NSKeyedArchiver.archivedDataWithRootObject(self.settings), forKey: "settings")
        
        NSUserDefaults.standardUserDefaults().setValue(token, forKey: "token")
        NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")

        
    }
    
    func setupAudio() {
        let error: NSErrorPointer = nil
        let bufferLength: NSTimeInterval = 0.1

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error1 as NSError {
            error.memory = error1
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error1 as NSError {
            error.memory = error1
        }
        do {
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(bufferLength)
        } catch let error1 as NSError {
            error.memory = error1
        }

        audioPlayer.meteringEnabled = true
        audioPlayer.volume = 1
        audioPlayer.equalizerEnabled = true
        print(audioPlayer.frameFilters)
        
      
        // Every 0.3 seconds we monitor the levels of the audio
        
        //var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "meterAudio", userInfo: nil, repeats: true)
     

      
    }
    
 
    func addTrackToPlayedTracks(thisTrack: Track) {
        self.entity = NSEntityDescription.entityForName("PlayedTracks", inManagedObjectContext: managedContext!)
        let track = NSManagedObject(entity: self.entity!, insertIntoManagedObjectContext: managedContext)
        
        // Set track properties
        track.setValue(thisTrack.id, forKey: "id")
        
        // Check for errors, if it cannot savetr
        var error: NSError?
        do {
            try self.managedContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }
        
        // Add to playedTracks
        self.playedTracksAsCoreData.append(track)
        self.transferCoreDataTracksToPlayedTracks()
    }
    
    func addTrackToSavedTracks(thisTrack: Track) {
        self.entity = NSEntityDescription.entityForName("SavedTracks", inManagedObjectContext: managedContext!)
        let track = NSManagedObject(entity: self.entity!, insertIntoManagedObjectContext: managedContext)
        
        // Set track properties
        track.setValue(thisTrack.title, forKey: "title")
        track.setValue(thisTrack.permalink_url, forKey: "link")
        track.setValue(thisTrack.artwork_url, forKey: "artwork_url")
        track.setValue(thisTrack.id, forKey: "id");
        track.setValue(thisTrack.user, forKey: "user")
    
        // Check for errors, if it cannot save
        var error: NSError?
        do {
            try self.managedContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Could not save \(error), \(error?.userInfo)")
        }

        // Add to savedTracks
        self.savedTracksAsCoreData.append(track)
        self.transferCoreDataTracksToSavedTracks()
    }

    func transferCoreDataTracksToPlayedTracks() {
        let fetchRequest = NSFetchRequest(entityName:"PlayedTracks")
        
        do {
            
            self.playedTracksAsCoreData = try self.managedContext!.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            self.playedTracks = [];
            for coreTrack in self.playedTracksAsCoreData as [NSManagedObject]{
                let track = Track()
                track.id = coreTrack.valueForKey("id") as? Int
                self.playedTracks.addObject(track)
            }
        }
        catch {
            
        }
    }
    
    func transferCoreDataTracksToSavedTracks() {
        let fetchRequest = NSFetchRequest(entityName:"SavedTracks")
        do {
            self.savedTracksAsCoreData = try self.managedContext!.executeFetchRequest(fetchRequest) as! [NSManagedObject];
            
            self.savedTracks = [];
            for coreTrack in self.savedTracksAsCoreData as [NSManagedObject]{
                let track = Track()
                track.title = coreTrack.valueForKey("title") as! String
                track.permalink_url = coreTrack.valueForKey("link")as! String
                track.artwork_url = coreTrack.valueForKey("artwork_url") as? String
                track.id = coreTrack.valueForKey("id") as? Int
                self.savedTracks.addObject(track)
            }
            
        }
        catch {
            //print("Could not fetch \(error), \(error.userInfo)")
            
        }

    }
    
    class var sharedInstance : Singleton {
        struct Static {
            static let instance : Singleton = Singleton()
        }
        return Static.instance
    }
    
    func clearSavedTracks() {
        let count = savedTracksAsCoreData.count
        for i in 0 ..< count {
            self.managedContext!.deleteObject(self.savedTracksAsCoreData[0])
            savedTracksAsCoreData.removeAtIndex(0)
        }
        do {
            try self.managedContext!.save()
        } catch _ {
        }
        self.savedTracksAsCoreData = []
        self.savedTracks = []
        self.delegate?.reloadData!()
    }
    
    func deleteSavedTrackAtIndex(index:Int) {
        self.managedContext!.deleteObject(self.savedTracksAsCoreData[index])
        var error:NSError?
        do {
            try self.managedContext!.save()
        } catch let error1 as NSError {
            error = error1
        }
        if (error != nil) {
            print(error)
        }
        
        self.savedTracksAsCoreData.removeAtIndex(index)
        self.savedTracks.removeObjectAtIndex(index)
    }
}