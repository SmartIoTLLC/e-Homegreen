//
//  NavigationTitleView.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//
import UIKit

private struct LocalConstants {
    static let labelHeight: CGFloat = 22
}

class NavigationTitleView: UIView {
    
    private var clockState: ClockType = .timeAMPM
    
    private let titleView = UILabel()
    private let subtitleView = UILabel()
    private let dateFormatter = DateFormatter()
    
    private let timeLabel = UILabel()
    
    private var clockTimer: Foundation.Timer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
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
    
    func commonInit() {
        loadClockSettings()
        setDateFormatter()
        
        addTitleLabel()
        addSubtitleLabel()
        addTimeLabel()
        
        setPortraitTitle()
    }
    
    private func addTitleLabel() {
        titleView.font            = .tahoma(size: 17)
        titleView.textColor       = .white
        
        self.addSubview(titleView)
    }
    
    private func addSubtitleLabel() {
        subtitleView.font                      = .tahoma(size: 13)
        subtitleView.textColor                 = .white
        subtitleView.adjustsFontSizeToFitWidth = true
        
        self.addSubview(subtitleView)
    }
    
    private func addTimeLabel() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        timeLabel.text = dateFormatter.string(from: Date())
        clockTimer     = Foundation.Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(tickTock), userInfo: nil, repeats: true)
        timeLabel.font                      = .tahoma(size: 17)
        timeLabel.textColor                 = .white
        timeLabel.textAlignment             = .right
        timeLabel.numberOfLines             = 2
        timeLabel.addTap {
            self.setClockType()
        }
        
        self.addSubview(timeLabel)
    }
    
    func setPortraitTitle() {
        timeLabel.adjustsFontSizeToFitWidth = false
        
        titleView.snp.remakeConstraints { (make) in
            make.bottom.equalTo(self.snp.centerY)
            make.leading.equalToSuperview()
            make.trailing.equalTo(timeLabel.snp.leading)
            make.height.equalTo(LocalConstants.labelHeight)
        }
        
        subtitleView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.snp.centerY)
            make.leading.equalToSuperview()
            make.trailing.equalTo(timeLabel.snp.leading)
            make.height.equalTo(LocalConstants.labelHeight)
        }
        
        timeLabel.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
    }
    
    func setLandscapeTitle(){
        timeLabel.adjustsFontSizeToFitWidth = true
        
        titleView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        subtitleView.snp.remakeConstraints { (make) in
            make.leading.equalTo(titleView.snp.trailing).offset(GlobalConstants.sidePadding / 2)
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(timeLabel.snp.leading)
        }
        
        timeLabel.snp.remakeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
    }
    
    func setTitleAndSubtitle(_ title:String, subtitle:String){
        titleView.text = title
        subtitleView.text = subtitle
    }
    
    private func loadClockSettings() {
        if let clockSettings = Foundation.UserDefaults.standard.value(forKey: UserDefaults.ClockType) as? Int { clockState = ClockType(rawValue: clockSettings)! }
    }
    
    private func setDateFormatter() {
        switch clockState {
            case .timeAMPM         : dateFormatter.dateFormat = "h:mm a"
            case .dateAndTimeUpper : dateFormatter.dateFormat = "dd/MM/yyyy\n h:mm a"
            case .justDate         : dateFormatter.dateFormat = "dd/MM/yyyy"
            case .dateAndTimeLower : dateFormatter.dateFormat = "h:mm a\ndd/MM/yyyy"
        }
    }
    
    @objc private func setClockType() {
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
        Foundation.UserDefaults.standard.set(type, forKey: UserDefaults.ClockType)
    }
    
}
