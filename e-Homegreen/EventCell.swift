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
    var imageOne:UIImage?
    var imageTwo:UIImage?
    func getImagesFrom(event:Event) {
        if let eventImage = UIImage(data: event.eventImageOne) {
            imageOne = eventImage
        }
        
        if let eventImage = UIImage(data: event.eventImageTwo) {
            imageTwo = eventImage
        }
        eventImageView.image = imageOne
        setNeedsDisplay()
    }
    func commandSentChangeImage () {
        eventImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(EventsCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
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