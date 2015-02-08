//
//  MenuViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit

class SavedSongsViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, SavedSongsDelegate {
      let singleton:Singleton = Singleton.sharedInstance
      var tableData:NSMutableArray = ["Error"]
 

    func setupData() {
        self.tableData = singleton.savedTracks
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name:"Futura",size:20.00)!]

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        Singleton.sharedInstance.delegate = self
        ConnectionManager.testNetworking()
        
        let barButton = UIBarButtonItem(title: "Clear Data", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("clearData"))
        self.navigationItem.setLeftBarButtonItem(barButton, animated: true)
            

       // ConnectionManager.getRedditList()
        
    }
    
    func clearData () {
        println("Data Cleared")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
         let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "protoCell")
        let track:Track = tableData[indexPath.row] as Track

        cell.textLabel?.text = track.title
        cell.textLabel?.font = UIFont(name:"Futura",size:13.00)

        return cell
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Change the center view controller
        self.tableView.reloadData()
        var url : NSURL
        let track = singleton.savedTracks[indexPath.row] as Track
        url = NSURL(string:track.permalink_url)!
        UIApplication.sharedApplication().openURL(url)
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == singleton.savedTracks {
            return false
        }
        return true
    }
   
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == singleton.savedTracks {
            return nil
        }
        return indexPath
    }
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == singleton.savedTracks {
            cell.alpha = 0.4
            cell.backgroundColor = UIColor.grayColor()
        }
      
    }
    override func viewWillAppear(animated: Bool) {
        self.reloadData()
    }
    func reloadData() {
        self.tableData = singleton.savedTracks
        self.tableView.reloadData()
    }
    
    @IBAction func clearListPressed(sender: UIButton) {
        singleton.clearSavedTracks()
        singleton
    }
}