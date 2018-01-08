//
//  NavigationTitleViewNF.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/12/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
import Foundation

class NavigationTitleViewNF: UIView {
    
    let titleView = UILabel()
    
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
        self.addSubview(timeLabel)
        
        // Clock constraints
        let timeCenterY  = NSLayoutConstraint(item: timeLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let timeTrailing = NSLayoutConstraint(item: timeLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0)
        self.addConstraint(timeCenterY)
        self.addConstraint(timeTrailing)
        
        // Title constraints
        let titleCenterY = NSLayoutConstraint(item: titleView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        let titleLeading = NSLayoutConstraint(item: titleView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 16)
        self.addConstraint(titleCenterY)
        self.addConstraint(titleLeading)
    }
    
    func setTitle(_ title:String){
        titleView.text = title
    }
}
