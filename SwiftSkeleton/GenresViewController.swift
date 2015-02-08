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
       
        //self.navigationItem.title?.font = UIFont(name:"Futura",size:15.00)
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName:UIFont(name:"Futura",size:20.00)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name:"Futura",size:20.00)!]
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
        cell.textLabel?.font = UIFont(name:"Futura",size:15.00)
        
        if indexPath.row == singleton.selectedGenre {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None

        }
        
        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Change the center view controller
        
        
        singleton.selectedGenre = indexPath.row
        self.tableView.reloadData()
        self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
        ConnectionManager.getRandomTracks("a", limit: 0)
        
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
       return true
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        // Remove all accessories
      
        if indexPath.row == singleton.selectedGenre {
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