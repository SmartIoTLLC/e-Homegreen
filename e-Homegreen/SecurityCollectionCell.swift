//
//  SecurityCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/14/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class SecurityCollectionCell: UICollectionViewCell {
    @IBOutlet weak var securityTitle: UILabel!
    @IBOutlet weak var securityImageView: UIImageView!
    @IBOutlet weak var securityButton: UIButton!
    
    var timer: Foundation.Timer?
    
    func setCell(_ name: String, securityName: String, securityBtnTitle: String){
        
        // These two notifications are used to start and stop blinking correct cell, which is being activated.
        NotificationCenter.default.addObserver(self, selector: #selector(SecurityCollectionCell.startBlinking(_:)), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStartBlinking), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SecurityCollectionCell.stopBlinking), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStopBlinking), object: nil)
        self.securityTitle.text = name
        self.securityTitle.isUserInteractionEnabled = true
        self.securityImageView.image = UIImage(named: "maaa")
        self.securityButton.setTitle(securityBtnTitle, for: UIControlState())
        
        
        switch securityName {
        case "Away":
            self.securityImageView.image = UIImage(named: "inactiveaway")
        case "Night":
            self.securityImageView.image = UIImage(named: "inactivenight")
        case "Day":
            self.securityImageView.image = UIImage(named: "inactiveday")
        case "Vacation":
            self.securityImageView.image = UIImage(named: "inactivevacation")
        case "Disarm":
            self.securityImageView.image = UIImage(named: "inactivedisarm")
        case "Panic":
            self.securityImageView.image = UIImage(named: "inactivepanic")
        default: break
        }
        
        let defaults = Foundation.UserDefaults.standard
        if let securityMode = defaults.value(forKey: UserDefaults.Security.SecurityMode) as? String {
            if securityName.contains(securityMode) {
                switch securityMode {
                case "Away":
                    self.securityImageView.image = UIImage(named: "away")
                case "Night":
                    self.securityImageView.image = UIImage(named: "night")
                case "Day":
                    self.securityImageView.image = UIImage(named: "day")
                case "Vacation":
                    self.securityImageView.image = UIImage(named: "vacation")
                case "Disarm":
                    self.securityImageView.image = UIImage(named: "disarm")
                default: break
                }
            }
        }
        if securityName == "Panic" {
            if defaults.bool(forKey: UserDefaults.Security.IsPanic) {
                //                cell.setImageForSecuirity(UIImage(named: "panic")!)
                self.securityImageView.image = UIImage(named: "panic")
            } else {
                //                cell.setImageForSecuirity(UIImage(named: "inactivepanic")!)
                self.securityImageView.image = UIImage(named: "inactivepanic")
            }
        }
    }
    
    func setImageForSecuirity (_ image:UIImage) {
        securityImageView.image = image
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
    
    func startBlinking(_ notification: Notification){
        print("Celija: \(self.securityTitle.text)")
        guard let notificationControlMode = (notification as NSNotification).userInfo?["controlMode"] as? String else{
            return
        }
        guard let securityCellName = self.securityTitle.text else{
            return
        }
        if (securityCellName.contains(notificationControlMode)) {
            if timer == nil {
                if securityCellName == "Panic" {
//                timer = Foundation.Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(SecurityCollectionCell.toggleBtnImage(_:)), userInfo: (notification as NSNotification).userInfo, repeats: true)
                } else {
                timer = Foundation.Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SecurityCollectionCell.toggleBtnImage(_:)), userInfo: (notification as NSNotification).userInfo, repeats: true)
                }
            }
        }else{
            if let _ = self.timer{
                timer!.invalidate()
                timer = nil
            }
        }
    }
    // Indicates cell to stop blinking (new state has occured)
    func stopBlinking(){
//        let defaults = Foundation.UserDefaults.standard
//        guard let currentControlMode = defaults.value(forKey: UserDefaults.Security.SecurityMode) as? String else{
//            return
//        }
//        
//        if currentControlMode != SecurityControlMode.Disarm {
//            guard let timer = self.timer else{
//                return
//            }
//            
//            timer.invalidate()
//        }
        
        guard let timer = self.timer else { return }
        timer.invalidate()
    }
    
    // Function used to toggle immages on-off until App receives new state
    func toggleBtnImage(_ timer: Foundation.Timer){
        if let info = timer.userInfo as? [String:AnyObject] {
            if let i = info["controlMode"] as? String{
                switch i {
                case SecurityControlMode.Away:
                    if self.securityImageView.image == UIImage(named: "inactiveaway"){
                        self.securityImageView.image = UIImage(named: "away")
                    }else{
                        self.securityImageView.image = UIImage(named: "inactiveaway")
                    }
                case SecurityControlMode.Day:
                    if self.securityImageView.image == UIImage(named: "inactiveday"){
                        self.securityImageView.image = UIImage(named: "day")
                    }else{
                        self.securityImageView.image = UIImage(named: "inactiveday")
                    }
                case SecurityControlMode.Disarm:
                    if self.securityImageView.image == UIImage(named: "inactivedisarm"){
                        self.securityImageView.image = UIImage(named: "disarm")
                    }else{
                        self.securityImageView.image = UIImage(named: "inactivedisarm")
                    }
                case SecurityControlMode.Night:
                    if self.securityImageView.image == UIImage(named: "inactivenight"){
                        self.securityImageView.image = UIImage(named: "night")
                    }else{
                        self.securityImageView.image = UIImage(named: "inactivenight")
                    }
                case SecurityControlMode.Vacation:
                    if self.securityImageView.image == UIImage(named: "inactivevacation"){
                        self.securityImageView.image = UIImage(named: "vacation")
                    }else{
                        self.securityImageView.image = UIImage(named: "inactivevacation")
                    }
                case SecurityControlMode.Panic:
                    if self.securityImageView.image == UIImage(named: "inactivepanic"){
                        self.securityImageView.image = UIImage(named: "panic")
                        print("Postavljen PANIC image")
                    }else{
                        self.securityImageView.image = UIImage(named: "panic")
                        print("Sklonjen PANIC image")
                    }
                default:
                    break
//                    if self.securityImageView.image == UIImage(named: "inactivepanic"){
//                        self.securityImageView.image = UIImage(named: "panic")
//                        print("Postavljen PANIC image")
//                    }else{
//                        self.securityImageView.image = UIImage(named: "inactivepanic")
//                        print("Sklonjen PANIC image")
//                    }
                }
            }
        }
        
    }
    
}
