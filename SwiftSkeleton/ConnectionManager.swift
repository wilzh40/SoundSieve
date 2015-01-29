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
    class func testNetworking() {
        
        // Testting an http networking client for swift!
        Alamofire.request(.GET, url)
            .responseSwiftyJSON() { (request, response, data, error) in
                println(request)
                println(response)
                
                if error != nil {
                    println(error)
                }
        }
        
    }

}

