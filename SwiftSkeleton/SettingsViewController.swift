//
//  SettingsViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 2/3/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
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

        form.addFormSection(section)
        
        
        // Switches
        
        
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
        row = XLFormRowDescriptor(tag: tag.account, rowType: XLFormRowDescriptorTypeButton, title: Singleton.sharedInstance.username)
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.value = Singleton.sharedInstance.username
        row.action.formSelector = "connectSC"
        section.addFormRow(row)

        
        self.form = form;
        
    }

    func connectSC() {
        println("Connecting account")
        ConnectionManager.authenticateSC()
    }
  
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        
        // Called once a value is changed
        // Delegate function

        var values = self.formValues() as Dictionary
        
        if formRow.description == tag.genre {
            // Get the index of the selection, works seemlessly with existing code
            
            settings.selectedGenre = Singleton.sharedInstance.genres.indexOfObject(values[tag.genre] as! String)
            self.evo_drawerController?.closeDrawerAnimated(true, completion: nil)
            ConnectionManager.getRandomTracks()
            SwiftSpinner.show("Switching Genres")
        }
      
        
        settings.autoplay = values[tag.autoplay] as! Bool
        settings.duplicates = values[tag.duplicates] as! Bool
        
        settings.preview = values[tag.preview] as! Bool
        settings.waveform = values[tag.waveform] as! Bool
        
        print(self.formValues())

    }
    
}