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

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        self.translatesAutoresizingMaskIntoConstraints = true        
        self.backgroundColor = UIColor.clear
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor.clear
        titleView.font = UIFont.boldSystemFont(ofSize: 20)
        titleView.textColor = UIColor.white
        titleView.setContentHuggingPriority(1000, for: .horizontal)
        self.addSubview(titleView)
        
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        subtitleView.backgroundColor = UIColor.clear
        subtitleView.font = UIFont.boldSystemFont(ofSize: 13)
        subtitleView.textColor = UIColor.white
        subtitleView.adjustsFontSizeToFitWidth = true
        self.addSubview(subtitleView)
        
        //set portrait constraint
        titleTopConstraint = NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0)
        titleLeadingConstraint = NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0)
        subtitleTopConstraint = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0)
        subtitleLeadingConstraint = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0)
        
        //set landscape constraint
        titleCenterConstraint = NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
        
        subtitleCenterConstraint = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0)
        subtitleLeadingConstraintLandscape = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 10)
        
        self.addConstraint(NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0))

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
