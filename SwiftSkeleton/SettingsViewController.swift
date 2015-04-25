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
        static let dateTime = "dateTime"
        static let date = "date"
        static let time = "time"
        static let duplicates = "duplicates"
        static let autoplay = "autoplay"
        static let genre = "genre"
    }
    
  /*  required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initializeForm()
    }
    */
    override func viewDidLoad() {
        self.initializeForm()
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
        
        
        // 
        
      
        //
        
        
        form = XLFormDescriptor.formDescriptorWithTitle("Settings") as! XLFormDescriptor
        
        section = XLFormSectionDescriptor.formSectionWithTitle("Genres") as! XLFormSectionDescriptor
        form.addFormSection(section)
        
        
        row = XLFormRowDescriptor(tag: tag.genre, rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Genre")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "textLabel.font")
        row.cellConfig.setObject(UIFont(name:"Futura",size:15.00)!, forKey: "detailTextLabel.font")
        row.selectorOptions = Singleton.sharedInstance.genres as [AnyObject]
        section.addFormRow(row)
        
        
        
        
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
        
        
        
        self.form = form;
        
        
        
        print(self.formValues())
    
    }
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        
        // Called once a value is changed
        // Delegate function


        print(self.formValues()[formRow.description]!)
        var values = self.formValues() as Dictionary
        
        settings.autoplay = values[tag.autoplay] as! Bool
        settings.duplicates = values[tag.duplicates] as! Bool
        
        
        

    }
    
}