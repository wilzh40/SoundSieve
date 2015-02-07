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
        return 100;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "protoCell")
        let VC:UIViewController = tableData[indexPath.row] as UIViewController

        cell.textLabel?.text = VC.title
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Change the center view controller
        let newCenterVC = singleton.centerViewControllers[indexPath.row] as UIViewController

        if indexPath.row != singleton.currentCenterViewController {
            
            // Doesn't allow selection of the current VC
            
            self.evo_drawerController?.setCenterViewController(newCenterVC, withCloseAnimation: true, completion: nil)
            self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
            singleton.currentCenterViewController = indexPath.row

        }
        self.tableView.reloadData()
            
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == singleton.currentCenterViewController {
            return false
        }
        return true
    }
   
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == singleton.currentCenterViewController {
            return nil
        }
        return indexPath
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == singleton.currentCenterViewController {
            cell.alpha = 0.4
            cell.backgroundColor = UIColor.grayColor()
        }
      
    }
    
}