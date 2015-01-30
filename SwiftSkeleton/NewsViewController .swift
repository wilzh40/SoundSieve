//
//  NewsViewController .swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
class NewsViewController: CenterViewController, UITableViewDataSource, UITableViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLeftMenuButton()
        ConnectionManager.testNetworking()

    }
    func setupLeftMenuButton() {
        let leftDrawerButton = DrawerBarButtonItem(target: self, action: "toggleMenu")
        self.navigationItem.setLeftBarButtonItem(leftDrawerButton, animated: true)
  
    }
    func toggleMenu() {
              self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
        
    }

}