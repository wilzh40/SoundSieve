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


@objc(Settings)
class Settings: NSObject, NSCoding {
    var selectedSearchMethod : SearchMethod = .Random
    var startTime : StartTimeOptions = .StartFromPreviewTime
    var selectedGenre: Int = 0
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
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.selectedSearchMethod.rawValue, forKey: "selectedSearchMethod")
        aCoder.encodeInteger(self.startTime.rawValue, forKey: "startTime")
        aCoder.encodeInteger(self.selectedGenre, forKey: "selectedGenre")
    }

}