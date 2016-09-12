//
//  EventCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class EventsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var eventButton: UIButton!
    var reportEvent:Bool = false
    var eventId:Int!
    var imageOne:UIImage?
    var imageTwo:UIImage?
    
    func setItem(event:Event, filterParametar:FilterItem){
        eventTitle.text = getName(event, filterParametar: filterParametar)
    }
    
    func getName(event:Event, filterParametar:FilterItem) -> String{
        var name:String = ""
        if event.gateway.location.name != filterParametar.location{
            name += event.gateway.location.name! + " "
        }
        if let id = event.entityLevelId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: event.gateway.location){
                if zone.name != filterParametar.levelName{
                    name += zone.name! + " "
                }
            }
        }
        
        if let id = event.eventZoneId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: event.gateway.location){
                if zone.name != filterParametar.zoneName{
                    name += zone.name! + " "
                }
            }
        }
        name += event.eventName
        return name
    }
    
    func getImagesFrom(event:Event) {
        self.reportEvent = event.report.boolValue
        self.eventId = event.eventId as Int
        
        if let id = event.eventImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                }else{
                    if let defaultImage = event.eventImageOneDefault{
                        imageOne = UIImage(named: defaultImage)
                    }else{
                        imageOne = UIImage(named: "17 Event - Up Down - 00")
                    }
                }
            }else{
                if let defaultImage = event.eventImageOneDefault{
                    imageOne = UIImage(named: defaultImage)
                }else{
                    imageOne = UIImage(named: "17 Event - Up Down - 00")
                }
            }
        }else{
            if let defaultImage = event.eventImageOneDefault{
                imageOne = UIImage(named: defaultImage)
            }else{
                imageOne = UIImage(named: "17 Event - Up Down - 00")
            }
        }
        
        if let id = event.eventImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTwo = UIImage(data: data)
                }else{
                    if let defaultImage = event.eventImageTwoDefault{
                        imageTwo = UIImage(named: defaultImage)
                    }else{
                        imageTwo = UIImage(named: "17 Event - Up Down - 01")
                    }
                }
            }else{
                if let defaultImage = event.eventImageTwoDefault{
                    imageTwo = UIImage(named: defaultImage)
                }else{
                    imageTwo = UIImage(named: "17 Event - Up Down - 01")
                }
            }
        }else{
            if let defaultImage = event.eventImageTwoDefault{
                imageTwo = UIImage(named: defaultImage)
            }else{
                imageTwo = UIImage(named: "17 Event - Up Down - 01")
            }
        }
        
        eventImageView.image = imageOne
        setNeedsDisplay()
    }
    func commandSentChangeImage () {
        
        if reportEvent {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventsCollectionViewCell.changeImage(_:)), name:"ReportEvent", object: nil)
        }else{
            eventImageView.image = imageTwo
            setNeedsDisplay()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(EventsCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)

        }
    }
    func changeImage(notification:NSNotification) {
        if let info = notification.userInfo! as? [String:Int] {
            if info["value"] == 1{
                eventImageView.image = imageTwo
                setNeedsDisplay()
            }else{
                if info["id"] == eventId{
                    eventImageView.image = imageOne
                    setNeedsDisplay()
                }
            }
        }
    }
    func changeImageToNormal () {
        eventImageView.image = imageOne
        setNeedsDisplay()
    }
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.AllCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGrayColor().setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
                                                  colors,
                                                  colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}
