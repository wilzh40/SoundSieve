//
//  ViewController.swift
//  SwiftSkeleton
//
//  Created by Wilson Zhao on 1/28/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import UIKit
import AlamofireSwiftyJSON
import Alamofire
import SwiftyJSON


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let x = "/users/123"
        let URL = "https://api.soundcloud.com" + x


        Alamofire.request(.GET, URL, parameters: ["foo": "bar"])
            .responseSwiftyJSON { (request, response, responseJSON, error) in
                print(responseJSON)
                print(error)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

