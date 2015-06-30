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
        ImageLoader.sharedLoader.imageForUrl(track.artwork_url!, completionHandler:{(image: UIImage?, url: String) in
            self.imageView!.image = image
            self.imageView!.alpha = 0
            UIView.animateWithDuration(0.3, animations:{
                self.imageView!.alpha = 1
            })
        })

        

       
        //self.constructInfoView()

       // self.constructNameLabel()
      //  self.addBackground()

    }
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    
    }
    
    func constructNameLabel() {
       var leftPadding:CGFloat = 12
        var topPadding:CGFloat = 50
        frame = CGRectMake(leftPadding,
           topPadding,
            CGRectGetWidth(self.bounds),
            CGRectGetHeight(self.bounds) - topPadding)
        let nameLabel = UILabel(frame: frame)
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 20)
        nameLabel.text = track?.title
        self.addSubview(nameLabel)
        
        
    }
    
    func addBackground() {
        self.layer.borderColor = UIColor.grayColor().CGColor!
        self.layer.shadowColor = UIColor.blackColor().CGColor!
        //self.backgroundColor = UIColor.blackColor()
        var gradientMaskLayer:CAGradientLayer = CAGradientLayer()
        gradientMaskLayer.frame = self.bounds
        gradientMaskLayer.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor,UIColor.blackColor().CGColor,UIColor.clearColor().CGColor]

        gradientMaskLayer.locations = [0, 0,0.7,1]
        //self.imageView.layer.mask = gradientMaskLayer
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