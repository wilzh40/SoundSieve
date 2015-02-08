//
//  Model.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/29/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation



class Track: NSObject {
    
    // Mandatory Variables
    var title: String
    var id: Int
    var duration: Int
    var stream_url: String
    var permalink_url: String
    
    // Optional Variables (could be nil if not there)
    var genre: String?
    var subtitle: String?
    var artwork_url: String?
    
    override init() {
        self.title = "ExampleTitle"
        self.id = 0
        self.duration = 0
        self.stream_url = "exampleUrl"
        self.permalink_url = "exampleUrl"
        self.artwork_url = "http://indie-france.olympe.in/apps/images/soundcloud.png"
    }
}


