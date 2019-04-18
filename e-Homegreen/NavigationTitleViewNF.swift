//
//  NavigationTitleViewNF.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/12/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import SnapKit

enum ClockType: Int {
    case timeAMPM = 0, dateAndTimeLower, justDate, dateAndTimeUpper
}

class NavigationTitleViewNF: UIView {
    // todo: save clock state to user
    private var clockState: ClockType = .timeAMPM
    
    private let titleLabel: UILabel = UILabel()
    private let timeLabel: UILabel = UILabel()
    private let dateFormatter = DateFormatter()
    
    private var clockTimer: Foundation.Timer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
        addTitleLabel()
        addTimeLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
        
        addTitleLabel()
        addTimeLabel()
        
        setupConstraints()
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    deinit {
        clockTimer = nil
    }
    
    @objc fileprivate func tickTock() {
        timeLabel.text = dateFormatter.string(from: Date())        
    }
    
    private func addTitleLabel() {
        titleLabel.font            = .tahoma(size: 17)
        titleLabel.textColor       = .white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        self.addSubview(titleLabel)
    }
    
    private func addTimeLabel() {
        timeLabel.font                      = .tahoma(size: 17)
        timeLabel.textColor                 = .white
        timeLabel.textAlignment             = .right
        timeLabel.addTap {
            self.setClockType()
        }
        timeLabel.numberOfLines = 2
        
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.amSymbol  = "AM"
        dateFormatter.pmSymbol  = "PM"
        
        timeLabel.text = dateFormatter.string(from: Date())
                
        self.addSubview(timeLabel)
    }
    
    func commonInit() {
        loadClockSettings()
        setDateFormatter()
        
        clockTimer     = Foundation.Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTock), userInfo: nil, repeats: true)
    }
    
    private func setupConstraints() {
        timeLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(timeLabel.snp.leading)
        }
    }
    
    func setTitle(_ title:String){
        titleLabel.text = title
    }
    
    private func loadClockSettings() {
        if let clockSettings = Foundation.UserDefaults.standard.value(forKey: "clockType") as? Int { clockState = ClockType(rawValue: clockSettings)! }
    }
    
    private func setDateFormatter() {
        switch clockState {
            case .timeAMPM         : dateFormatter.dateFormat = "h:mm a"
            case .dateAndTimeUpper : dateFormatter.dateFormat = "dd/MM/yyyy\n h:mm a"
            case .justDate         : dateFormatter.dateFormat = "dd/MM/yyyy"
            case .dateAndTimeLower : dateFormatter.dateFormat = "h:mm a\ndd/MM/yyyy"
        }
    }
    
    private func setClockType() {
        switch clockState {
            case .timeAMPM         : saveClock(type: ClockType.dateAndTimeLower.rawValue)
            case .dateAndTimeLower : saveClock(type: ClockType.justDate.rawValue)
            case .justDate         : saveClock(type: ClockType.dateAndTimeUpper.rawValue)
            case .dateAndTimeUpper : saveClock(type: ClockType.timeAMPM.rawValue)
        }
        setDateFormatter()
        tickTock()
    }
    
    private func saveClock(type: Int) {
        clockState = ClockType(rawValue: type)!
        Foundation.UserDefaults.standard.set(type, forKey: "clockType")
    }
}
