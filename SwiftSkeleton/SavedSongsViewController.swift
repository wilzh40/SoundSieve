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
        self.navigationController?.navigationBar.topItem?.title = "Saved Songs"
    }
    
    func clearData () {
        self.tableView.beginUpdates()
        for var i = 0; i < tableData.count; ++i {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        singleton.clearSavedTracks()
        self.tableView.endUpdates()
        println("Data Cleared")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        
        Singleton.sharedInstance.delegate = self
      //  ConnectionManager.testNetworking()

        let barButton = UIBarButtonItem(barButtonSystemItem:.Trash, target: self, action: Selector("clearData"))

        self.navigationItem.setRightBarButtonItem(barButton, animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadData()
        self.navigationController?.view.layoutSubviews()
        
        
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
  
        let track:Track = tableData[indexPath.row] as! Track
        let cell: SongCell = SongCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "protoCell",urlString: track.artwork_url!)
        cell.textLabel?.text = track.title
        cell.textLabel?.font = UIFont(name:"Futura",size:13.00)
        //cell.imageView!.image = ConnectionManager.getImageFromURL(track.artwork_url!)
        
        // Opti efforts
              cell.layer.shouldRasterize = false
       // cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        return cell
    }
    

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Change the center view controller
        // self.tableView.reloadData()
        var url : NSURL
        let track = singleton.savedTracks[indexPath.row] as! Track
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
        
        let track = singleton.savedTracks[indexPath.row] as! Track
     

      
    }
    
    func reloadData() {
        self.tableData = singleton.savedTracks
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            singleton.deleteSavedTrackAtIndex(indexPath.row)
            self.tableData = singleton.savedTracks
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
}