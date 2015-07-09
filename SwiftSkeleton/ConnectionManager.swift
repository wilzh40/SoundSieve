//
//  ConnectionManager.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

import OAuthSwift
import UIKit
import AVFoundation

let baseURL = "http://soundsieve-kzeng.rhcloud.com/api/"
let soundcloudURL = "http://api.soundcloud.com/"

@objc protocol ConnectionProtocol {
    optional func didGetTracks()
    optional func updatePausePlayButton(play: Bool)
}
class ConnectionManager {
    var delegate : ConnectionProtocol?
    let settings = Singleton.sharedInstance.settings
    
    
    
    
    // Authenticate SC -> Safari login -> Call back to app -> Get token -> Get username -> Save data -> reload
    
    class func authenticateSC() {
        let oauthswift = OAuth2Swift(
            consumerKey:    Soundcloud["consumerKey"]!,
            consumerSecret: Soundcloud["consumerSecret"]!,
            authorizeUrl:   "https://soundcloud.com/connect",
            responseType:   "token"
        )
        
        // The callback URL matches the one given on the soundsieve sc account
        // After the user logins Safari redirects it to "SoundSieve://" which opens the app natively
        // After successful authentication the openURL function in appDelegate is called
        oauthswift.authorizeWithCallbackURL(NSURL(string: "SoundSieve://oauth-callback")!, scope: "non-expiring", state: "", success: {
            credential, response, parameters in
            println("Soundcloud", message: "oauth_token:\(credential.oauth_token)")
            Singleton.sharedInstance.token = credential.oauth_token
            ConnectionManager.getUsername()
            
            }, failure: {(error:NSError!) -> Void in
                SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                println(error.localizedDescription)
        })
        
    }
    
    class func getUsername() {
        let URL = soundcloudURL + "me/"
        let parameters = ["oauth_token": Singleton.sharedInstance.token!]
        Alamofire.request(.GET, URL, parameters:parameters )
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                println(request)
                println(response)
                Singleton.sharedInstance.username = responseJSON["username"].string!
                Singleton.sharedInstance.saveData()
                // Either get user stream or random tracks, based on the setting
                switch (Singleton.sharedInstance.settings.trackSource) {
                case .Stream:
                    self.initializeStream()
                case .Explore:
                    self.getRandomTracks()
                    
                }
                // Update the
                Singleton.sharedInstance.settingsVC!.updateUsername()
                
                
                if error != nil {
                    println(error)
                }
            })
    }
    
    class func getRandomTracks() {
        //make a temp array of played tracks' ids
        var playedTracksArray = [Int]()
        for aTrack in Singleton.sharedInstance.playedTracks{
            let track = aTrack as! Track
            playedTracksArray.append(track.id!);
        }
        
        
        let selectedGenre = Singleton.sharedInstance.APIgenres.objectAtIndex(Singleton.sharedInstance.settings.selectedGenre) as! String
        var searchMethod:String
        /*switch (Singleton.sharedInstance.settings.selectedSearchMethod) {
        case .Hot:
        searchMethod = "hot"
        case .Random:
        searchMethod = "random"
        }*/
        
        if Singleton.sharedInstance.settings.hotness == true {
            searchMethod = "hot"
        } else {
            searchMethod = "random"
        }
        
        let URL = baseURL + searchMethod + "?genres=" + selectedGenre
        
        Alamofire.request(.GET, URL )
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                println(request)
                
                if error != nil {
                    println(error)
                    SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                    
                } else {
                    
                    //println(responseJSON)
                    var tracks: NSMutableArray = []
                    for (index: String, child: JSON) in responseJSON {
                        var track = Track()
                        track.title = child["title"].string!
                        //println(track.title)
                        track.user = child["user"]["username"].string!
                        track.id = child["id"].int!
                        track.duration = child["duration"].int
                        track.genre = child["genre"].string
                        track.subtitle = child["description"].string
                        track.artwork_url = child["artwork_url"].string
                        track.permalink_url = child["permalink_url"].string!
                        track.stream_url = child["stream_url"].string!
                        track.start_time = child["start_time"].int!
                        
                        if Singleton.sharedInstance.settings.duplicates == false {
                            // If duplicates are not allowed
                            if find(playedTracksArray, track.id!) == nil {
                                // Check if the id is in played tracks; if it isn't add it to the collection
                                tracks.addObject(track)
                            }
                            if tracks.count <= 1 {
                                // If there's no more tracks abort mission
                                //SwiftSpinner.show("Uh Oh! No more songs...", animated:false)
                                //var timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("enableDuplicates"), userInfo: nil, repeats: true)
                                
                                
                                //return
                            }
                            
                        } else {
                            tracks.addObject(track)
                        }
                        
                    }
                    Singleton.sharedInstance.tracks = tracks
                    ConnectionManager.sharedInstance.delegate?.didGetTracks!()
                }
            })
    }
    
    // Limit songs for stream
    static let limit = 100
    
    class func initializeStream () {
        //Clear array
        Singleton.sharedInstance.idsArray.removeAllObjects()
        
        //make a temp array of played tracks' ids
        var playedTracksArray = [Int]()
        for aTrack in Singleton.sharedInstance.playedTracks{
            let track = aTrack as! Track
            playedTracksArray.append(track.id!);
        }
        
        //make temp array that is a replica of idsArray to prevent the same song on stream
        var localIdsArray = [Int]()
        
        //Set number of tracks in one request
        
        //Construct Url based on whether this is the first time user stream is requested or if it is a continuation
        let URL = "https://api.soundcloud.com/me/activities?limit=" + String(limit) + "&oauth_token=" + Singleton.sharedInstance.token!
        
        //Create initial string to hold future trackIds
        
        //Request from url
        Alamofire.request(.GET, URL)
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                println(request)
                if error != nil {
                    println(error)
                    SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                    
                } else {
                    //println(responseJSON)
                    
                    //Pull song ids from response json and add them to string, seperated by commas
                    for (index: String, child: JSON) in responseJSON["collection"] {
                        if(child["origin"]["kind"].string! == "track") {
                            let id = child["origin"]["id"].int!
                            if Singleton.sharedInstance.settings.duplicates == false {
                                // If duplicates are not allowed
                                if find(playedTracksArray, id) == nil && find(localIdsArray, id) == nil {
                                    // Check if the id is in played tracks or if the id is already in idsArray if it isn't add it to the collection
                                    Singleton.sharedInstance.idsArray.addObject(id)
                                    localIdsArray.append(id)
                                }
                            } else {
                                if find(localIdsArray, id) == nil {
                                    Singleton.sharedInstance.idsArray.addObject(id)
                                    localIdsArray.append(id)
                                }
                            }
                        }
                    }
                    
                    //Grab and store next_href string for next set of songs
                    Singleton.sharedInstance.userStreamNextHrefUrl = responseJSON["next_href"].string!
                    
                    //If not enough tracks due to duplicates
                    if (Singleton.sharedInstance.idsArray.count < 100) {
                        //Grab JUST the next song
                        self.getNextStreamTrackIds()
                    } else {
                        self.loadAndAddInitialTracksInIdsArray()
                    }
                }
            })
    }
    
    //recursive fucntion to insure x amount of songs at beginning if duplicates are off
    class func getNextStreamTrackIds() {
        //example url that is passed as argument (for reference) : https://api.soundcloud.com/me/activities?limit=1&amp;cursor=41d566d9-4840-0000-63c7-80891af6f5e8
        
        let href_url = Singleton.sharedInstance.userStreamNextHrefUrl
        
        //Change the limit to 1
        let u1 = href_url!.substringToIndex(advance(href_url!.startIndex, 47)) //first half up to the first "="
        let u2 = href_url!.substringFromIndex(advance(href_url!.startIndex, 50)) // from the & to the end
        let URL = u1 + String(limit) + u2
        
        println(URL)
        
        //make a temp array of played tracks' ids
        var playedTracksArray = [Int]()
        for aTrack in Singleton.sharedInstance.playedTracks{
            let track = aTrack as! Track
            playedTracksArray.append(track.id!);
        }
        
        Alamofire.request(.GET, URL)
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                println(request)
                if error != nil {
                    println(error)
                    SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                    
                } else {
                    //println(responseJSON)
                    
                    //Grab and store next_href string for next set of songs
                    Singleton.sharedInstance.userStreamNextHrefUrl = responseJSON["next_href"].string!
                    
                    //Pull song ids from response json and add them to string, seperated by commas
                    for (index: String, child: JSON) in responseJSON["collection"] {
                        if(child["origin"]["kind"].string! == "track") {
                            let id = child["origin"]["id"].int!
                            if Singleton.sharedInstance.settings.duplicates == false {
                                // If duplicates are not allowed
                                if find(playedTracksArray, id) == nil {
                                    // Check if the id is in played tracks; if it isn't add it to the collection
                                    Singleton.sharedInstance.idsArray.addObject(id)
                                }
                            } else {
                                Singleton.sharedInstance.idsArray.addObject(id)
                            }
                        }
                    }
                    
                    //If not enough tracks due to duplicates
                    if (Singleton.sharedInstance.idsArray.count < 250) {
                        //Grab more songs
                        self.getNextStreamTrackIds()
                    } else {
                        self.loadAndAddInitialTracksInIdsArray()
                    }
                }
            })
    }
    
    class func loadAndAddInitialTracksInIdsArray() {
        //Construct trackIds String for Url
        
        var trackIds = ""
        
        let initialSongs = 8
        
        //only load initialSongs
        for var i = 0; i < initialSongs; ++i {
            var temp = Singleton.sharedInstance.idsArray.objectAtIndex(0) as! Int
            trackIds = trackIds + String(temp) + ","
            
            //remove loaded song from idsArray
            Singleton.sharedInstance.idsArray.removeObjectAtIndex(0)
        }
        
        //Fix to fencepost issue (delete additional comment at the end)
        trackIds = trackIds.substringToIndex(advance(trackIds.endIndex, -1))
        
        println(trackIds)
        
        //Construct second Url that is actually used to fetch song data for the ids and the start time
        let URL2 = "http://soundsieve-backend.appspot.com/api/track?ids=" + trackIds
        
        Alamofire.request(.GET, URL2)
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                println(request)
                
                if error != nil {
                    println(error)
                    SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                    
                } else {
                    
                    //Filling in corresponding data for track
                    var tracks: NSMutableArray = []
                    for (index: String, child: JSON) in responseJSON {
                        var track = Track()
                        track.title = child["title"].string!
                        track.user = child["user"]["username"].string!
                        //println(track.title)
                        track.id = child["id"].int!
                        track.duration = child["duration"].int
                        track.genre = child["genre"].string
                        track.subtitle = child["description"].string
                        if let s = child["artwork_url"].string {
                            var tempStr = child["artwork_url"].string
                            tempStr = tempStr!.substringToIndex(advance(tempStr!.endIndex,-9)) + "t500x500.jpg"
                            track.artwork_url = tempStr!
                        }
                        track.permalink_url = child["permalink_url"].string!
                        track.stream_url = child["stream_url"].string!
                        track.start_time = child["start_time"].int! * 1000
                        tracks.addObject(track)
                    }
                    
                    Singleton.sharedInstance.tracks = tracks
                    ConnectionManager.sharedInstance.delegate?.didGetTracks!()
                }
            })
    }
    
    class func loadAndAddNextTrackToQueue() {
        
        let temp = Singleton.sharedInstance.idsArray.objectAtIndex(0) as! Int
        
        //remove loaded song from idsArray
        Singleton.sharedInstance.idsArray.removeObjectAtIndex(0)
        
        let URL2 = "http://soundsieve-backend.appspot.com/api/track?ids=" + String(temp)
        
        Alamofire.request(.GET, URL2)
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                println(request)
                
                if error != nil {
                    println(error)
                    SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                    
                } else {
                    
                    //Filling in corresponding data for track
                    var tracks: NSMutableArray = []
                    for (index: String, child: JSON) in responseJSON {
                        var track = Track()
                        track.title = child["title"].string!
                        track.user = child["user"]["username"].string!
                        //println(track.title)
                        track.id = child["id"].int!
                        track.duration = child["duration"].int
                        track.genre = child["genre"].string
                        track.subtitle = child["description"].string
                        if let s = child["artwork_url"].string {
                            var tempStr = child["artwork_url"].string
                            tempStr = tempStr!.substringToIndex(advance(tempStr!.endIndex,-9)) + "t500x500.jpg"
                            track.artwork_url = tempStr!
                        }
                        track.permalink_url = child["permalink_url"].string!
                        track.stream_url = child["stream_url"].string!
                        track.start_time = child["start_time"].int! * 1000
                        Singleton.sharedInstance.tracks.addObject(track)
                    }
                }
            })
    }
    
    class func favoriteTrack (track: Track) {
        let URL = soundcloudURL + "me/favorites/" + String(track.id!)
        let parameters = ["oauth_token": Singleton.sharedInstance.token!]
        Alamofire.request(.PUT, URL, parameters: parameters)
            .response { (request, response, responseJSON, error) in
                println(request)
                println(response)
                
                if error != nil {
                    println(error)
                }
        }
    }
    
    
    class func unFavoriteTrack (track: Track) {
        let URL = soundcloudURL + "me/favorites/" + String(track.id!)
        if let token = Singleton.sharedInstance.token {
            let parameters = ["oauth_token": token]
            Alamofire.request(.DELETE, URL, parameters: parameters)
                .response { (request, response, responseJSON, error) in
                    println(request)
                    println(response)
                    
                    if error != nil {
                        println(error)
                    }
            }
        }
    }
    
    class func playStreamFromTrack(track:Track, nextTrack:Track) {
        
        let client_id = Soundcloud["consumerKey"]!
        let streamURL = track.stream_url + "?client_id=" + client_id + "#t=" + String(track.start_time/1000)
        var time = track.start_time/1000
        
        
        Singleton.sharedInstance.audioPlayer.play(streamURL)
        
        //Hacky way to seek to music
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            // Unmute the track giving it time to skip ahead
            Singleton.sharedInstance.audioPlayer.volume = 1
            
            // Seek ahead
            
            if Singleton.sharedInstance.settings.preview == true {
                Singleton.sharedInstance.audioPlayer.seekToTime(Double(time))
                println("Playing: \(track.title) at time: \(track.start_time/1000)")
            } else if Singleton.sharedInstance.settings.autoplay == true {
                
                // Bug fix explanation: Swiping right with autoplay enabled, preview disabled, resulted in an infinite loop. That is because if preview is enabled there already is a function to ensure it skips under the delegate function in MainViewController
                
                // self.queueStreamFromTrack(nextTrack)
            }
            
            //Autoplay functionality
            ConnectionManager.sharedInstance.delegate?.updatePausePlayButton!(Singleton.sharedInstance.settings.autoplay)
        }
        
        
    }
    
    class func queueStreamFromTrack(track:Track) {
        
        let delay = 1 * Double(NSEC_PER_SEC)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            let client_id = Soundcloud["consumerKey"]!
            let streamURL = track.stream_url + "?client_id=" + client_id + "#t=" + String(track.start_time/1000)
            var time = track.start_time/1000
            Singleton.sharedInstance.audioPlayer.queue(streamURL)
            
            println("Queued: \(Singleton.sharedInstance.audioPlayer.currentlyPlayingQueueItemId())")
            // println(Singleton.sharedInstance.audioPlayer.mostRecentlyQueuedStillPendingItem)
        }
        
    }
    
    class func testNetworking() {
        let URL = "http://httpbin.org/get"
        
        // Testting an http networking client for swift!
        Alamofire.request(.GET, URL, parameters: ["foo": "bar"])
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                //println(request)
                //println(responseJSON["args"])
                if error != nil {
                    println(error)
                }
                
            })
        
        
    }
    
    class func getImageFromURL(imageURL:String) -> UIImage? {
        let url = NSURL(string: imageURL)
        if let data = NSData(contentsOfURL: url!) {
            return UIImage(data: data)!
        } else {
            return nil
        }
    }
    
    // Singleton
    class var sharedInstance : ConnectionManager {
        struct Static {
            static let instance : ConnectionManager = ConnectionManager()
        }
        return Static.instance
    }
    
    
}

