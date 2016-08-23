//
//  ChooseSongView .swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 2/7/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UCZProgressView
import MDCSwipeToChoose

let imageLabelWidth:Float = 42.0

class ChooseTrackView : MDCSwipeToChooseView {
    var track:Track?
    
    var infoView:UIView?
    var loadingAnimation: UCZProgressView!

    
    init(track:Track, frame:CGRect, options:MDCSwipeToChooseViewOptions) {
        self.track = track
        
        super.init(frame: frame, options: options)
        self.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleBottomMargin]
        
        loadingAnimation = UCZProgressView(frame: self.bounds)
        self.showLoadingAnimation()
        
        ImageLoader.sharedLoader.imageForUrl(track.artwork_url!, completionHandler:{(image: UIImage?, url: String) in
            self.imageView!.image = image
            self.imageView!.alpha = 0
            self.loadingAnimation.blurEffect = UIBlurEffect(style: .ExtraLight)
            UIView.animateWithDuration(0.3, animations:{
                self.imageView!.alpha = 1
            
            })
        })

        //self.constructInfoView()

       // self.constructNameLabel()
      //  self.addBackground()

    }
    
    
    // Called when the song is loaded/playing to hide the loading animation
    func showLoadingAnimation () {
        self.loadingAnimation!.alpha = 0.5
        self.addSubview(loadingAnimation!)
    }
    func hideLoadingAnimation () {
      
        UIView.animateWithDuration(0.8, animations: {
            self.loadingAnimation!.alpha = 0.0
            }, completion: { finished in
                self.loadingAnimation.removeFromSuperview()
        })
        
    }
    
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    
    }
    
    func constructNameLabel() {
       let leftPadding:CGFloat = 12
        let topPadding:CGFloat = 50
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
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.shadowColor = UIColor.blackColor().CGColor
        //self.backgroundColor = UIColor.blackColor()
        let gradientMaskLayer:CAGradientLayer = CAGradientLayer()
        gradientMaskLayer.frame = self.bounds
        gradientMaskLayer.colors = [UIColor.whiteColor().CGColor, UIColor.blackColor().CGColor,UIColor.blackColor().CGColor,UIColor.clearColor().CGColor]

        gradientMaskLayer.locations = [0, 0,0.7,1]
        //self.imageView.layer.mask = gradientMaskLayer
    }
    
    func constructInfoView() {
        let bottomHeight: CGFloat = 60
        let bottomFrame = CGRectMake(0,
            CGRectGetHeight(self.bounds) - bottomHeight,
            CGRectGetWidth(self.bounds),
            bottomHeight)
        infoView = UIView(frame: bottomFrame)
        infoView?.backgroundColor = UIColor.whiteColor()
        infoView?.clipsToBounds = true
        infoView?.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, .FlexibleTopMargin]
        self.addSubview(infoView!)
    }

}