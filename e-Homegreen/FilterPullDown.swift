//
//  FilterPullDown.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/15/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol FilterPullDownDelegate{
    func filterParametars (filterItem: FilterItem)
}

class FilterPullDown: UIScrollView {
    
    var filterDelegate : FilterPullDownDelegate?
    
    var bottom = NSLayoutConstraint()
    
    let contentView = UIView()
    let bottomLine = UIView()
    let pullView:UIImageView = UIImageView()
    
    //default value element
    let resetTimeButton:UIButton = UIButton()
    let secundsLabel:UILabel = UILabel()
    let secundsTextField:UITextField = UITextField()
    let minLabel:UILabel = UILabel()
    let minTextField:UITextField = UITextField()
    let hoursLabel:UILabel = UILabel()
    let hoursTextField:UITextField = UITextField()
    var setAsDefaultButton:CustomGradientButton = CustomGradientButton()
    
    //location
    let locationLabel:UILabel = UILabel()
    let chooseLocationButon:CustomGradientButton = CustomGradientButton()
    let resetLocationButton:UIButton = UIButton()
    
    //level
    let levelLabel:UILabel = UILabel()
    let chooseLevelButon:CustomGradientButton = CustomGradientButton()
    let resetLevelButton:UIButton = UIButton()
    
    //zone
    let zoneLabel:UILabel = UILabel()
    let chooseZoneButon:CustomGradientButton = CustomGradientButton()
    let resetZoneButton:UIButton = UIButton()
    
    //category
    let categoryLabel:UILabel = UILabel()
    let chooseCategoryButon:CustomGradientButton = CustomGradientButton()
    let resetCategoryButton:UIButton = UIButton()

    var button:UIButton!
    
    var location:Location?
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        
        self.delegate = self
        self.pagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Create and add content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        self.addSubview(contentView)
        
        //create and add bottom gray line
        bottomLine.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomLine)
        
        //create pull down image
        pullView.image = UIImage(named: "pulldown")
        pullView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pullView)
        
        //reset default button
        resetTimeButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetTimeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetTimeButton)
        
        // secunds label
        secundsLabel.text = "s"
        secundsLabel.textAlignment = .Center
        secundsLabel.textColor = UIColor.whiteColor()
        secundsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(secundsLabel)
        
        //secunds textfield
        secundsTextField.borderStyle = .RoundedRect
        secundsTextField.translatesAutoresizingMaskIntoConstraints = false
        secundsTextField.inputAccessoryView = CustomToolBar()
        secundsTextField.keyboardType = .NumberPad
        contentView.addSubview(secundsTextField)
        secundsTextField.backgroundColor = UIColor.whiteColor()
        
        //minutes label
        minLabel.text = "m"
        minLabel.textAlignment = .Center
        minLabel.textColor = UIColor.whiteColor()
        minLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(minLabel)
        
        //minutes textfield
        minTextField.borderStyle = .RoundedRect
        minTextField.translatesAutoresizingMaskIntoConstraints = false
        minTextField.inputAccessoryView = CustomToolBar()
        minTextField.keyboardType = .NumberPad
        contentView.addSubview(minTextField)
        minTextField.backgroundColor = UIColor.whiteColor()
        
        //hours label
        hoursLabel.text = "h"
        hoursLabel.textAlignment = .Center
        hoursLabel.textColor = UIColor.whiteColor()
        hoursLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hoursLabel)
        
        //hours text field
        hoursTextField.borderStyle = .RoundedRect
        hoursTextField.translatesAutoresizingMaskIntoConstraints = false
        hoursTextField.inputAccessoryView = CustomToolBar()
        hoursTextField.keyboardType = .NumberPad
        contentView.addSubview(hoursTextField)
        hoursTextField.backgroundColor = UIColor.whiteColor()
        
        //set as default button
        setAsDefaultButton.setTitle("SET AS DEFAULT", forState: .Normal)
        setAsDefaultButton.titleLabel!.numberOfLines = 1
        setAsDefaultButton.titleLabel!.adjustsFontSizeToFitWidth = true
        setAsDefaultButton.titleLabel!.lineBreakMode = NSLineBreakMode.ByClipping
        setAsDefaultButton.titleLabel?.font.fontWithSize(8)
        setAsDefaultButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(setAsDefaultButton)
        
        //location label
        locationLabel.text = "Location"
        locationLabel.textAlignment = .Left
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)
        
        //choose location button
        chooseLocationButon.setTitle("All", forState: .Normal)
        chooseLocationButon.addTarget(self, action: #selector(FilterPullDown.openLocations(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        chooseLocationButon.translatesAutoresizingMaskIntoConstraints = false
        chooseLocationButon.tag = 0
        contentView.addSubview(chooseLocationButon)
        
        //reset location
        resetLocationButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetLocationButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetLocationButton)
        
        //level label
        levelLabel.text = "Level"
        levelLabel.textAlignment = .Left
        levelLabel.textColor = UIColor.whiteColor()
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(levelLabel)
        
        //choose level button
        chooseLevelButon.setTitle("All", forState: .Normal)
        chooseLevelButon.translatesAutoresizingMaskIntoConstraints = false
        chooseLevelButon.addTarget(self, action: #selector(FilterPullDown.openLevels(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        chooseLevelButon.tag = 1
        contentView.addSubview(chooseLevelButon)
        
        //reset level
        resetLevelButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetLevelButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetLevelButton)
        
        //zone label
        zoneLabel.text = "Zone"
        zoneLabel.textAlignment = .Left
        zoneLabel.textColor = UIColor.whiteColor()
        zoneLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(zoneLabel)
        
        //choose zone button
        chooseZoneButon.setTitle("All", forState: .Normal)
        chooseZoneButon.translatesAutoresizingMaskIntoConstraints = false
        chooseZoneButon.addTarget(self, action: #selector(FilterPullDown.openZones(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        chooseZoneButon.tag = 2
        contentView.addSubview(chooseZoneButon)
        
        //reset zone
        resetZoneButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetZoneButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetZoneButton)
        
        //category label
        categoryLabel.text = "Category"
        categoryLabel.textAlignment = .Left
        categoryLabel.textColor = UIColor.whiteColor()
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        
        //choose category button
        chooseCategoryButon.setTitle("All", forState: .Normal)
        chooseCategoryButon.translatesAutoresizingMaskIntoConstraints = false
        chooseCategoryButon.addTarget(self, action: #selector(FilterPullDown.openCategories(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        chooseCategoryButon.tag = 3
        contentView.addSubview(chooseCategoryButon)
        
        //reset category
        resetCategoryButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetCategoryButton)
        
    }
    
    //MARK: Seetup constraint
    
    func setItem(view: UIView){
        
        //set content view constraint
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        bottom = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -600)
        self.addConstraint(bottom)
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))

        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0))
        
        
        setBottomLineAndPullDownImageConstraint()
        
        setDefaultValueConstraint()
        
        setLocationConstraint()
        
        setLevelConstraint()
        
        setZonesConstraint()
        
        setCategoryConstraint()
        

    }
    
    func setBottomLineAndPullDownImageConstraint(){
        //set bottomLine constraint
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0))
        bottomLine.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 2))
        
        //set pullDown image
        self.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
        
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60))
    }
    
    func setDefaultValueConstraint(){
        
        //reset value button
        contentView.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: resetTimeButton, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 10))
        resetTimeButton.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        resetTimeButton.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        //secunds label
        contentView.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: secundsLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: resetTimeButton, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        secundsLabel.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        secundsLabel.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20))
        
        //secunds text field
        contentView.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: secundsTextField, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: secundsLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        secundsTextField.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        secundsTextField.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        //minutes label
        contentView.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: minLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: secundsTextField, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        minLabel.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        minLabel.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20))
 
        //minutes text field
        contentView.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: minTextField, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: minLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        minTextField.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        minTextField.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        //hours lebel
        contentView.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: hoursLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: minTextField, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        hoursLabel.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        hoursLabel.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20))
        
        //hours text field
        contentView.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: hoursTextField, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: hoursLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        hoursTextField.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        hoursTextField.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        //set as default button
        contentView.addConstraint(NSLayoutConstraint(item: setAsDefaultButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: setAsDefaultButton, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 5))
        contentView.addConstraint(NSLayoutConstraint(item: setAsDefaultButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: hoursTextField, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    func setLocationConstraint(){
        
        //location label
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: setAsDefaultButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 30))
        locationLabel.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))
        
        //choose location button
        contentView.addConstraint(NSLayoutConstraint(item: chooseLocationButon, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: locationLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseLocationButon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: locationLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        //reset location
        contentView.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: chooseLocationButon, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: resetLocationButton, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 10))
        resetLocationButton.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        resetLocationButton.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        //choose location button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: chooseLocationButon, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
    }
    
    func setLevelConstraint(){

        // level label
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: locationLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 30))
        levelLabel.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))
        
        //choose level button
        contentView.addConstraint(NSLayoutConstraint(item: chooseLevelButon, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: levelLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseLevelButon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: levelLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))

        //reset level button
        contentView.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: chooseLevelButon, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: resetLevelButton, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 10))
        resetLevelButton.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        resetLevelButton.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        //choose level button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: chooseLevelButon, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
    }
    
    func setZonesConstraint(){

        //zone label
        contentView.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: levelLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 30))
        zoneLabel.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))

        //choose zone butoon
        contentView.addConstraint(NSLayoutConstraint(item: chooseZoneButon, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: zoneLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseZoneButon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: zoneLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        //reset zone
        contentView.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: chooseZoneButon, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: resetZoneButton, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 10))
        resetZoneButton.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        resetZoneButton.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        //choose zone trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: chooseZoneButon, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
    }
    
    func setCategoryConstraint(){

        //category label
        contentView.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: zoneLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 30))
        categoryLabel.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 80))

        //choose category label
        contentView.addConstraint(NSLayoutConstraint(item: chooseCategoryButon, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: categoryLabel, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseCategoryButon, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: categoryLabel, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))

        //reset category
        contentView.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: resetCategoryButton, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 10))
        resetCategoryButton.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        resetCategoryButton.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 35))
        
        // choose button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 20))
    }
    
    func openLocations(sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Location] = FilterController.shared.getLocationForFilterByUser()
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openFilterPopover(sender, popOverList:popoverList)
        }
    }
    
    func openLevels(sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location{
            let list:[Zone] = FilterController.shared.getLevelsByLocation(location)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openFilterPopover(sender, popOverList:popoverList)
        }
    }
    
    func openZones(sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location, let level = level{
            let list:[Zone] = FilterController.shared.getZoneByLevel(location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }

        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openFilterPopover(sender, popOverList:popoverList)
        }
    }
    
    func openCategories(sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location{
            let list:[Category] = FilterController.shared.getCategoriesByLocation(location)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openFilterPopover(sender, popOverList:popoverList)
        }
    }
    
    func setButtonTitle(text:String, id:String){
        switch button.tag{
        case 0:
            location = FilterController.shared.getLocationByObjectId(id)
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            break
        default:
            break
        }

        button.setTitle(text, forState: .Normal)
    }

}

extension FilterPullDown: UIScrollViewDelegate{
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if point.y > contentView.frame.size.height + 30 {
            return nil
        }
        return super.hitTest(point, withEvent: event)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0{
            guard let location = location else{
                filterDelegate?.filterParametars(FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All"))
                return
            }
            guard let level = level else{
                filterDelegate?.filterParametars(FilterItem(location: location.name!, levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All"))
                return
            }
            guard let zone = zoneSelected else{
                filterDelegate?.filterParametars(FilterItem(location: location.name!, levelId: level.id!.integerValue, zoneId: 0, categoryId: 0, levelName: level.name!, zoneName: "All", categoryName: "All"))
                return
            }
            guard let category = category else{
                filterDelegate?.filterParametars(FilterItem(location: location.name!, levelId: level.id!.integerValue, zoneId: zone.id!.integerValue, categoryId: 0, levelName: level.name!, zoneName: zone.name!, categoryName: "All"))
                return
            }
            filterDelegate?.filterParametars(FilterItem(location: location.name!, levelId: level.id!.integerValue, zoneId: zone.id!.integerValue, categoryId: category.id!.integerValue, levelName: level.name!, zoneName: zone.name!, categoryName: category.name!))
        }
    }
    
}


