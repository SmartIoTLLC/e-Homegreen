//
//  RemoteDummy.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation

public class RemoteDummy: NSObject {
    
    enum ButtonShape {
        case rectangle
        case circle
    }
    
    var buggerOff: String?
    var name: String?
    var location: Location?
    var address: String!
    var channel: String!
    var buttonSize: CGSize!
    var margin: [CGFloat]!
    var buttonColor: UIColor!
    var buttonShape: String!
    var columns: Int!
    var rows: Int!
    var buttonMargins: UIEdgeInsets!

    init(buggerOff: String) {
        self.buggerOff = buggerOff
    }
}
