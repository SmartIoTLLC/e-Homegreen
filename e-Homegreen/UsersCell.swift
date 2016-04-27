//
//  UsersCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/12/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class TimerUserCell:UICollectionViewCell{
    
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var imageTimer: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: CustomGradientButtonWhite!
    @IBOutlet weak var pauseButton: CustomGradientButtonWhite!
    @IBOutlet weak var stopButton: CustomGradientButtonWhite!
    
    var imageOne:UIImage?
    var imageTwo:UIImage?
    
    var cellTimer:Timer!
    var time:NSTimer?
    
    override func awakeFromNib() {
        imageTimer.layer.cornerRadius = 5
        imageTimer.clipsToBounds = true
    }
    
    func setItem(timer:Timer, filterParametar:FilterItem){
        cellTimer = timer
        titleLabel.text = getName(timer, filterParametar: filterParametar)
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timeLabel.text = "\(h):\(m):\(s)"
        
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startTimer(){
        time?.invalidate()
        time = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "countUp:", userInfo:nil, repeats: true)
            
    }
    
    func stopTimer(){
        time?.invalidate()
    }
    
    func countUp(timer:NSTimer){
        cellTimer.timerCount += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timeLabel.text = "\(h):\(m):\(s)"
    }
    
    override func prepareForReuse() {
        time?.invalidate()
    }
    
    func getName(timer:Timer, filterParametar:FilterItem) -> String{
        var name:String = ""
        if timer.gateway.location.name != filterParametar.location{
            name += timer.gateway.location.name! + " "
        }
        if timer.entityLevel != filterParametar.levelName{
            name += timer.entityLevel! + " "
        }
        if timer.timeZone != filterParametar.zoneName{
            name += timer.timeZone! + " "
        }
        name += timer.timerName
        return name
    }
    
    func getImagesFrom(timer:Timer) {
        if let timerImage = UIImage(data: timer.timerImageOne) {
            imageOne = timerImage
        }
        if let timerImage = UIImage(data: timer.timerImageTwo) {
            imageTwo = timerImage
        }
        imageTimer.image = imageOne
        setNeedsDisplay()
    }
    
    func commandSentChangeImage () {
        imageTimer.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(TimerCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    
    func changeImageToNormal () {
        imageTimer.image = imageOne
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