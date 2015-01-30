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
var apikey : String = "deEjldQkPV5fRpfyTC3L9xQpPe2VeBeS"
var url : String = "https://www.kimonolabs.com/api/1wq466c8"


protocol ConnectionProtocol {
    
}
class ConnectionManager {
    var delegate : ConnectionProtocol?
    
    // Singleton
    class var sharedInstance : ConnectionManager {
        struct Static {
            static let instance : ConnectionManager = ConnectionManager()
        }
        return Static.instance
    }
    
    class func getRedditList() {
        var subreddit = "dota2"
        let URL = "www.reddit.com/search/" + subreddit + "/hot"
        Alamofire.request(.GET, URL, parameters: ["limit":"25"])
            .responseSwiftyJSON { (request, response, responseJSON, error) in
                println(request)
                println(responseJSON["args"])
                if error != nil {
                    println(error)
                }
        }
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

}

