//
//  SongCell.swift
//  SoundSieve
//
//  Created by Wilson Zhao on 4/26/15.
//  Copyright (c) 2015 Innogen. All rights reserved.
//

import Foundation
import UIKit

class SongCell: UITableViewCell  {
    
    
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, urlString: String) {
        
       
        super.init(style: style, reuseIdentifier: reuseIdentifier)
         self.imageView!.image = UIImage(contentsOfFile:"placeHolderArt")
        ImageLoader.sharedLoader.imageForUrl(urlString, completionHandler:{(image: UIImage?, url: String) in
            self.imageView!.image = image
            self.setNeedsLayout()
        })
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func setCachedImage (urlString: String) {
        ImageLoader.sharedLoader.imageForUrl(urlString, completionHandler:{(image: UIImage?, url: String) in
            self.imageView!.image = image
        })
    }
    
}