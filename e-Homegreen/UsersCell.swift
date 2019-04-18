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
    let clock0 = UIImage(named: "15 Timer - CLock - 00")
    let clock1 = UIImage(named: "15 Timer - CLock - 01")
    
    var cellTimer:Timer!
    var time:Foundation.Timer?
    
    override func awakeFromNib() {
        imageTimer.layer.cornerRadius = 5
        imageTimer.clipsToBounds = true
    }
    
    func setItem(_ timer:Timer, filterParametar:FilterItem, tag: Int) {
        cellTimer = timer
        titleLabel.text = getName(timer, filterParametar: filterParametar)
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timeLabel.text = "\(h):\(m):\(s)"
        
        titleLabel.isUserInteractionEnabled = true
        
        // Default
        playButton.isHidden = false
        pauseButton.isHidden = true
        stopButton.isHidden = true
        playButton.isEnabled = true
        playButton.setTitle("Start", for: UIControl.State())
        
        if timer.timerState == 1 {
            playButton.isHidden = true
            stopButton.isHidden = false
            pauseButton.isHidden = false
            startTimer()
            pauseButton.setTitle("Pause", for: UIControl.State())
        }
        if timer.timerState == 240 {
            playButton.isHidden = false
            pauseButton.isHidden = true
            stopButton.isHidden = true
            stopTimer()
            playButton.isEnabled = true
        }
        if timer.timerState == 238 {
            playButton.isHidden = true
            stopButton.isHidden = false
            pauseButton.isHidden = false
            stopTimer()
            pauseButton.setTitle("Resume", for: UIControl.State())
            stopButton.setTitle("Cancel", for: UIControl.State())
        }
        
        playButton.tag = tag
        pauseButton.tag = tag
        stopButton.tag = tag
        
        getImagesFrom(timer)
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startTimer() {
        time?.invalidate()
        time = Foundation.Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(TimerUserCell.countUp(_:)), userInfo:nil, repeats: true)
    }
    
    func stopTimer() {
        time?.invalidate()
    }
    
    @objc func countUp(_ timer:Foundation.Timer) {
        cellTimer.timerCount += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timeLabel.text = "\(h):\(m):\(s)"
    }
    
    override func prepareForReuse() {
        time?.invalidate()
    }
    
    func getName(_ timer:Timer, filterParametar:FilterItem) -> String {
        var name:String = ""
        if timer.gateway.location.name != filterParametar.location { name += timer.gateway.location.name! + " " }
        name += timer.timerName
        return name
    }
    
    func getImagesFrom(_ timer:Timer) {
        if let id = timer.timerImageOneCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData {
                    imageOne = UIImage(data: data)
                } else {
                    if let defaultImage = timer.timerImageOneDefault { imageOne = UIImage(named: defaultImage)
                    } else { imageOne = clock0 }
                }
            } else {
                if let defaultImage = timer.timerImageOneDefault { imageOne = UIImage(named: defaultImage)
                } else { imageOne = clock0 }
            }
            
        } else {
            if let defaultImage = timer.timerImageOneDefault { imageOne = UIImage(named: defaultImage)
            } else { imageOne = clock0 }
        }
        
        if let id = timer.timerImageTwoCustom {
            if let image = DatabaseImageController.shared.getImageById(id) {
                if let data =  image.imageData {
                    imageTwo = UIImage(data: data)
                } else {
                    if let defaultImage = timer.timerImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                    } else { imageTwo = clock1 }
                }
            } else {
                if let defaultImage = timer.timerImageTwoDefault { imageTwo = UIImage(named: defaultImage)
                } else { imageTwo = clock1 }
            }
        } else {
            if let defaultImage = timer.timerImageTwoDefault { imageTwo = UIImage(named: defaultImage)
            } else { imageTwo = clock1 }
        }
        imageTimer.image = imageOne
        setNeedsDisplay()
    }
    
    func commandSentChangeImage () {
        imageTimer.image = imageTwo
        setNeedsDisplay()
        Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TimerCollectionViewCell.changeImageToNormal), userInfo: nil, repeats: false)
    }
    
    func changeImageToNormal () {
        imageTimer.image = imageOne
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
