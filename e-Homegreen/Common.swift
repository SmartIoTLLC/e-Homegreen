//
//  Common.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/18/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class Common: NSObject {
    
    var screenWidth:CGFloat! = UIScreen.mainScreen().bounds.size.width
    var screenHeight:CGFloat! = UIScreen.mainScreen().bounds.size.height
    
}

enum InputError: ErrorType {
    case InputMissing
    //  For zone and category id
    case IdIncorrect
}