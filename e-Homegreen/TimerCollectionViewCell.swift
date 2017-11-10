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
    let clock0 = UIImage(named: "15 Timer - CLock - 00")
    let clock1 = UIImage(named: "15 Timer - CLock - 01")
    
    var cellTimer:Timer!
    var time:Foundation.Timer?
    
    func setItem(_ timer:Timer, filterParametar:FilterItem, tag: Int) {
        cellTimer = timer
        
        timerTitle.isUserInteractionEnabled = true
        timerTitle.text = getName(timer, filterParametar: filterParametar)
        if Int(cellTimer.type) == TimerType.timer.rawValue || Int(cellTimer.type) == TimerType.stopwatch.rawValue{
            let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
            timerCOuntingLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
        }else{
           timerCOuntingLabel.text = ""
        }
        
        timerButton.tag = tag
        timerButtonLeft.tag = tag
        timerButtonRight.tag = tag
        
        //   ===   Default   ===
        if Int(timer.type) == TimerType.timer.rawValue || Int(timer.type) == TimerType.stopwatch.rawValue {
            timerButton.isHidden = false
            timerButtonLeft.isHidden = true
            timerButtonRight.isHidden = true
            timerButton.isEnabled = true
            timerButton.setTitle("Start", for: UIControlState())
            
            if timer.timerState == 1 {
                timerButton.isHidden = true
                timerButtonLeft.isHidden = false
                timerButtonRight.isHidden = false
                startTimer()
                timerButtonRight.setTitle("Pause", for: UIControlState())
                timerButtonLeft.setTitle("Cancel", for: UIControlState())
            }
            
            if timer.timerState == 240 {
                timerButton.isHidden = false
                timerButtonLeft.isHidden = true
                timerButtonRight.isHidden = true
                stopTimer()
                timerButton.isEnabled = true
                timerButton.setTitle("Start", for: UIControlState())
            }
            
            if timer.timerState == 238 {
                timerButton.isHidden = true
                timerButtonLeft.isHidden = false
                timerButtonRight.isHidden = false
                stopTimer()
                timerButtonRight.setTitle("Resume", for: UIControlState())
                timerButtonLeft.setTitle("Cancel", for: UIControlState())
            }
            
        } else {
            timerCOuntingLabel.text = ""
            if timer.timerState == 240 {
                timerButton.isHidden = false
                timerButtonLeft.isHidden = true
                timerButtonRight.isHidden = true
                timerButton.setTitle("Cancel", for: UIControlState())
                timerButton.isEnabled = false
            } else {
                timerButton.isHidden = false
                timerButtonLeft.isHidden = true
                timerButtonRight.isHidden = true
                timerButton.setTitle("Cancel", for: UIControlState())
                timerButton.isEnabled = true
            }
        }
        
        timerImageView.layer.cornerRadius = 5
        timerImageView.clipsToBounds = true
        
        getImagesFrom(timer)
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startTimer(){
        if Int(cellTimer.type) == TimerType.timer.rawValue{
            time?.invalidate()
            time = Foundation.Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(countDown(_:)), userInfo:nil, repeats: true)
            
        }
        if Int(cellTimer.type) == TimerType.stopwatch.rawValue{
            time?.invalidate()
            time = Foundation.Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(countUp(_:)), userInfo:nil, repeats: true)
            
        }
    }
    
    func stopTimer(){
        time?.invalidate()
    }
    
    func countUp(_ timer:Foundation.Timer){
        cellTimer.timerCount += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timerCOuntingLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
    }
    
    override func prepareForReuse() {
        time?.invalidate()
    }
    
    func countDown(_ timer:Foundation.Timer){
        if cellTimer.timerCount > 0 {
            cellTimer.timerCount -= 1
            let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
            timerCOuntingLabel.text = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
        }
        
    }
    
    func getName(_ timer:Timer, filterParametar:FilterItem) -> String{
        var name:String = ""
        if timer.gateway.location.name != filterParametar.location { name += timer.gateway.location.name! + " " }
        
        if let id = timer.entityLevelId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: timer.gateway.location){
                if zone.name != filterParametar.levelName{ name += zone.name! + " " }
            }
        }        
        if let id = timer.timeZoneId as? Int{
            if let zone = DatabaseZoneController.shared.getZoneById(id, location: timer.gateway.location){
                if zone.name != filterParametar.zoneName { name += zone.name! + " " }
            }
        }
        name += timer.timerName
        return name
    }
    
    func getImagesFrom(_ timer:Timer) {
        
        if let id = timer.timerImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageOne = UIImage(data: data)
                } else { if let defaultImage = timer.timerImageOneDefault { imageOne = UIImage(named: defaultImage)
                    } else { imageOne = clock0 } }
                
            } else {
                if let defaultImage = timer.timerImageOneDefault { imageOne = UIImage(named: defaultImage)
                } else { imageOne = clock0 } }
            
        } else {
            if let defaultImage = timer.timerImageOneDefault { imageOne = UIImage(named: defaultImage)
            } else { imageOne = clock0 } }
        
        
        if let id = timer.timerImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                
                if let data =  image.imageData { imageTwo = UIImage(data: data)
                } else {
                    if let defaultImage = timer.timerImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                    } else { imageTwo = clock1 } }
                
            } else {
                if let defaultImage = timer.timerImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                } else { imageTwo = clock1 } }
            
        } else {
            if let defaultImage = timer.timerImageTwoDefault { imageTwo = UIImage(named: defaultImage)
            } else { imageTwo = clock1 } }
        
        timerImageView.image = imageOne
        setNeedsDisplay()
    }
    
    func commandSentChangeImage () {
        timerImageView.image = imageTwo
        setNeedsDisplay()
        Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    
    func changeImageToNormal () {
        timerImageView.image = imageOne
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
