//
//  SettingsViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 2/3/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit
class SettingsViewController:  XLFormViewController {
    
    struct tag {
        static let dateTime = "dateTime"
        static let date = "date"
        static let time = "time"
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.initializeForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initializeForm() {
        var form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor.formDescriptorWithTitle("Dates") as! XLFormDescriptor
        
        section = XLFormSectionDescriptor.formSectionWithTitle("Inline Dates") as!XLFormSectionDescriptor
        form.addFormSection(section)
        
        // Date
        row = XLFormRowDescriptor(tag: tag.date, rowType: XLFormRowDescriptorTypeDateInline, title:"Date")
        row.value = NSDate()
        section.addFormRow(row)
        
        // Time
        row = XLFormRowDescriptor(tag: tag.time, rowType: XLFormRowDescriptorTypeTimeInline, title: "Time")
        row.value = NSDate()
        section.addFormRow(row)
        
        // DateTime
        row = XLFormRowDescriptor(tag: tag.dateTime, rowType: XLFormRowDescriptorTypeDateTimeInline, title: "Date Time")
        row.value = NSDate()
        section.addFormRow(row)
        self.form = form;
    }
    
}