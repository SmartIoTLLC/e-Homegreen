//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"
let mac_address = [0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1]

let s2 = "08:9E:01:50:83:D1"
let cs2 = (s2 as NSString).UTF8String
let second_parametar = UnsafeMutablePointer<UInt8>(cs2)
let data_mac_address = NSData(bytes: mac_address, length: mac_address.count)
let mac = UnsafeMutablePointer<UInt8>(mac_address)
let mac1 = UnsafeMutablePointer<UInt8>(mac_address)
let mac2 = UnsafeMutablePointer<UInt8>(mac_address)
let mac3 = UnsafeMutablePointer<UInt8>(mac_address)
let mac4 = UnsafeMutablePointer<UInt8>(mac_address)

let a = UnsafeMutableBufferPointer(start: second_parametar, count: 6)
var b:[UInt8] = []
for i in a {
    b.append(UInt8(i))
}
b



class Hey: NSObject {
    func test(p : UnsafeMutablePointer<UInt8>, n : Int) {
        
        // Mutable buffer pointer from data:
        let a = UnsafeMutableBufferPointer(start: p, count: n)
        // Array from mutable buffer pointer
        let b = Array(a)
        
        // Modify the given data:
        p[2] = 17
        
        // Printing elements of a shows the modified data: 1, 2, 17, 4
        for elem in a {
            print(elem)
        }
        
        // Printing b shows the orignal (copied) data: 1, 2, 3, 4
        print(b)
        
    }
    func convertByteArrayToMacAddress(byteArray:[UInt8]) -> String {
        guard byteArray.count == 6 else {
            return ""
        }
        var returnString = ""
        for (index, byte) in byteArray.enumerate() {
            if index == byteArray.count-1 {
                returnString += String.localizedStringWithFormat("%02x", byte)
                break
            }
            returnString += String.localizedStringWithFormat("%02x", byte) + ":"
        }
        return returnString.uppercaseString
    }
}
var bytes : [UInt8] = [0x08, 0x9E, 0x01, 0x50, 0x83, 0xD1]
Hey().test(&bytes, n: bytes.count)

let s3 = "08:9E:01:50:83:D1"
let cs3 = (s3 as NSString).UTF8String
let second_parametar3 = UnsafeMutablePointer<UInt8>(cs3)
Hey().convertByteArrayToMacAddress(bytes)
