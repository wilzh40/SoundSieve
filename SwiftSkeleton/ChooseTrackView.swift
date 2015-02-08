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
    
    var infoView:UIView?

    
    init(track:Track, frame:CGRect, options:MDCSwipeToChooseViewOptions) {
        self.track = track
        
        super.init(frame: frame, options: options)
        self.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleBottomMargin
        
        self.imageView.image = ConnectionManager.getImageFromURL(track.artwork_url!)
       
        self.constructInfoView()
    
        self.constructNameLabel()

    }
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    
    }
    
    func constructNameLabel() {
       var leftPadding:CGFloat = 12
        var topPadding:CGFloat = 17
        frame = CGRectMake(leftPadding,
           topPadding,
            CGRectGetWidth(self.frame),
            CGRectGetHeight(self.frame) - topPadding)
        let nameLabel = UILabel(frame: frame)
        nameLabel.text = track?.title
        self.addSubview(nameLabel)
    
        
    }
    
    
    func constructInfoView() {
        var bottomHeight: CGFloat = 60
        var bottomFrame = CGRectMake(0,
            CGRectGetHeight(self.bounds) - bottomHeight,
            CGRectGetWidth(self.bounds),
            bottomHeight)
        infoView = UIView(frame: bottomFrame)
        infoView?.backgroundColor = UIColor.whiteColor()
        infoView?.clipsToBounds = true
        infoView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth | .FlexibleTopMargin
        self.addSubview(infoView!)
    }

}