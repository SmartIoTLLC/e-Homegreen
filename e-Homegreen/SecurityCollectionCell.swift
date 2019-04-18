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
    
    let inactiveAway     = UIImage(named: "inactiveaway")
    let inactiveNight    = UIImage(named: "inactivenight")
    let inactiveDay      = UIImage(named: "inactiveday")
    let inactiveVacation = UIImage(named: "inactivevacation")
    let inactiveDisarm   = UIImage(named: "inactivedisarm")
    let inactivePanic    = UIImage(named: "inactivepanic")
    let activeAway       = UIImage(named: "away")
    let activeNight      = UIImage(named: "night")
    let activeDay        = UIImage(named: "day")
    let activeVacation   = UIImage(named: "vacation")
    let activeDisarm     = UIImage(named: "disarm")
    let activePanic      = UIImage(named: "panic")

    let defaults = Foundation.UserDefaults.standard
    var timer: Foundation.Timer?
    
    var securityButtonTitle: String!
    
    func setCell(_ name: String, security: Security, tag: Int) {
        // These two notifications are used to start and stop blinking correct cell, which is being activated.
        NotificationCenter.default.addObserver(self, selector: #selector(startBlinking(_:)), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStartBlinking), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopBlinking), name: NSNotification.Name(rawValue: NotificationKey.Security.ControlModeStopBlinking), object: nil)
        
        securityTitle.text                     = name
        securityTitle.isUserInteractionEnabled = true
        securityTitle.tag                      = tag
        
        securityButton.tag = tag
        securityImageView.image = UIImage(named: "maaa")
        
        if security.securityName! == SecurityControlMode.Disarm { securityButtonTitle = "ENTER CODE" }
        else if security.securityName! == SecurityControlMode.Panic { securityButtonTitle = "TRIGGER" }
        else { securityButtonTitle = "ARM" }
        securityButton.setTitle(securityButtonTitle, for: UIControl.State())
        
        switch security.securityName! {
            case "Away"     : securityImageView.image = inactiveAway
            case "Night"    : securityImageView.image = inactiveNight
            case "Day"      : securityImageView.image = inactiveDay
            case "Vacation" : securityImageView.image = inactiveVacation
            case "Disarm"   : securityImageView.image = inactiveDisarm
            case "Panic"    : securityImageView.image = inactivePanic
            default: break
        }
        
        if let securityMode = defaults.value(forKey: UserDefaults.Security.SecurityMode) as? String {
            if security.securityName!.contains(securityMode) {
                switch securityMode {
                    case "Away"     : securityImageView.image = activeAway
                    case "Night"    : securityImageView.image = activeNight
                    case "Day"      : securityImageView.image = activeDay
                    case "Vacation" : securityImageView.image = activeVacation
                    case "Disarm"   : securityImageView.image = activeDisarm
                    default: break
                }
            }
        }
        
        if security.securityName! == "Panic" {
            if defaults.bool(forKey: UserDefaults.Security.IsPanic) { securityImageView.image = activePanic }
            else { securityImageView.image = inactivePanic }
        }
    }

    @objc func startBlinking(_ notification: Notification) {
        guard let notificationControlMode = notification.userInfo?["controlMode"] as? String else { return }
        guard let securityCellName = securityTitle.text else { return }
        
        if securityCellName.contains(notificationControlMode) {
            if timer == nil {

                if securityCellName == "Panic" { timer = Foundation.Timer.scheduledTimer(timeInterval: 0, target: self, selector: #selector(toggleBtnImage(_:)), userInfo: notification.userInfo, repeats: false)
                } else { timer = Foundation.Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(toggleBtnImage(_:)), userInfo: notification.userInfo, repeats: true) }
            }
            
        } else {
            if let _ = timer { timer!.invalidate(); timer = nil }
        }
    }
    
    // Indicates cell to stop blinking (new state has occured)
    @objc func stopBlinking() {
        
        guard let timer = self.timer else { return }
        timer.invalidate()
    }
    
    // Function used to toggle images on-off until App receives new state
    @objc func toggleBtnImage(_ timer: Foundation.Timer) {
        if let info = timer.userInfo as? [String:AnyObject] {
            if let i = info["controlMode"] as? String {
                let image = securityImageView.image
                var changedImage: UIImage!
                
                switch i {
                    case SecurityControlMode.Away     : if image == inactiveAway { changedImage = activeAway } else { changedImage = inactiveAway }
                    case SecurityControlMode.Day      : if image == inactiveDay { changedImage = activeDay } else { changedImage = inactiveDay }
                    case SecurityControlMode.Disarm   : if image == inactiveDisarm { changedImage = activeDisarm } else { changedImage = inactiveDisarm }
                    case SecurityControlMode.Night    : if image == inactiveNight { changedImage = activeNight } else { changedImage = inactiveNight }
                    case SecurityControlMode.Vacation : if image == inactiveVacation { changedImage = activeVacation } else { changedImage = inactiveVacation }
                    case SecurityControlMode.Panic    : if image == inactivePanic { changedImage = activePanic } else { changedImage = inactivePanic }
                    default: break
                }
                
                securityImageView.image = changedImage
            }
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        
        UIColor.lightGray.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors  = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).withAlphaComponent(0.95).cgColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).withAlphaComponent(1.0).cgColor]
        
        let colorSpace               = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint   = CGPoint(x:0, y:self.bounds.height)
        
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
        path.stroke()
    }
    
}
