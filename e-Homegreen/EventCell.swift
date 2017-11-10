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
    let upDown0 = UIImage(named: "17 Event - Up Down - 00")
    let upDown1 = UIImage(named: "17 Event - Up Down - 01")
    
    func setItem(_ event:Event, filterParametar:FilterItem, tag: Int) {
        eventTitle.text = getName(event, filterParametar: filterParametar)
        eventTitle.tag = tag
        eventTitle.isUserInteractionEnabled = true
        
        eventImageView.tag = tag
        eventImageView.isUserInteractionEnabled = true
        
        if let id = event.eventImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data = image.imageData { eventImageView.image = UIImage(data: data)
                    
                } else {
                    if let defaultImage = event.eventImageOneDefault { eventImageView.image = UIImage(named: defaultImage)
                    } else { eventImageView.image = upDown0 }
                }
                
            } else {
                if let defaultImage = event.eventImageOneDefault { eventImageView.image = UIImage(named: defaultImage)
                } else { eventImageView.image = upDown0 }
            }
            
        } else {
            if let defaultImage = event.eventImageOneDefault { eventImageView.image = UIImage(named: defaultImage)
            } else { eventImageView.image = upDown0 }
        }
        
        eventImageView.layer.cornerRadius = 5
        eventImageView.clipsToBounds = true
        
        eventButton.tag = tag
        
        layer.cornerRadius = 5
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 0.5
    }
    
    func getName(_ event:Event, filterParametar:FilterItem) -> String {
        var name:String = ""
        if event.gateway.location.name != filterParametar.location { name += event.gateway.location.name! + " " }
        if let id = event.entityLevelId as? Int {
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: event.gateway.location) {
                if zone.name != filterParametar.levelName { name += zone.name! + " " }
            }
        }
        
        if let id = event.eventZoneId as? Int {
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: event.gateway.location) {
                if zone.name != filterParametar.zoneName { name += zone.name! + " " }
            }
        }
        name += event.eventName
        return name
    }
    
    func getImagesFrom(_ event:Event) {
        self.reportEvent = event.report.boolValue
        self.eventId = event.eventId as! Int
        
        if let id = event.eventImageOneCustom {
            
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                } else {
                    if let defaultImage = event.eventImageOneDefault{ imageOne = UIImage(named: defaultImage)
                    } else { imageOne = upDown0 }
                }
            } else {
                if let defaultImage = event.eventImageOneDefault { imageOne = UIImage(named: defaultImage)
                } else { imageOne = upDown0 }
            }
        } else {
            if let defaultImage = event.eventImageOneDefault { imageOne = UIImage(named: defaultImage)
            } else { imageOne = upDown0 }
        }
        
        if let id = event.eventImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData { imageTwo = UIImage(data: data)
                } else {
                    if let defaultImage = event.eventImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                    } else { imageTwo = upDown1 }
                }
            } else {
                if let defaultImage = event.eventImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                } else { imageTwo = upDown1 }
            }
        } else {
            if let defaultImage = event.eventImageTwoDefault { imageTwo = UIImage(named: defaultImage)
            } else { imageTwo = upDown1 }
        }
        
        eventImageView.image = imageOne
        setNeedsDisplay()
    }
    func commandSentChangeImage () {
        
        if reportEvent {
            NotificationCenter.default.addObserver(self, selector: #selector(EventsCollectionViewCell.changeImage(_:)), name:NSNotification.Name(rawValue: "ReportEvent"), object: nil)
        } else {
            eventImageView.image = imageTwo
            setNeedsDisplay()
            Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(changeImageToNormal), userInfo: nil, repeats: false)
        }
    }
    func changeImage(_ notification:Notification) {
        if let info = notification.userInfo! as? [String:Int] {
            
            if info["value"] == 1 { eventImageView.image = imageTwo; setNeedsDisplay()
                
            } else {
                if info["id"] == eventId { eventImageView.image = imageOne; setNeedsDisplay() }
            }
        }
    }
    
    func changeImageToNormal () {
        eventImageView.image = imageOne
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGray.setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).withAlphaComponent(0.95).cgColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).withAlphaComponent(1.0).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                                  colors: colors as CFArray,
                                                  locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:self.bounds.height)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}
