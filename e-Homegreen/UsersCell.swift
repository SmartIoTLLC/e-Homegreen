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
    var time:Foundation.Timer?
    
    override func awakeFromNib() {
        imageTimer.layer.cornerRadius = 5
        imageTimer.clipsToBounds = true
    }
    
    func setItem(_ timer:Timer, filterParametar:FilterItem){
        cellTimer = timer
        titleLabel.text = getName(timer, filterParametar: filterParametar)
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timeLabel.text = "\(h):\(m):\(s)"
        
    }
    
    func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func startTimer(){
        time?.invalidate()
        time = Foundation.Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(TimerUserCell.countUp(_:)), userInfo:nil, repeats: true)
            
    }
    
    func stopTimer(){
        time?.invalidate()
    }
    
    func countUp(_ timer:Foundation.Timer){
        cellTimer.timerCount += 1
        let (h,m,s) = secondsToHoursMinutesSeconds(Int(cellTimer.timerCount))
        timeLabel.text = "\(h):\(m):\(s)"
    }
    
    override func prepareForReuse() {
        time?.invalidate()
    }
    
    func getName(_ timer:Timer, filterParametar:FilterItem) -> String{
        var name:String = ""
        if timer.gateway.location.name != filterParametar.location{
            name += timer.gateway.location.name! + " "
        }
//        if timer.entityLevel != filterParametar.levelName{
//            name += timer.entityLevel! + " "
//        }
//        if timer.timeZone != filterParametar.zoneName{
//            name += timer.timeZone! + " "
//        }
        name += timer.timerName
        return name
    }
    
    func getImagesFrom(_ timer:Timer) {
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
