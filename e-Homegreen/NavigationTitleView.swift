//
//  NavigationTitleView.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/21/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class NavigationTitleView: UIView {
    
    let titleView = UILabel()
    let subtitleView = UILabel()
    
    var titleTopConstraint = NSLayoutConstraint()
    var titleLeadingConstraint = NSLayoutConstraint()
    var subtitleTopConstraint = NSLayoutConstraint()
    var subtitleLeadingConstraint = NSLayoutConstraint()
    
    var titleCenterConstraint = NSLayoutConstraint()
    var subtitleCenterConstraint = NSLayoutConstraint()
    var subtitleLeadingConstraintLandscape = NSLayoutConstraint()
    
    let timeLabel = UILabel()
    
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
        timeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
    }
    
    func commonInit() {
        timeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
        clockTimer     = Foundation.Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(tickTock), userInfo: nil, repeats: true)
        
        self.translatesAutoresizingMaskIntoConstraints = true        
        self.backgroundColor = .clear
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = .clear
        titleView.font            = .tahoma(size: 20)
        titleView.textColor       = .white
        titleView.setContentHuggingPriority(1000, for: .horizontal)
        self.addSubview(titleView)
        
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        subtitleView.backgroundColor           = .clear
        subtitleView.font                      = .tahoma(size: 13)
        subtitleView.textColor                 = .white
        subtitleView.adjustsFontSizeToFitWidth = true
        self.addSubview(subtitleView)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.backgroundColor           = .clear
        timeLabel.font                      = .tahoma(size: 20)
        timeLabel.textColor                 = .white
        timeLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(timeLabel)
        
        // Clock constraints
        let timeCenterY           = NSLayoutConstraint(item: timeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let timeTrailing          = NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        self.addConstraint(timeCenterY)
        self.addConstraint(timeTrailing)
        
        // set portrait constraint
        titleTopConstraint        = NSLayoutConstraint(item: titleView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        titleLeadingConstraint    = NSLayoutConstraint(item: titleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24)
        subtitleTopConstraint     = NSLayoutConstraint(item: subtitleView, attribute: .top, relatedBy: .equal, toItem: titleView, attribute: .bottom, multiplier: 1.0, constant: 0)
        subtitleLeadingConstraint = NSLayoutConstraint(item: subtitleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 24)
        
        // set landscape constraint
        titleCenterConstraint = NSLayoutConstraint(item: titleView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        
        subtitleCenterConstraint           = NSLayoutConstraint(item: subtitleView, attribute: .centerY, relatedBy: .equal, toItem: titleView, attribute: .centerY, multiplier: 1.0, constant: 0)
        subtitleLeadingConstraintLandscape = NSLayoutConstraint(item: subtitleView, attribute: .leading, relatedBy: .equal, toItem: titleView, attribute: .trailing, multiplier: 1.0, constant: 10)
        
        self.addConstraint(NSLayoutConstraint(item: subtitleView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))

        setPortraitTitle()
        
    }
    
    func setPortraitTitle(){
        self.removeConstraint(titleLeadingConstraint)
        self.removeConstraint(titleCenterConstraint)
        self.removeConstraint(subtitleCenterConstraint)
        self.removeConstraint(subtitleLeadingConstraintLandscape)
        
        self.addConstraint(titleTopConstraint)
        self.addConstraint(titleLeadingConstraint)
        self.addConstraint(subtitleTopConstraint)
        self.addConstraint(subtitleLeadingConstraint)
    }
    
    func setLandscapeTitle(){
        self.removeConstraint(titleLeadingConstraint)
        self.removeConstraint(titleTopConstraint)
        self.removeConstraint(subtitleTopConstraint)
        self.removeConstraint(subtitleLeadingConstraint)
        
        self.addConstraint(titleCenterConstraint)
        self.addConstraint(titleLeadingConstraint)
        self.addConstraint(subtitleCenterConstraint)
        self.addConstraint(subtitleLeadingConstraintLandscape)
    }
    
    func setTitleAndSubtitle(_ title:String, subtitle:String){
        titleView.text = title
        subtitleView.text = subtitle
    }

}
