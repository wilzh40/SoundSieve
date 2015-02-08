//
//  ChooseSongView .swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 2/7/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation

let imageLabelWidth:Float = 42.0

class ChooseTrackView : MDCSwipeToChooseView {
    var track:Track?
    
    init(track:Track, frame:CGRect, options:MDCSwipeToChooseViewOptions) {
        self.track = track
        
        super.init(frame: frame, options: options)
        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleBottomMargin
        
        //change later
        self.imageView.image = UIImage(named: "Taylor.png")
        
        self.constructInfoView()

    }
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    
    }
    
    func constructInfoView() {
        
    }

}