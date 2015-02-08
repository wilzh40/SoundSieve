//
//  GenresViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 2/8/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
//
//  MenuViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit

class GenresViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource  {
    let singleton:Singleton = Singleton.sharedInstance
    var tableData:NSMutableArray = ["Error"]
    
    
    func setupData() {
        self.tableData = singleton.genres
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
       // Singleton.sharedInstance.delegate = self
        ConnectionManager.testNetworking()
        // ConnectionManager.getRedditList()
        
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "protoCell")
      
        
        cell.textLabel?.text = tableData[indexPath.row] as? String
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Change the center view controller
        self.tableView.reloadData()
        
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == singleton.savedTracks {
            return false
        }
        return true
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell",
            forIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        if indexPath.row == singleton.savedTracks {
            return nil
        }
        return indexPath
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
       
        
    }
    
    func reloadData() {
        self.tableData = singleton.savedTracks
        self.tableView.reloadData()
    }
    
}