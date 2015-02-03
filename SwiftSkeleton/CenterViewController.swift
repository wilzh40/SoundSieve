//
//  CenterViewController .swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/30/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit

class CenterViewController: UITableViewController, ConnectionProtocol {
    let singleton:Singleton = Singleton.sharedInstance
    let connectionManager:ConnectionManager = ConnectionManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLeftMenuButton()
        connectionManager.delegate = self
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