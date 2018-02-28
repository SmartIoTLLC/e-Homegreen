//
//  NavigationTitleViewNF.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/12/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation

enum ClockType: Int {
    case timeAMPM = 0, dateAndTimeLower, justDate, dateAndTimeUpper
}

class NavigationTitleViewNF: UIView {

    var clockState: ClockType = .timeAMPM
    
    let titleView = UILabel()
    let timeLabel = UILabel()
    let dateFormatter = DateFormatter()
    
    var clockTimer: Foundation.Timer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }
    
    deinit {
        clockTimer = nil
    }
    
    @objc fileprivate func tickTock() {
        timeLabel.text = dateFormatter.string(from: Date())        
    }
    
    func commonInit() {
        loadClockSettings()
        setDateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.amSymbol  = "AM"
        dateFormatter.pmSymbol  = "PM"
        timeLabel.text = dateFormatter.string(from: Date())
        clockTimer     = Foundation.Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTock), userInfo: nil, repeats: true)
        
        self.translatesAutoresizingMaskIntoConstraints = true
        self.backgroundColor = UIColor.clear
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = .clear
        titleView.font            = .tahoma(size: 17)
        titleView.textColor       = .white
        titleView.setContentHuggingPriority(1000, for: .horizontal)
        self.addSubview(titleView)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.backgroundColor           = .clear
        timeLabel.font                      = .tahoma(size: 17)
        timeLabel.textColor                 = .white
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.textAlignment             = .left
        timeLabel.isUserInteractionEnabled  = true
        timeLabel.numberOfLines = 2
        timeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setClockType)))
        self.addSubview(timeLabel)
        
        // Clock constraints
        let timeCenterY  = NSLayoutConstraint(item: timeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let timeTrailing = NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        self.addConstraint(timeCenterY)
        self.addConstraint(timeTrailing)
        
        // Title constraints
        let titleCenterY = NSLayoutConstraint(item: titleView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let titleLeading = NSLayoutConstraint(item: titleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 8)
        self.addConstraint(titleCenterY)
        self.addConstraint(titleLeading)
    }
    
    func setTitle(_ title:String){
        titleView.text = title
    }
    
    func loadClockSettings() {
        if let clockSettings = Foundation.UserDefaults.standard.value(forKey: UserDefaults.ClockType) as? Int { clockState = ClockType(rawValue: clockSettings)! }
    }
    
    func setDateFormatter() {
        switch clockState {
            case .timeAMPM         : dateFormatter.dateFormat = "h:mm a"
            case .dateAndTimeUpper : dateFormatter.dateFormat = "dd/MM/yyyy\n h:mm a"
            case .justDate         : dateFormatter.dateFormat = "dd/MM/yyyy"
            case .dateAndTimeLower : dateFormatter.dateFormat = "h:mm a\ndd/MM/yyyy"
        }
    }
    
    func setClockType() {
        switch clockState {
            case .timeAMPM         : saveClock(type: ClockType.dateAndTimeLower.rawValue)
            case .dateAndTimeLower : saveClock(type: ClockType.justDate.rawValue)
            case .justDate         : saveClock(type: ClockType.dateAndTimeUpper.rawValue)
            case .dateAndTimeUpper : saveClock(type: ClockType.timeAMPM.rawValue)
        }
        setDateFormatter()
        tickTock()
    }
    
    func saveClock(type: Int) {
        clockState = ClockType(rawValue: type)!
        Foundation.UserDefaults.standard.set(type, forKey: UserDefaults.ClockType)
    }
}
