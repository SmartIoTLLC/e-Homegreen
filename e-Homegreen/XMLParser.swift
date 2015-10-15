//
//  XMLParser.swift
//  XMLdemo
//
//  Created by Vladimir on 9/21/15.
//  Copyright © 2015 nswebdevolopment. All rights reserved.
//

import UIKit
import Foundation

class XMLParser: NSObject, NSXMLParserDelegate {
    
    var parser = NSXMLParser()
    var posts = NSMutableArray()
    var answer = String()
    var element = NSString()
    var title1 = String()
    var title2 = String()
    
    func parseAnswer() -> String {
        
        let url = NSURL(string: "http://answers.com/Q/what_is_banana")!
        
        if let parser = NSXMLParser(contentsOfURL: url) {
            parser.delegate = self
            parser.parse()
        }
        
        return answer
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if elementName == "div class=\"answer_text\""
        {

        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        if string == "div"
        {
            
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName as NSString).isEqualToString("item") {

        }
    }
    

}
