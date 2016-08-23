//
//  PulsingLayer .swift
//  SoundSieve
//
//  Created by Wilson Zhao on 4/25/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation

import UIKit
import QuartzCore

class PulsingLayer: CALayer {
    
    var radius: CGFloat
    var fromValueForRadius: CGFloat
    var fromValueForAlpha: CGFloat
    var keyTimeForHalfOpacity: CGFloat
    var animationDuration: NSTimeInterval
    var pulseInterval: NSTimeInterval
    var animationGroup: CAAnimationGroup
    
    let singleton = Singleton.sharedInstance
    var meterInterval: Float
    var threshold: Float
    var intervalThreshold: Float
    var intervalsSinceLastBeat: Float
    
    
    override init() {
        // before super.init()
        self.radius = 100
        self.fromValueForRadius = 2
        self.fromValueForAlpha = 0.45
        self.keyTimeForHalfOpacity = 0.45
        self.animationDuration = 1
        self.pulseInterval = 0
        self.animationGroup = CAAnimationGroup();
        
        // metering vars
        
        self.threshold = 0.94
        self.meterInterval = 0.01
        self.intervalThreshold = 5
        
        self.intervalsSinceLastBeat = 0
        super.init()
        
        // after super.init()
        self.repeatCount = 0;
        
        self.backgroundColor =  UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1).CGColor;
        
        let tempPos = self.position;
        let diameter = self.radius * 2;
        self.bounds = CGRectMake(0, 0, diameter, diameter);
        self.cornerRadius = self.radius;
        self.position = tempPos;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            self.setupAnimationGroup()
            
            
            dispatch_async(dispatch_get_main_queue(), {
                // Play the animation once
                self.addAnimation(self.animationGroup, forKey: "pulse")
                
                // Then add a timer that meters the audio
                _ = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: #selector(PulsingLayer.meterAudio), userInfo: nil, repeats: true)
            })
            
        })
    }
    
    @objc func meterAudio() {
        // Everytime the amplitude of the first channel exceeds a threshold
        // it will play the pulse animation again
        /*println(singleton.audioPlayer.peakPowerInDecibelsForChannel(1))
        let lowAmplitude = singleton.audioPlayer.peakPowerInDecibelsForChannel(1)
        if lowAmplitude > -5 {
            self.addAnimation(self.animationGroup, forKey:nil)
        }*/
        
        let normalizedValue = pow(10, singleton.audioPlayer.averagePowerInDecibelsForChannel(0) / 20) + pow(10, singleton.audioPlayer.averagePowerInDecibelsForChannel(1) / 20)
        //println(normalizedValue)
        if normalizedValue > self.threshold*2{
            intervalsSinceLastBeat += 1
            if intervalsSinceLastBeat > intervalThreshold {
                self.setupAnimationGroup()
                self.addAnimation(self.animationGroup, forKey:nil)
                intervalsSinceLastBeat = 0
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAnimationGroup() {
        self.animationGroup = CAAnimationGroup()
        self.animationGroup.duration = self.animationDuration + self.pulseInterval
        self.animationGroup.repeatCount = self.repeatCount
        self.animationGroup.removedOnCompletion = false
        self.animationGroup.fillMode = kCAFillModeForwards;
        self.animationGroup.delegate = self
        
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        self.animationGroup.timingFunction = defaultCurve
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.fromValue = self.fromValueForRadius
        scaleAnimation.toValue = 1.0;
        scaleAnimation.duration = self.animationDuration;
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [self.fromValueForAlpha, 0.45, 0]
        opacityAnimation.keyTimes = [0, self.keyTimeForHalfOpacity, 1]
        opacityAnimation.duration = self.animationDuration
        opacityAnimation.removedOnCompletion = false
        
        let animations = [scaleAnimation, opacityAnimation]
        self.animationGroup.animations = animations
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        //self.removeFromSuperlayer()
    }
}



