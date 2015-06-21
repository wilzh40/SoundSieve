//
//  Settings.swift
//  SoundSieve
//
//  Created by Wilson Zhao on 4/3/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation

// Setting Enums
enum SearchMethod: Int {
    case Random, Hot
}

enum StartTimeOptions: Int {
    case StartFromPreviewTime, StartFromBeginning
}

enum TrackSource: Int {
    case Explore, Stream
}


@objc(Settings)
class Settings: NSObject, NSCoding {
    var selectedSearchMethod : SearchMethod = .Random
    var startTime : StartTimeOptions = .StartFromPreviewTime
    var selectedGenre: Int = 0
    var genre: NSString = "Trap"

    
    // Bools

    var trackSource: TrackSource = .Explore
    var autoplay: Bool  = true
    var duplicates: Bool = true
    var hotness: Bool = false
    var preview: Bool = true
    var waveform: Bool = true
    var firstLaunch: Bool = true

   /* override init() {
        var selectedSearchMethod : SearchMethod = .Random
        var startTime : StartTimeOptions = .StartFromPreviewTime
        var selectedGenre: Int = 0
    }*/
    override init() {
        
    }
    required init(coder aDecoder: NSCoder) {
        self.selectedSearchMethod = SearchMethod(rawValue: aDecoder.decodeIntegerForKey("selectedSearchMethod"))!
        self.startTime = StartTimeOptions(rawValue: aDecoder.decodeIntegerForKey("startTime"))!
        self.selectedGenre = aDecoder.decodeIntegerForKey("selectedGenre")
        self.trackSource = TrackSource(rawValue: aDecoder.decodeIntegerForKey("trackSource"))!
        
        //self.genre = aDecoder.decodeObjectForKey("genre") as! NSString
        
        self.autoplay = aDecoder.decodeBoolForKey("autoplay")
        self.duplicates = aDecoder.decodeBoolForKey("duplicates")
        self.hotness = aDecoder.decodeBoolForKey("hotness")
        self.preview = aDecoder.decodeBoolForKey("preview")
        self.waveform = aDecoder.decodeBoolForKey("waveform")
        self.firstLaunch = aDecoder.decodeBoolForKey("firstLaunch")

        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.selectedSearchMethod.rawValue, forKey: "selectedSearchMethod")
        aCoder.encodeInteger(self.startTime.rawValue, forKey: "startTime")
        aCoder.encodeInteger(self.selectedGenre, forKey: "selectedGenre")
        aCoder.encodeInteger(self.trackSource.rawValue, forKey: "trackSource")
        
        //aCoder.encodeObject(self.genre, forKey: "genre")
        
        aCoder.encodeBool(self.autoplay, forKey: "autoplay")
        aCoder.encodeBool(self.duplicates, forKey: "duplicates")
        aCoder.encodeBool(self.hotness, forKey: "hotness")
        aCoder.encodeBool(self.preview, forKey: "preview")
        aCoder.encodeBool(self.waveform, forKey: "waveform")
        aCoder.encodeBool(self.firstLaunch, forKey: "firstLaunch")
}
}

