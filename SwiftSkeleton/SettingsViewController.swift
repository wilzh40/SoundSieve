//
//  SettingsViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 2/3/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
import XLForm
class SettingsViewController:  XLFormViewController, XLFormDescriptorDelegate {
    
    let settings = Singleton.sharedInstance.settings
    
    struct tag {
        static let duplicates = "duplicates"
        static let autoplay = "autoplay"
        static let genre = "genre"
        static let hotness = "hotness"
        static let preview = "preview"
        static let waveform = "waveform"
        static let account = "account"
        static let credits = "credits"
        static let stream = "stream"
    }
    
  /*  required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initializeForm()
    }
    */
    override func viewDidLoad() {
        
        self.initializeForm()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont(name:"Futura",size:20.00)!]
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.view.layoutSubviews()
        self.updateUsername()
        self.evo_drawerController?.centerViewController?.view.userInteractionEnabled = false
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.evo_drawerController?.centerViewController?.view.userInteractionEnabled = true
        
    }


    
    func initializeForm() {
        
        
        
        // Row Config
        
        var form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor.formDescriptorWithTitle("Settings") as! XLFormDescriptor

        section = XLFormSectionDescriptor.formSectionWithTitle("Genres") as! XLFormSectionDescriptor
        form.addFormSection(section)
        
    // Genres

        row = XLFormRowDescriptor(tag: tag.genre, rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Genre")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "detailTextLabel.font")
        row.selectorOptions = Singleton.sharedInstance.genres as [AnyObject]
        row.value = Singleton.sharedInstance.genres.objectAtIndex(settings.selectedGenre)
        
    
        section.addFormRow(row)
        
    // Other settings
        
        section = XLFormSectionDescriptor.formSectionWithTitle("Other Settings") as!XLFormSectionDescriptor
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        section.multivaluedRowTemplate = row
        section.multivaluedRowTemplate.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")

        form.addFormSection(section)
        
        
        // Switches
        
        // Stream
        row = XLFormRowDescriptor(tag: tag.stream, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Use User Stream")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.value = settings.stream
        section.addFormRow(row)
        
        // Display Duplicates?
        row = XLFormRowDescriptor(tag: tag.duplicates, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Display Duplicates?")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.value = settings.duplicates
        section.addFormRow(row)
        
        // Autoplay?
        row = XLFormRowDescriptor(tag: tag.autoplay, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Autoplay?")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.value = settings.autoplay
        section.addFormRow(row)
        
        // Hotness?
        row = XLFormRowDescriptor(tag: tag.hotness, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Sort by Hotness?")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.value = settings.hotness
        section.addFormRow(row)

        // Preview Song?
        row = XLFormRowDescriptor(tag: tag.preview, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Preview song?")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.value = settings.preview
        section.addFormRow(row)
        
        // Display Waveform
        row = XLFormRowDescriptor(tag: tag.waveform, rowType: XLFormRowDescriptorTypeBooleanSwitch, title: "Display Waveform?")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.value = settings.waveform
        section.addFormRow(row)
        
    // User Account
        section = XLFormSectionDescriptor.formSectionWithTitle("Soundcloud Account") as!XLFormSectionDescriptor
        
        form.addFormSection(section)
        
        // Account
        if let un = Singleton.sharedInstance.username {
            row = XLFormRowDescriptor(tag: tag.account, rowType: XLFormRowDescriptorTypeButton, title: Singleton.sharedInstance.username)
        } else {
             row = XLFormRowDescriptor(tag: tag.account, rowType: XLFormRowDescriptorTypeButton, title: "Connect with SoundCloud")
        }
        row.cellConfigIfDisabled.setObject(UIColor.ht_bitterSweetColor(), forKey: "backgroundColor")

        row.cellConfig.setObject(UIColor.ht_bitterSweetDarkColor(), forKey: "backgroundColor")
    
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIColor.whiteColor(), forKey: "textLabel.color")
        row.value = Singleton.sharedInstance.username
        row.action.formSelector = "connectSC"
        section.addFormRow(row)
    // Credits
        section = XLFormSectionDescriptor.formSectionWithTitle("Credits") as! XLFormSectionDescriptor
        
        form.addFormSection(section)
        
        // Account
     
        let credits2 = "Wilson Zhao | Brian Ng | Kevin Zeng "
        row = XLFormRowDescriptor(tag: tag.credits, rowType: XLFormRowDescriptorTypeInfo, title: credits2)
        row.cellConfig.setObject(UIFont(name:"Futura",size:10.00)!, forKey: "textLabel.font")
        section.addFormRow(row)
        
        let credits = "Uses StreamingKit (Thong Ngyuen), XLForms (Xmartlabs)"
        row = XLFormRowDescriptor(tag: tag.credits, rowType: XLFormRowDescriptorTypeInfo, title: credits)
        row.cellConfig.setObject(UIFont(name:"Futura",size:8.00)!, forKey: "textLabel.font")
        section.addFormRow(row)
        
        
        self.form = form;
        
    }

    func connectSC() {
        println("Connecting account")
        ConnectionManager.authenticateSC()
    }
  
    func updateUsername(){
        //self.reloadFormRow(self.form.formRowWithTag(tag.account))
        self.updateFormRow(self.form.formRowWithTag(tag.account))
        if let un = Singleton.sharedInstance.username {
            self.form.formRowWithTag(tag.account).title = un
        }
        self.tableView.reloadData()
        println(Singleton.sharedInstance.username)

    }


    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        
        // Called once a value is changed
        // Delegate function

        var values = self.formValues() as Dictionary
        
        if formRow.tag == tag.genre {
            // Get the index of the selection, works seemlessly with existing code
            
            settings.selectedGenre = Singleton.sharedInstance.genres.indexOfObject(values[tag.genre] as! String)
            self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
            ConnectionManager.getRandomTracks()
            SwiftSpinner.show("Switching Genres")
        }
      
        if formRow.tag == tag.hotness {
            settings.hotness = values[tag.hotness] as! Bool
            ConnectionManager.getRandomTracks()
            SwiftSpinner.show("Switching Sorting")
            self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
        }
        
        if formRow.tag == tag.stream {
            settings.stream = values[tag.stream] as! Bool
            if settings.stream == true {
                settings.trackSource = .Stream
                ConnectionManager.getUserStream()
                SwiftSpinner.show("Switching to Stream")
            } else {
                settings.trackSource = .Explore
                ConnectionManager.getRandomTracks()
                SwiftSpinner.show("Switching to Explore")
            }
            self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)

        }
        
        //ConnectionManager.sharedInstance.delegate?.updatePausePlayButton!(true)
        
        settings.autoplay = values[tag.autoplay] as! Bool
        settings.duplicates = values[tag.duplicates] as! Bool
        
        settings.preview = values[tag.preview] as! Bool
        settings.waveform = values[tag.waveform] as! Bool
        
        print(self.formValues())

    }
    
}