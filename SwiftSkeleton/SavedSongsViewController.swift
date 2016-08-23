//
//  MenuViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit

class SavedSongsViewController: UITableViewController, SavedSongsDelegate {
    let singleton:Singleton = Singleton.sharedInstance
    var tableData:NSMutableArray = ["Error"]
    
    
    func setupData() {
        self.tableData = singleton.savedTracks
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name:"Futura",size:20.00)!]
        self.navigationController?.navigationBar.topItem?.title = "Saved Songs"
    }
    
    func clearData () {
        self.tableView.beginUpdates()
        for i in 0 ..< tableData.count {
            let indexPath = NSIndexPath(forRow: i, inSection: 0)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        singleton.clearSavedTracks()
        self.tableView.endUpdates()
        print("Data Cleared", terminator: "")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
        
        Singleton.sharedInstance.delegate = self
        //  ConnectionManager.testNetworking()
        
        let barButton = UIBarButtonItem(barButtonSystemItem:.Trash, target: self, action: #selector(SavedSongsViewController.clearData))
        
        self.navigationItem.setRightBarButtonItem(barButton, animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadData()
        self.navigationController?.view.layoutSubviews()
        self.evo_drawerController?.centerViewController?.view.userInteractionEnabled = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.evo_drawerController?.centerViewController?.view.userInteractionEnabled = true
        
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
        cell.textLabel?.font = UIFont(name:"Futura",size:11.00)
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.textLabel?.numberOfLines = 2
        
        // IF there is an artist display it
        
        // HACKY way when track.use has no data
        if track.user != "ExampleUser" {
            cell.detailTextLabel?.text = track.user
            cell.detailTextLabel?.font = UIFont(name:"Futura",size:8.00)
            cell.detailTextLabel?.textColor = UIColor.grayColor()
        }
        
        
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
        //let reversedArray = NSMutableArray(array: singleton.savedTracks.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
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
        
        _ = singleton.savedTracks[indexPath.row] as! Track
        
        
        
    }
    
    func reloadData() {
        self.tableData = singleton.savedTracks
            
            //NSMutableArray(array: singleton.savedTracks.reverseObjectEnumerator().allObjects).mutableCopy() as! NSMutableArray
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            ConnectionManager.unFavoriteTrack(singleton.savedTracks[indexPath.row] as! Track);
            // To account for the reversed order of the array
            self.tableData = singleton.savedTracks
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
}