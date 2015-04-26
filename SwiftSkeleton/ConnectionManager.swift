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
import AlamofireSwiftyJSON
import OAuthSwift
import UIKit
import AVFoundation

let baseURL = "http://soundsieve-kzeng.rhcloud.com/api/"
let soundcloudURL = "http://api.soundcloud.com/"

@objc protocol ConnectionProtocol {
    optional func didGetTracks()
}
class ConnectionManager {
    var delegate : ConnectionProtocol?
    
    let settings = Singleton.sharedInstance.settings
    
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
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "SoundSieve://oauth-callback")!, scope: "non-expiring", state: "", success: {
            credential, response in
            println("Soundcloud", message: "oauth_token:\(credential.oauth_token)")
            Singleton.sharedInstance.token = credential.oauth_token

            Singleton.sharedInstance.saveData()
            // Either get user stream or random tracks, based on the setting
            switch (Singleton.sharedInstance.settings.trackSource) {
            case .Stream:
                self.getUserStream()
            case .Explore:
                self.getRandomTracks()
                
            }

            }, failure: {(error:NSError!) -> Void in
                SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                println(error.localizedDescription)
        })
        
    }
    
    class func getRandomTracks() {

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
                        track.id = child["id"].int!
                        track.duration = child["duration"].int
                        track.genre = child["genre"].string
                        track.subtitle = child["description"].string
                        track.artwork_url = child["artwork_url"].string
                        track.permalink_url = child["permalink_url"].string!
                        track.stream_url = child["stream_url"].string!
                        track.start_time = child["start_time"].int!
                        
                        tracks.addObject(track)
                    }
                    Singleton.sharedInstance.tracks = tracks
                    ConnectionManager.sharedInstance.delegate?.didGetTracks!()
                }
                

        })


    }
    
    class func getTrackStream (trackUrl:String) {
        
    }
    
    class func getUserStream () {
        let URL = "https://api.soundcloud.com/me/activities?limit=100&oauth_token=" + Singleton.sharedInstance.token!
        Alamofire.request(.GET, URL)
            .responseSwiftyJSON ({ (request, response, responseJSON, error) in
                println(request)
                if error != nil {
                    println(error)
                    SwiftSpinner.show("Failed to connect, waiting...", animated: false)
                    
                } else {
                    
                    //println(responseJSON)
                    var tracks: NSMutableArray = []
                    for (index: String, child: JSON) in responseJSON["collection"] {
                        if(child["origin"]["kind"].string! == "track") {
                            var track = Track()
                            track.title = child["origin"]["title"].string!
                            //println(track.title)
                            track.id = child["origin"]["id"].int!
                            track.duration = child["origin"]["duration"].int
                            track.genre = child["origin"]["genre"].string
                            track.subtitle = child["origin"]["description"].string
                            track.artwork_url = child["origin"]["artwork_url"].string
                            track.permalink_url = child["origin"]["permalink_url"].string!
                            track.stream_url = child["origin"]["stream_url"].string!
                            track.start_time = 0
                            tracks.addObject(track)
                        }
                    }
                    Singleton.sharedInstance.tracks = tracks
                    ConnectionManager.sharedInstance.delegate?.didGetTracks!()
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
            
            Singleton.sharedInstance.audioPlayer.seekToTime(Double(time))
            println("Playing: \(track.title) at time: \(track.start_time/1000)")
            
            if Singleton.sharedInstance.settings.autoplay == true {
                self.queueStreamFromTrack(nextTrack)
            }
            
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

