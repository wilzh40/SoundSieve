//
//  MainNavController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/30/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
class MainNavController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        var button = UIBarButtonItem(title: "=", style: .Plain, target: self, action: Selector("toggleMenu"))
        self.navigationItem.setLeftBarButtonItem(button, animated: true)

        
        

    }
    
    func toggleMenu() {
        
    }
}