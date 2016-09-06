//
//  TimerCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/11/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation



class TimerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timerTitle: UILabel!
    @IBOutlet weak var timerImageView: UIImageView!
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var timerButtonLeft: UIButton!
    @IBOutlet weak var timerButtonRight: UIButton!    
    @IBOutlet weak var timerCOuntingLabel: UILabel!
    
    var imageOne:UIImage?
    var imageTwo:UIImage?
    
    var cellTimer:Timer!
    var time:NSTimer?
//    var count:Int = 0
    
    func setItem(timer:Timer, filterParametar:FilterItem){
        cellTimer = timer
        timerTitle.text = getName(timer, filterParametar: filterParametar)
        if cellTimer.type == "Timer" || cellTimer.type == "Stopwatch/User"{
            let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
            timerCOuntingLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
        }else{
           timerCOuntingLabel.text = ""
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startTimer(){
        if cellTimer.type == "Timer"{
            time?.invalidate()
            time = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "countDown:", userInfo:nil, repeats: true)
            
        }
        if cellTimer.type == "Stopwatch/User"{
            time?.invalidate()
            time = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: "countUp:", userInfo:nil, repeats: true)
            
        }
    }
    
    func stopTimer(){
        time?.invalidate()
    }
    
    func countUp(timer:NSTimer){
        cellTimer.timerCount += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timerCOuntingLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
    }
    
    override func prepareForReuse() {
        time?.invalidate()
    }
    
    func countDown(timer:NSTimer){
        if cellTimer.timerCount > 0{
            cellTimer.timerCount -= 1
            let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
            timerCOuntingLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
        }
        
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
        
        if let id = timer.timerImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                }else{
                    if let defaultImage = timer.timerImageOneDefault{
                        imageOne = UIImage(named: defaultImage)
                    }else{
                        imageOne = UIImage(named: "15 Timer - CLock - 00")
                    }
                }
            }else{
                if let defaultImage = timer.timerImageOneDefault{
                    imageOne = UIImage(named: defaultImage)
                }else{
                    imageOne = UIImage(named: "15 Timer - CLock - 00")
                }
            }
        }else{
            if let defaultImage = timer.timerImageOneDefault{
                imageOne = UIImage(named: defaultImage)
            }else{
                imageOne = UIImage(named: "15 Timer - CLock - 00")
            }
        }
        
        if let id = timer.timerImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageTwo = UIImage(data: data)
                }else{
                    if let defaultImage = timer.timerImageTwoDefault{
                        imageTwo = UIImage(named: defaultImage)
                    }else{
                        imageTwo = UIImage(named: "15 Timer - CLock - 01")
                    }
                }
            }else{
                if let defaultImage = timer.timerImageTwoDefault{
                    imageTwo = UIImage(named: defaultImage)
                }else{
                    imageTwo = UIImage(named: "15 Timer - CLock - 01")
                }
            }
        }else{
            if let defaultImage = timer.timerImageTwoDefault{
                imageTwo = UIImage(named: defaultImage)
            }else{
                imageTwo = UIImage(named: "15 Timer - CLock - 01")
            }
        }
        timerImageView.image = imageOne
        setNeedsDisplay()
    }
    
    func commandSentChangeImage () {
        timerImageView.image = imageTwo
        setNeedsDisplay()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(TimerCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    
    func changeImageToNormal () {
        timerImageView.image = imageOne
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
