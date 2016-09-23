//
//  ChatBubbleData.swift
//  ChatBubbleScratch
//
//  Created by Vladimir on 10/13/15.
//  Copyright © 2015 Innofied Solution Pvt. Ltd. All rights reserved.
//

import Foundation
import UIKit

enum BubbleDataType: Int{
    case mine = 0
    case opponent
}

/// DataModel for maintaining the message data for a single chat bubble
class ChatBubbleData {
    
    // 2.Properties
    var text: String?
    var image: UIImage?
    var date: Date?
    var type: BubbleDataType
    
    // 3. Initialization
    init(text: String?,image: UIImage?,date: Date? , type:BubbleDataType = .mine) {
        // Default type is Mine
        self.text = text
        self.image = image
        self.date = date
        self.type = type
    }
}
