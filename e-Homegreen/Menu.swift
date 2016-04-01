//
//  Menu.swift
//  SlideOutNavigation
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 James Frost. All rights reserved.
//

import UIKit

class MenuItem:NSObject{
    let title: String?
    let image: UIImage?
    let viewController: UIViewController?
    var state:Bool?
    
    init(title: String, image: UIImage?, viewController: UIViewController, state:Bool) {
        self.title = title
        self.image = image
        self.viewController = viewController
        self.state = state
    }
}

