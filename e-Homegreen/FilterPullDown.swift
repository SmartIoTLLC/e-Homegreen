//
//  FilterPullDown.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/15/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol FilterPullDownDelegate{
    func filterParametars (_ filterItem: FilterItem)
    func saveDefaultFilter()
}

class FilterPullDown: UIScrollView {
    
    var filterDelegate : FilterPullDownDelegate?
    
    var bottom = NSLayoutConstraint()
    
    let contentView = UIView()
    let bottomLine = UIView()
    let pullView:UIImageView = UIImageView()
    
    let redIndicator = UIView()
    let greenIndicator = UIView()
    
    //default value element
    let resetTimeButton:UIButton = UIButton()
    let secundsLabel:UILabel = UILabel()
    let secundsTextField:EditTextField = EditTextField()
    let minLabel:UILabel = UILabel()
    let minTextField:EditTextField = EditTextField()
    let hoursLabel:UILabel = UILabel()
    let hoursTextField:EditTextField = EditTextField()
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
    
    // go button
    let goButon:CustomGradientButton = CustomGradientButton()
    
    var button:UIButton!
    
    var location:Location?
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    var menuItem:Menu!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        removeObservers()
    }

    func commonInit(){
        
        addObservers()
        
        self.delegate = self
        self.isPagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Create and add content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        self.addSubview(contentView)
        
        //create and add bottom gray line
        bottomLine.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomLine)
        
        //create signal indicators
        greenIndicator.backgroundColor = UIColor.clear
        greenIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(greenIndicator)
        redIndicator.backgroundColor = UIColor.clear
        redIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(redIndicator)
        
        //create pull down image
        pullView.image = UIImage(named: "pulldown")
        pullView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pullView)
        
        //reset default button
        resetTimeButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetTimeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetTimeButton)
        
        // secunds label
        secundsLabel.text = "s"
        secundsLabel.textAlignment = .center
        secundsLabel.textColor = UIColor.white
        secundsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(secundsLabel)
        
        //secunds textfield
        secundsTextField.borderStyle = .roundedRect
        secundsTextField.translatesAutoresizingMaskIntoConstraints = false
        secundsTextField.inputAccessoryView = CustomToolBar()
        secundsTextField.keyboardType = .numberPad
        contentView.addSubview(secundsTextField)
        secundsTextField.text = "0"
        secundsTextField.backgroundColor = UIColor.white
        
        //minutes label
        minLabel.text = "m"
        minLabel.textAlignment = .center
        minLabel.textColor = UIColor.white
        minLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(minLabel)
        
        //minutes textfield
        minTextField.borderStyle = .roundedRect
        minTextField.translatesAutoresizingMaskIntoConstraints = false
        minTextField.inputAccessoryView = CustomToolBar()
        minTextField.keyboardType = .numberPad
        contentView.addSubview(minTextField)
        minTextField.text = "0"
        minTextField.backgroundColor = UIColor.white
        
        //hours label
        hoursLabel.text = "h"
        hoursLabel.textAlignment = .center
        hoursLabel.textColor = UIColor.white
        hoursLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hoursLabel)
        
        //hours text field
        hoursTextField.borderStyle = .roundedRect
        hoursTextField.translatesAutoresizingMaskIntoConstraints = false
        hoursTextField.inputAccessoryView = CustomToolBar()
        hoursTextField.keyboardType = .numberPad
        contentView.addSubview(hoursTextField)
        hoursTextField.text = "0"
        hoursTextField.backgroundColor = UIColor.white
        
        //set as default button
        setAsDefaultButton.setTitle("SET AS DEFAULT", for: UIControlState())
        setAsDefaultButton.titleLabel!.numberOfLines = 1
        setAsDefaultButton.titleLabel!.adjustsFontSizeToFitWidth = true
        setAsDefaultButton.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        setAsDefaultButton.titleLabel?.font.withSize(8)
        setAsDefaultButton.translatesAutoresizingMaskIntoConstraints = false
        setAsDefaultButton.addTarget(self, action: #selector(FilterPullDown.setDefaultParametar), for: UIControlEvents.touchUpInside)
        contentView.addSubview(setAsDefaultButton)
        
        //location label
        locationLabel.text = "Location"
        locationLabel.textAlignment = .left
        locationLabel.textColor = UIColor.white
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)
        
        //choose location button
        chooseLocationButon.setTitle("All", for: UIControlState())
        chooseLocationButon.addTarget(self, action: #selector(FilterPullDown.openLocations(_:)), for: UIControlEvents.touchUpInside)
        chooseLocationButon.translatesAutoresizingMaskIntoConstraints = false
        chooseLocationButon.tag = 0
        contentView.addSubview(chooseLocationButon)
        
        //reset location
        resetLocationButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetLocationButton.translatesAutoresizingMaskIntoConstraints = false
        resetLocationButton.addTarget(self, action: #selector(FilterPullDown.resetLocations(_:)), for: UIControlEvents.touchUpInside)
        contentView.addSubview(resetLocationButton)
        
        //level label
        levelLabel.text = "Level"
        levelLabel.textAlignment = .left
        levelLabel.textColor = UIColor.white
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(levelLabel)
        
        //choose level button
        chooseLevelButon.setTitle("All", for: UIControlState())
        chooseLevelButon.translatesAutoresizingMaskIntoConstraints = false
        chooseLevelButon.addTarget(self, action: #selector(FilterPullDown.openLevels(_:)), for: UIControlEvents.touchUpInside)
        chooseLevelButon.tag = 1
        contentView.addSubview(chooseLevelButon)
        
        //reset level
        resetLevelButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetLevelButton.translatesAutoresizingMaskIntoConstraints = false
        resetLevelButton.addTarget(self, action: #selector(FilterPullDown.resetLevel(_:)), for: UIControlEvents.touchUpInside)
        contentView.addSubview(resetLevelButton)
        
        //zone label
        zoneLabel.text = "Zone"
        zoneLabel.textAlignment = .left
        zoneLabel.textColor = UIColor.white
        zoneLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(zoneLabel)
        
        //choose zone button
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseZoneButon.translatesAutoresizingMaskIntoConstraints = false
        chooseZoneButon.addTarget(self, action: #selector(FilterPullDown.openZones(_:)), for: UIControlEvents.touchUpInside)
        chooseZoneButon.tag = 2
        contentView.addSubview(chooseZoneButon)
        
        //reset zone
        resetZoneButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetZoneButton.translatesAutoresizingMaskIntoConstraints = false
        resetZoneButton.addTarget(self, action: #selector(FilterPullDown.resetZone(_:)), for: UIControlEvents.touchUpInside)
        contentView.addSubview(resetZoneButton)
        
        //category label
        categoryLabel.text = "Category"
        categoryLabel.textAlignment = .left
        categoryLabel.textColor = UIColor.white
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        
        //choose category button
        chooseCategoryButon.setTitle("All", for: UIControlState())
        chooseCategoryButon.translatesAutoresizingMaskIntoConstraints = false
        chooseCategoryButon.addTarget(self, action: #selector(FilterPullDown.openCategories(_:)), for: UIControlEvents.touchUpInside)
        chooseCategoryButon.tag = 3
        contentView.addSubview(chooseCategoryButon)
        
        //reset category
        resetCategoryButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        resetCategoryButton.addTarget(self, action: #selector(FilterPullDown.resetCategory(_:)), for: UIControlEvents.touchUpInside)
        contentView.addSubview(resetCategoryButton)
        
        //GO button
        goButon.setTitle("Go", for: UIControlState())
        goButon.translatesAutoresizingMaskIntoConstraints = false
        goButon.addTarget(self, action: #selector(FilterPullDown.go), for: UIControlEvents.touchUpInside)
        contentView.addSubview(goButon)
        
    }
    
    //MARK: Seetup constraint
    
    func setItem(_ view: UIView){
        
        //set content view constraint
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        
        bottom = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: -600)
        self.addConstraint(bottom)
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
        
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))

        view.addConstraint(NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0))
        
        
        setBottomLineAndPullDownImageConstraint()
        
        setDefaultValueConstraint()
        
        setLocationConstraint()
        
        setLevelConstraint()
        
        setZonesConstraint()
        
        setCategoryConstraint()
        
        setGo()

    }
    
    func setBottomLineAndPullDownImageConstraint(){
        //set bottomLine constraint
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0))
        bottomLine.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 2))
        
        //set pullDown image
        self.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 37))
        
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 120))
        
        //setGreenIndicator
        self.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -15))
        
        greenIndicator.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 12))
        
        greenIndicator.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30))
        
        //setRedIndicator
        self.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 15))
        
        redIndicator.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 12))
        
        redIndicator.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30))


    }
    
    func setDefaultValueConstraint(){
        
        //reset value button
        contentView.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: resetTimeButton, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 10))
        resetTimeButton.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        resetTimeButton.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        
        //secunds label
        contentView.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: secundsLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: resetTimeButton, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        secundsLabel.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        secundsLabel.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20))
        
        //secunds text field
        contentView.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: secundsTextField, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: secundsLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        secundsTextField.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        secundsTextField.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
        
        //minutes label
        contentView.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: minLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: secundsTextField, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        minLabel.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        minLabel.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20))
 
        //minutes text field
        contentView.addConstraint(NSLayoutConstraint(item: minLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: minTextField, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: minLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        minTextField.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        minTextField.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
        
        //hours lebel
        contentView.addConstraint(NSLayoutConstraint(item: minTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: hoursLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: minTextField, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        hoursLabel.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        hoursLabel.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20))
        
        //hours text field
        contentView.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: hoursTextField, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: hoursLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        hoursTextField.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        hoursTextField.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
        
        //set as default button
        contentView.addConstraint(NSLayoutConstraint(item: setAsDefaultButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: setAsDefaultButton, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 5))
        contentView.addConstraint(NSLayoutConstraint(item: setAsDefaultButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: hoursTextField, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
    }
    
    func setLocationConstraint(){
        
        //location label
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: setAsDefaultButton, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 25))
        locationLabel.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 80))
        
        //choose location button
        contentView.addConstraint(NSLayoutConstraint(item: chooseLocationButon, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: locationLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseLocationButon, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: locationLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        //reset location
        contentView.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: chooseLocationButon, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: resetLocationButton, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 10))
        resetLocationButton.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        resetLocationButton.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        
        //choose location button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: chooseLocationButon, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
    }
    
    func setLevelConstraint(){

        // level label
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: locationLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 25))
        levelLabel.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 80))
        
        //choose level button
        contentView.addConstraint(NSLayoutConstraint(item: chooseLevelButon, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: levelLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseLevelButon, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: levelLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))

        //reset level button
        contentView.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: chooseLevelButon, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: resetLevelButton, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 10))
        resetLevelButton.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        resetLevelButton.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        
        //choose level button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: chooseLevelButon, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
    }
    
    func setZonesConstraint(){

        //zone label
        contentView.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: levelLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 25))
        zoneLabel.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 80))

        //choose zone butoon
        contentView.addConstraint(NSLayoutConstraint(item: chooseZoneButon, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: zoneLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseZoneButon, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: zoneLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        //reset zone
        contentView.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: chooseZoneButon, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: resetZoneButton, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 10))
        resetZoneButton.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        resetZoneButton.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        
        //choose zone trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: chooseZoneButon, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
    }
    
    func setCategoryConstraint(){

        //category label
        contentView.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: contentView, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: zoneLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 25))
        categoryLabel.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 80))

        //choose category label
        contentView.addConstraint(NSLayoutConstraint(item: chooseCategoryButon, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: categoryLabel, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseCategoryButon, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: categoryLabel, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))

        //reset category
        contentView.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: resetCategoryButton, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 10))
        resetCategoryButton.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        resetCategoryButton.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 35))
        
        // choose button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
    }
    
    func setGo(){
        
        //set go button constraints
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.width, multiplier: 0.5, constant: 0))
    }
    
    func openLocations(_ sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Location] = FilterController.shared.getLocationForFilterByUser()
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openPopover(sender, popOverList:popoverList)
        }
    }
    
    func resetLocations(_ sender : UIButton){
        location = nil
        level = nil
        zoneSelected = nil
        category = nil
        chooseLocationButon.setTitle("All", for: UIControlState())
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseLevelButon.setTitle("All", for: UIControlState())
        chooseCategoryButon.setTitle("All", for: UIControlState())
    }
    
    func openLevels(_ sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location{
            let list:[Zone] = FilterController.shared.getLevelsByLocation(location)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openPopover(sender, popOverList:popoverList)
        }
    }
    
    func resetLevel(_ sender : UIButton){
        level = nil
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseLevelButon.setTitle("All", for: UIControlState())
    }
    
    func openZones(_ sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location, let level = level{
            let list:[Zone] = FilterController.shared.getZoneByLevel(location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
            }
        }

        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openPopover(sender, popOverList:popoverList)
        }
    }
    
    func resetZone(_ sender : UIButton){
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControlState())
    }
    
    func openCategories(_ sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location{
            let list:[Category] = FilterController.shared.getCategoriesByLocation(location)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openPopover(sender, popOverList:popoverList)
        }
    }
    
    func resetCategory(_ sender : UIButton){
        category = nil
        chooseCategoryButon.setTitle("All", for: UIControlState())
    }
    
    func setButtonTitle(_ text:String, id:String){
        switch button.tag{
        case 0:
            location = FilterController.shared.getLocationByObjectId(id)
            level = nil
            zoneSelected = nil
            category = nil
            chooseLevelButon.setTitle("All", for: UIControlState())
            chooseZoneButon.setTitle("All", for: UIControlState())
            chooseCategoryButon.setTitle("All", for: UIControlState())
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            zoneSelected = nil
            chooseZoneButon.setTitle("All", for: UIControlState())
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

        button.setTitle(text, for: UIControlState())
    }
    
    func setFilterItem(_ menu:Menu){
        self.menuItem = menu
        if let filter = DatabaseFilterController.shared.getFilterByMenu(menu){
            if filter.locationId != "All"{
                if let location = FilterController.shared.getLocationByObjectId(filter.locationId){
                    chooseLocationButon.setTitle(location.name, for: UIControlState())
                    self.location = location
                }
            }else{
                chooseLocationButon.setTitle("All", for: UIControlState())
                self.location = nil
            }
            if filter.levelId != "All"{
                if let level = FilterController.shared.getZoneByObjectId(filter.levelId){
                    chooseLevelButon.setTitle(level.name, for: UIControlState())
                    self.level = level
                }
            }else{
                chooseLevelButon.setTitle("All", for: UIControlState())
                self.level = nil
            }
            if filter.zoneId != "All"{
                if let zone = FilterController.shared.getZoneByObjectId(filter.zoneId){
                    chooseZoneButon.setTitle(zone.name, for: UIControlState())
                    self.zoneSelected = zone
                }
            }else{
                chooseZoneButon.setTitle("All", for: UIControlState())
                self.zoneSelected = nil
            }
            if filter.categoryId != "All"{
                if let category = FilterController.shared.getCategoryByObjectId(filter.categoryId){
                    chooseCategoryButon.setTitle(category.name, for: UIControlState())
                    self.category = category
                }
            }else{
                chooseCategoryButon.setTitle("All", for: UIControlState())
                self.category = nil
            }
        }
        returnFilter()
    }
    
    func setDefaultFilterItem(_ menu:Menu){
        if let filter = DatabaseFilterController.shared.getDefaultFilterByMenu(menu){
            if filter.locationId != "All"{
                if let location = FilterController.shared.getLocationByObjectId(filter.locationId){
                    chooseLocationButon.setTitle(location.name, for: UIControlState())
                    self.location = location
                }
            }else{
                chooseLocationButon.setTitle("All", for: UIControlState())
                self.location = nil
            }
            if filter.levelId != "All"{
                if let level = FilterController.shared.getZoneByObjectId(filter.levelId){
                    chooseLevelButon.setTitle(level.name, for: UIControlState())
                    self.level = level
                }
            }else{
                chooseLevelButon.setTitle("All", for: UIControlState())
                self.level = nil
            }
            if filter.zoneId != "All"{
                if let zone = FilterController.shared.getZoneByObjectId(filter.zoneId){
                    chooseZoneButon.setTitle(zone.name, for: UIControlState())
                    self.zoneSelected = zone
                }
            }else{
                chooseZoneButon.setTitle("All", for: UIControlState())
                self.zoneSelected = nil
            }
            if filter.categoryId != "All"{
                if let category = FilterController.shared.getCategoryByObjectId(filter.categoryId){
                    chooseCategoryButon.setTitle(category.name, for: UIControlState())
                    self.category = category
                }
            }else{
                chooseCategoryButon.setTitle("All", for: UIControlState())
                self.category = nil
            }
        }
        returnFilter()
    }
    
    func setDefaultParametar(){
        guard let h = hoursTextField.text else {
            return
        }
        guard let m = minTextField.text else {
            return
        }
        guard let s = secundsTextField.text else {
            return
        }
        
        guard let hours = Int(h) else {
            return
        }
        guard let minutes = Int(m) else{
            return
        }
        guard let socunds  = Int(s) else{
            return
        }
        
        let filterItem = FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")
        if let location = location {
            filterItem.location = location.name!
            filterItem.locationObjectId = location.objectID.uriRepresentation().absoluteString
        }
        if let category = category{
            filterItem.categoryId = category.id!.intValue
            filterItem.categoryName = category.name!
            filterItem.categoryObjectId = category.objectID.uriRepresentation().absoluteString
        }
        if let level = level {
            filterItem.levelId = level.id!.intValue
            filterItem.levelName = level.name!
            filterItem.levelObjectId = level.objectID.uriRepresentation().absoluteString
        }

        if let zone = zoneSelected {
            filterItem.zoneId = zone.id!.intValue
            filterItem.zoneName = zone.name!
            filterItem.zoneObjectId = zone.objectID.uriRepresentation().absoluteString
        }
        
        let time = socunds + minutes*60 + hours*3600
        
        DatabaseFilterController.shared.saveDeafultFilter(filterItem, menu: menuItem, time: time)
        
        filterDelegate?.saveDefaultFilter()
    }
    
    func go(){
        
        returnFilter()
        
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
        self.setContentOffset(bottomOffset, animated: true)
        
    }
    
    func returnFilter(){
        let filterItem = FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")
        guard let location = location else{
            filterDelegate?.filterParametars(filterItem)
            return
        }
        filterItem.location = location.name!
        filterItem.locationObjectId = location.objectID.uriRepresentation().absoluteString
        if let category = category{
            filterItem.categoryId = category.id!.intValue
            filterItem.categoryName = category.name!
            filterItem.categoryObjectId = category.objectID.uriRepresentation().absoluteString
        }
        guard let level = level else{
            filterDelegate?.filterParametars(filterItem)
            return
        }
        
        filterItem.levelId = level.id!.intValue
        filterItem.levelName = level.name!        
        filterItem.levelObjectId = level.objectID.uriRepresentation().absoluteString
        guard let zone = zoneSelected else{
            filterDelegate?.filterParametars(filterItem)
            return
        }
        filterItem.zoneId = zone.id!.intValue
        filterItem.zoneName = zone.name!
        filterItem.zoneObjectId = zone.objectID.uriRepresentation().absoluteString
        filterDelegate?.filterParametars(filterItem)
    }
    
    func updateIndicator(_ notification:Notification){
        if let info = (notification as NSNotification).userInfo as? [String:String]{
            
            if let lamp = info["lamp"]{
                if lamp == "red" {
                    redIndicator.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)

                    self.redIndicator.alpha = 1
                    UIView.animate(withDuration: 0.5, animations: {
                        self.redIndicator.alpha = 0
                        }, completion: { (Bool) in
                            self.redIndicator.backgroundColor = UIColor.clear
                            self.greenIndicator.backgroundColor = UIColor.clear

                    })
                }else if lamp == "green" {
                    greenIndicator.backgroundColor = UIColor(red: 24/255, green: 202/255, blue: 0/255, alpha: 1.0)

                    self.greenIndicator.alpha = 1
                    UIView.animate(withDuration: 0.5, animations: {
                        self.greenIndicator.alpha = 0
                        }, completion: { (Bool) in
                            self.redIndicator.backgroundColor = UIColor.clear
                            self.greenIndicator.backgroundColor = UIColor.clear
                    })
                }
            }
        }
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(FilterPullDown.updateIndicator(_:)), name: NSNotification.Name(rawValue: NotificationKey.IndicatorLamp), object: nil)
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.IndicatorLamp), object: nil)
    }


}

extension FilterPullDown: UIScrollViewDelegate{
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if point.y > contentView.frame.size.height + 43{
            return nil
        }
        if point.y > contentView.frame.size.height && (point.x < contentView.frame.size.width/2 - 75 || point.x > contentView.frame.size.width/2 + 75) {
            return nil
        }
        return super.hitTest(point, with: event)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0{
            
            returnFilter()
        }
    }
    
}


