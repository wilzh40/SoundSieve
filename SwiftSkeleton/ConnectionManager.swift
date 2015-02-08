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
// This is my local RESTFUL testing setup using node and express.js, as well as modular databse


let baseURL = "http://soundsieve-backend.appspot.com/api/"

protocol ConnectionProtocol {
    
}
class ConnectionManager {
    var delegate : ConnectionProtocol?
    
   
    class func getRandomTracks (genre: String, limit: Int ) {
        let URL = baseURL + "randomTrack/" + genre

        Alamofire.request(.GET, URL)
            .responseSwiftyJSON { (request, response, responseJSON, error) in
                println(request)
                var tracks: NSMutableArray = []
                for (index: String, child: JSON) in responseJSON {
                    var track = Track()
                    track.title = child["title"].string!
                    println(track.title)
                    track.id = child["id"].int!
                    track.duration = child["duration"].int!
                    track.genre = child["genre"].string!
                    track.subtitle = child["description"].string!
                    track.artwork_url = child["artwork_url"].string
                    track.permalink_url = child["permalink_url"].string!
                    track.stream_url = child["stream_url"].string!
                    track.start_time = child["start_time"].int!

                    tracks.addObject(track)


                }
                Singleton.sharedInstance.tracks = tracks
                
                
                
                if error != nil {
                    println(error)
                }
        }

    }
    
    class func getTrackStream (trackUrl:String) {
        
    }
    
    
    
    
    
    
    class func testNetworking() {
        let URL = "http://httpbin.org/get"

        // Testting an http networking client for swift!
        Alamofire.request(.GET, URL, parameters: ["foo": "bar"])
            .responseSwiftyJSON { (request, response, responseJSON, error) in
                println(request)
                println(responseJSON["args"])
                if error != nil {
                    println(error)
                }
        }
        
    }
    
    
    class func getImageFromURL(imageURL:String) -> UIImage? {
        let url = NSURL(string: imageURL)
        if let data = NSData(contentsOfURL: url!) {
            return UIImage(data: data)!
        }else {
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

