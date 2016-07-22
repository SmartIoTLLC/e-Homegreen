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
    var subtitleBottomConstraint = NSLayoutConstraint()
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
        self.backgroundColor = UIColor.clearColor()
        
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.backgroundColor = UIColor.clearColor()
        titleView.font = UIFont.boldSystemFontOfSize(20)
        titleView.textColor = UIColor.whiteColor()
        titleView.setContentHuggingPriority(1000, forAxis: .Horizontal)
        titleView.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        self.addSubview(titleView)
        
        subtitleView.translatesAutoresizingMaskIntoConstraints = false
        subtitleView.backgroundColor = UIColor.clearColor()
        subtitleView.font = UIFont.boldSystemFontOfSize(13)
        subtitleView.textColor = UIColor.whiteColor()
        subtitleView.adjustsFontSizeToFitWidth = true
        self.addSubview(subtitleView)
        
        //set portrait constraint
        titleTopConstraint = NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
        titleLeadingConstraint = NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        subtitleTopConstraint = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: titleView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        subtitleLeadingConstraint = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0)
        
        //set landscape constraint
        titleCenterConstraint = NSLayoutConstraint(item: titleView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
        
        subtitleBottomConstraint = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: titleView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0)
        subtitleLeadingConstraintLandscape = NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: titleView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 10)
        
        self.addConstraint(NSLayoutConstraint(item: subtitleView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0))

        setPortraitTitle()
        
    }
    
    func setPortraitTitle(){
        
        self.removeConstraint(titleLeadingConstraint)
        self.removeConstraint(titleCenterConstraint)
        self.removeConstraint(subtitleBottomConstraint)
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
        self.addConstraint(subtitleBottomConstraint)
        self.addConstraint(subtitleLeadingConstraintLandscape)
        
    }
    
    func setTitleAndSubtitle(title:String, subtitle:String){
        titleView.text = title
        subtitleView.text = subtitle
    }

}
