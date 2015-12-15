//
//  ChatInfo.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/14/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

struct ChatScopeAnswer {
    let zoneName:String
    let chatScope:ChatScope
}

enum ChatScope {
    case ZoneFound
    case DidNotFindZone
    case UseFilter
}