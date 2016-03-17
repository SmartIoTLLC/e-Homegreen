//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
var mac:[UInt8] = [0x01, 0x00, 0x00]
var password:[UInt8] = [0x01, 0x00, 0x00]
var messageInfo:[UInt8] = [0x01, 0x00, 0x00]
messageInfo += mac
messageInfo += password
class Hey: NSObject {
    func wakeOnLan (address:[UInt8], mac:[UInt8], password:[UInt8]) -> [UInt8]{
        guard mac.count == 6 && password.count == 6 && address.count == 3 else {
            return [0x00]
        }
        return [0x02]
    }
}
Hey().wakeOnLan([1,2,3], mac: [1,2,3,4,5,6], password: [1,2,3,4,5,6])
let locations:[NSObject:[AnyObject]] = [
    1:["String1",12,43.5, "String Vladimir"],
    "String":["String",1,3.5, "String"],]

let array = locations[1]?[0]
locations["String"]

class Vladimir, Enumerable {
    init() {
    }
}
class Marko: Vladimir {
    
}
class Sladjan: Vladimir {
}
class Damir: Vladimir {
    
}
enum enumi:Vladimir {
    case M:Marko
    case S:Sladjan
    case D:Damir
}
