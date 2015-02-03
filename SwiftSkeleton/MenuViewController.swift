//
//  MenuViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit

class MenuViewController: UITableViewController {
      let singleton:Singleton = Singleton.sharedInstance
      var tableData:NSMutableArray = ["Error"]
 

    func setupData() {
        self.tableData = singleton.centerViewControllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        ConnectionManager.testNetworking()
       // ConnectionManager.getRedditList()
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "protoCell")
        let vc:UIViewController = tableData[indexPath.row] as UIViewController

        cell.textLabel?.text = vc.title

        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Chane the center view controller
        switch (indexPath.row) {
            case 0:
                //let newCenterController:CenterViewController =
            break
        default:
            break
        }
        self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
        
    }
   
    
}