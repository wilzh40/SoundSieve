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


let baseURL = "http://soundsieve.appspot.com/api/"

protocol ConnectionProtocol {
    
}
class ConnectionManager {
    var delegate : ConnectionProtocol?
    
   
    class func getRandomTrack (genre: String, limit: Int ) {
        let URL = baseURL + "randomTrack"

        Alamofire.request(.GET, URL, parameters: ["genre" : genre, "limit" : String(limit)])
            .responseSwiftyJSON { (request, response, responseJSON, error) in
                println(request)
                println(responseJSON)
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

