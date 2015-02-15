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
import UIKit
import AVFoundation
// This is my local RESTFUL testing setup using node and express.js, as well as modular databse


let baseURL = "http://soundsieve-backend.appspot.com/api/"

@objc protocol ConnectionProtocol {
    optional func didGetTracks()
}
class ConnectionManager {
    var delegate : ConnectionProtocol?

    class func getRandomTracks () {
        let selectedGenre = Singleton.sharedInstance.APIgenres.objectAtIndex(Singleton.sharedInstance.selectedGenre) as String
        var hot = ""
        if Singleton.sharedInstance.selectedSearchMethod == true {
            hot = "/hot"
        }
        let URL = baseURL + "randomTrack/" + selectedGenre 

        Alamofire.request(.GET, URL)
            .responseSwiftyJSON { (request, response, responseJSON, error) in
                println(request)
                //println(responseJSON)
                var tracks: NSMutableArray = []
                for (index: String, child: JSON) in responseJSON {
                    var track = Track()
                    track.title = child["title"].string!
                    //println(track.title)
                    track.id = child["id"].int!
                    track.duration = child["duration"].int!
                    track.genre = child["genre"].string!
                    track.subtitle = child["description"].string
                    track.artwork_url = child["artwork_url"].string
                    track.permalink_url = child["permalink_url"].string!
                    track.stream_url = child["stream_url"].string!
                    track.start_time = child["start_time"].int!

                    tracks.addObject(track)


                }
                
                Singleton.sharedInstance.tracks = tracks
                ConnectionManager.sharedInstance.delegate?.didGetTracks!()
                
                if error != nil {
                    println(error)
                }
        }

    }
    
    class func getTrackStream (trackUrl:String) {
        
    }
    
    
    class func playStreamFromTrack(track:Track, nextTrack:Track) {

        let client_id = "6ec16ffb5ed930fce00949be480f746b"
        let streamURL = track.stream_url + "?client_id=" + client_id + "#t=" + String(track.start_time/1000)
        var time = track.start_time/1000
        
    
        Singleton.sharedInstance.audioPlayer.play(streamURL)

        //Hacky way to seek to music
        let delay = 0.2 * Double(NSEC_PER_SEC)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            
            Singleton.sharedInstance.audioPlayer.seekToTime(Double(time))
            println("Playing: \(track.title) at time: \(track.start_time/1000)")
            self.queueStreamFromTrack(nextTrack)

        }

        
    }
    
    class func queueStreamFromTrack(track:Track) {
        let delay = 1 * Double(NSEC_PER_SEC)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(delayTime, dispatch_get_main_queue()) {

            let client_id = "6ec16ffb5ed930fce00949be480f746b"
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
            .responseSwiftyJSON { (request, response, responseJSON, error) in
                //println(request)
                //println(responseJSON["args"])
                if error != nil {
                    println(error)
                }
        }
    
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

