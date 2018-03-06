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
    
    @objc fileprivate func resetTime() {
        hoursTextField.text = "0"
        minTextField.text = "0"
        secundsTextField.text = "0"
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
        resetTimeButton.addTarget(self, action: #selector(resetTime), for: .touchUpInside)
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
        setAsDefaultButton.addTarget(self, action: #selector(setDefaultParametar), for: .touchUpInside)
        contentView.addSubview(setAsDefaultButton)
        
        //location label
        locationLabel.text = "Location"
        locationLabel.textAlignment = .left
        locationLabel.textColor = UIColor.white
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)
        
        //choose location button
        chooseLocationButon.setTitle("All", for: UIControlState())
        chooseLocationButon.addTarget(self, action: #selector(openLocations(_:)), for: .touchUpInside)
        chooseLocationButon.translatesAutoresizingMaskIntoConstraints = false
        chooseLocationButon.tag = 0
        contentView.addSubview(chooseLocationButon)
        
        //reset location
        resetLocationButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetLocationButton.translatesAutoresizingMaskIntoConstraints = false
        resetLocationButton.addTarget(self, action: #selector(resetLocations(_:)), for: .touchUpInside)
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
        chooseLevelButon.addTarget(self, action: #selector(openLevels(_:)), for: .touchUpInside)
        chooseLevelButon.tag = 1
        contentView.addSubview(chooseLevelButon)
        
        //reset level
        resetLevelButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetLevelButton.translatesAutoresizingMaskIntoConstraints = false
        resetLevelButton.addTarget(self, action: #selector(resetLevel(_:)), for: .touchUpInside)
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
        chooseZoneButon.addTarget(self, action: #selector(openZones(_:)), for: .touchUpInside)
        chooseZoneButon.tag = 2
        contentView.addSubview(chooseZoneButon)
        
        //reset zone
        resetZoneButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetZoneButton.translatesAutoresizingMaskIntoConstraints = false
        resetZoneButton.addTarget(self, action: #selector(resetZone(_:)), for: .touchUpInside)
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
        chooseCategoryButon.addTarget(self, action: #selector(openCategories(_:)), for: .touchUpInside)
        chooseCategoryButon.tag = 3
        contentView.addSubview(chooseCategoryButon)
        
        //reset category
        resetCategoryButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        resetCategoryButton.addTarget(self, action: #selector(resetCategory(_:)), for: .touchUpInside)
        contentView.addSubview(resetCategoryButton)
        
        //GO button
        goButon.setTitle("Go", for: UIControlState())
        goButon.translatesAutoresizingMaskIntoConstraints = false
        goButon.addTarget(self, action: #selector(go), for: .touchUpInside)
        contentView.addSubview(goButon)
        
    }
    
    //MARK: Setup constraint
    
    func setItem(_ view: UIView){
        
        //set content view constraint
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        
        bottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -600)
        self.addConstraint(bottom)
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))

        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1, constant: 0))
        
        
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
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        contentView.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        bottomLine.addConstraint(NSLayoutConstraint(item: bottomLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2))
        
        //set pullDown image
        self.addConstraint(NSLayoutConstraint(item: pullView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: pullView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 37))
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 120))
        
        //setGreenIndicator
        self.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: -15))
        
        greenIndicator.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 12))
        greenIndicator.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
        
        //setRedIndicator
        self.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 15))
        
        redIndicator.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 12))
        redIndicator.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30))
    }
    
    func setDefaultValueConstraint(){
        
        //reset value button
        contentView.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: resetTimeButton, attribute: .trailing, multiplier: 1.0, constant: 10))
        resetTimeButton.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        resetTimeButton.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        
        //secunds label
        contentView.addConstraint(NSLayoutConstraint(item: resetTimeButton, attribute: .leading, relatedBy: .equal, toItem: secundsLabel, attribute: .trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: .centerY, relatedBy: .equal, toItem: resetTimeButton, attribute: .centerY, multiplier: 1, constant: 0))
        secundsLabel.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        secundsLabel.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        
        //secunds text field
        contentView.addConstraint(NSLayoutConstraint(item: secundsLabel, attribute: .leading, relatedBy: .equal, toItem: secundsTextField, attribute: .trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: .centerY, relatedBy: .equal, toItem: secundsLabel, attribute: .centerY, multiplier: 1, constant: 0))
        secundsTextField.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        secundsTextField.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        
        //minutes label
        contentView.addConstraint(NSLayoutConstraint(item: secundsTextField, attribute: .leading, relatedBy: .equal, toItem: minLabel, attribute: .trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: minLabel, attribute: .centerY, relatedBy: .equal, toItem: secundsTextField, attribute: .centerY, multiplier: 1, constant: 0))
        minLabel.addConstraint(NSLayoutConstraint(item: minLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        minLabel.addConstraint(NSLayoutConstraint(item: minLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
 
        //minutes text field
        contentView.addConstraint(NSLayoutConstraint(item: minLabel, attribute: .leading, relatedBy: .equal, toItem: minTextField, attribute: .trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: minTextField, attribute: .centerY, relatedBy: .equal, toItem: minLabel, attribute: .centerY, multiplier: 1, constant: 0))
        minTextField.addConstraint(NSLayoutConstraint(item: minTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        minTextField.addConstraint(NSLayoutConstraint(item: minTextField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        
        //hours lebel
        contentView.addConstraint(NSLayoutConstraint(item: minTextField, attribute: .leading, relatedBy: .equal, toItem: hoursLabel, attribute: .trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: .centerY, relatedBy: .equal, toItem: minTextField, attribute: .centerY, multiplier: 1, constant: 0))
        hoursLabel.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        hoursLabel.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20))
        
        //hours text field
        contentView.addConstraint(NSLayoutConstraint(item: hoursLabel, attribute: .leading, relatedBy: .equal, toItem: hoursTextField, attribute: .trailing, multiplier: 1.0, constant: 3))
        contentView.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: .centerY, relatedBy: .equal, toItem: hoursLabel, attribute: .centerY, multiplier: 1, constant: 0))
        hoursTextField.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        hoursTextField.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        
        //set as default button
        contentView.addConstraint(NSLayoutConstraint(item: setAsDefaultButton, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: hoursTextField, attribute: .leading, relatedBy: .equal, toItem: setAsDefaultButton, attribute: .trailing, multiplier: 1.0, constant: 5))
        contentView.addConstraint(NSLayoutConstraint(item: setAsDefaultButton, attribute: .centerY, relatedBy: .equal, toItem: hoursTextField, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func setLocationConstraint(){
        
        //location label
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: .top, relatedBy: .equal, toItem: setAsDefaultButton, attribute: .bottom, multiplier: 1.0, constant: 25))
        locationLabel.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))
        
        //choose location button
        contentView.addConstraint(NSLayoutConstraint(item: chooseLocationButon, attribute: .leading, relatedBy: .equal, toItem: locationLabel, attribute: .trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseLocationButon, attribute: .centerY, relatedBy: .equal, toItem: locationLabel, attribute: .centerY, multiplier: 1, constant: 0))
        
        //reset location
        contentView.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: .centerY, relatedBy: .equal, toItem: chooseLocationButon, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: resetLocationButton, attribute: .trailing, multiplier: 1.0, constant: 10))
        resetLocationButton.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        resetLocationButton.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        
        //choose location button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: chooseLocationButon, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 20))
    }
    
    func setLevelConstraint(){

        // level label
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: .top, relatedBy: .equal, toItem: locationLabel, attribute: .bottom, multiplier: 1.0, constant: 25))
        levelLabel.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))
        
        //choose level button
        contentView.addConstraint(NSLayoutConstraint(item: chooseLevelButon, attribute: .leading, relatedBy: .equal, toItem: levelLabel, attribute: .trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseLevelButon, attribute: .centerY, relatedBy: .equal, toItem: levelLabel, attribute: .centerY, multiplier: 1, constant: 0))

        //reset level button
        contentView.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: .centerY, relatedBy: .equal, toItem: chooseLevelButon, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: resetLevelButton, attribute: .trailing, multiplier: 1.0, constant: 10))
        resetLevelButton.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        resetLevelButton.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        
        //choose level button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetLevelButton, attribute: .leading, relatedBy: .equal, toItem: chooseLevelButon, attribute: .trailing, multiplier: 1.0, constant: 20))
    }
    
    func setZonesConstraint(){

        //zone label
        contentView.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: .top, relatedBy: .equal, toItem: levelLabel, attribute: .bottom, multiplier: 1.0, constant: 25))
        zoneLabel.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))

        //choose zone butoon
        contentView.addConstraint(NSLayoutConstraint(item: chooseZoneButon, attribute: .leading, relatedBy: .equal, toItem: zoneLabel, attribute: .trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseZoneButon, attribute: .centerY, relatedBy: .equal, toItem: zoneLabel, attribute: .centerY, multiplier: 1, constant: 0))
        
        //reset zone
        contentView.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: .centerY, relatedBy: .equal, toItem: chooseZoneButon, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: resetZoneButton, attribute: .trailing, multiplier: 1.0, constant: 10))
        resetZoneButton.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        resetZoneButton.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        
        //choose zone trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetZoneButton, attribute: .leading, relatedBy: .equal, toItem: chooseZoneButon, attribute: .trailing, multiplier: 1.0, constant: 20))
    }
    
    func setCategoryConstraint(){

        //category label
        contentView.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: .top, relatedBy: .equal, toItem: zoneLabel, attribute: .bottom, multiplier: 1.0, constant: 25))
        categoryLabel.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 80))

        //choose category label
        contentView.addConstraint(NSLayoutConstraint(item: chooseCategoryButon, attribute: .leading, relatedBy: .equal, toItem: categoryLabel, attribute: .trailing, multiplier: 1.0, constant: 20))
        contentView.addConstraint(NSLayoutConstraint(item: chooseCategoryButon, attribute: .centerY, relatedBy: .equal, toItem: categoryLabel, attribute: .centerY, multiplier: 1, constant: 0))

        //reset category
        contentView.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: .centerY, relatedBy: .equal, toItem: chooseCategoryButon, attribute: .centerY, multiplier: 1, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: resetCategoryButton, attribute: .trailing, multiplier: 1.0, constant: 10))
        resetCategoryButton.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        resetCategoryButton.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
        
        // choose button trailing
        contentView.addConstraint(NSLayoutConstraint(item: resetCategoryButton, attribute: .leading, relatedBy: .equal, toItem: chooseCategoryButon, attribute: .trailing, multiplier: 1.0, constant: 20))
    }
    
    func setGo(){
        
        //set go button constraints
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: .trailing, relatedBy: .equal, toItem: chooseCategoryButon, attribute: .trailing, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: .top, relatedBy: .equal, toItem: chooseCategoryButon, attribute: .bottom, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: .width, relatedBy: .equal, toItem: chooseCategoryButon, attribute: .width, multiplier: 0.5, constant: 0))
    }
    
    @objc func openLocations(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Location] = FilterController.shared.getLocationForFilterByUser()
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    @objc func resetLocations(_ sender : UIButton) {
        location = nil
        level = nil
        zoneSelected = nil
        category = nil
        chooseLocationButon.setTitle("All", for: UIControlState())
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseLevelButon.setTitle("All", for: UIControlState())
        chooseCategoryButon.setTitle("All", for: UIControlState())
    }
    
    @objc func openLevels(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location {
            let list:[Zone] = FilterController.shared.getLevelsByLocation(location)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    @objc func resetLevel(_ sender : UIButton) {
        level = nil
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseLevelButon.setTitle("All", for: UIControlState())
    }
    
    @objc func openZones(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location, let level = level {
            let list:[Zone] = FilterController.shared.getZoneByLevel(location, parentZone: level)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }

        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    @objc func resetZone(_ sender : UIButton) {
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControlState())
    }
    
    @objc func openCategories(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location{
            let list:[Category] = FilterController.shared.getCategoriesByLocation(location)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC {  vc.openPopover(sender, popOverList:popoverList) }
    }
    
    @objc func resetCategory(_ sender : UIButton) {
        category = nil
        chooseCategoryButon.setTitle("All", for: UIControlState())
    }
    
    func setButtonTitle(_ text:String, id:String) {
        switch button.tag {
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
    
    func setFilterItem(_ menu:Menu) {
        self.menuItem = menu
        if let filter = DatabaseFilterController.shared.getFilterByMenu(menu) {
            if filter.locationId != "All" {
                if let location = FilterController.shared.getLocationByObjectId(filter.locationId) { chooseLocationButon.setTitle(location.name, for: UIControlState()); self.location = location }
            } else { chooseLocationButon.setTitle("All", for: UIControlState()); self.location = nil }
            
            if filter.levelId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filter.levelId) { chooseLevelButon.setTitle(level.name, for: UIControlState()); self.level = level }
            } else { chooseLevelButon.setTitle("All", for: UIControlState()); self.level = nil }
            
            if filter.zoneId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filter.zoneId) { chooseZoneButon.setTitle(zone.name, for: UIControlState()); self.zoneSelected = zone }
            } else { chooseZoneButon.setTitle("All", for: UIControlState()); self.zoneSelected = nil }
            
            if filter.categoryId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filter.categoryId) { chooseCategoryButon.setTitle(category.name, for: UIControlState()); self.category = category }
            } else { chooseCategoryButon.setTitle("All", for: UIControlState()); self.category = nil }
            
        }
        returnFilter()
    }
    
    func setDefaultFilterItem(_ menu:Menu) {
        if let filter = DatabaseFilterController.shared.getDefaultFilterByMenu(menu) {
            if filter.locationId != "All" {
                if let location = FilterController.shared.getLocationByObjectId(filter.locationId) { chooseLocationButon.setTitle(location.name, for: UIControlState()); self.location = location }
            } else { chooseLocationButon.setTitle("All", for: UIControlState()); self.location = nil }
            
            if filter.levelId != "All" {
                if let level = FilterController.shared.getZoneByObjectId(filter.levelId) { chooseLevelButon.setTitle(level.name, for: UIControlState()); self.level = level }
            } else { chooseLevelButon.setTitle("All", for: UIControlState()); self.level = nil }
            
            if filter.zoneId != "All" {
                if let zone = FilterController.shared.getZoneByObjectId(filter.zoneId) { chooseZoneButon.setTitle(zone.name, for: UIControlState()); self.zoneSelected = zone }
            } else { chooseZoneButon.setTitle("All", for: UIControlState()); self.zoneSelected = nil }
            
            if filter.categoryId != "All" {
                if let category = FilterController.shared.getCategoryByObjectId(filter.categoryId) { chooseCategoryButon.setTitle(category.name, for: UIControlState()); self.category = category }
            } else { chooseCategoryButon.setTitle("All", for: UIControlState()); self.category = nil }
            
        }
        returnFilter()
    }
    
    @objc func setDefaultParametar(){
        guard let h = hoursTextField.text else { return }
        guard let m = minTextField.text else { return }
        guard let s = secundsTextField.text else { return }
        
        guard let hours = Int(h) else { return }
        guard let minutes = Int(m) else { return }
        guard let socunds  = Int(s) else { return }
        
        let filterItem = FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")
        if let location = location {
            if let locationName = location.name { filterItem.location = locationName }
            filterItem.locationObjectId = location.objectID.uriRepresentation().absoluteString
        }
        if let category = category {
            if let categoryId = category.id?.intValue { filterItem.categoryId = categoryId }
            if let categoryName = category.name { filterItem.categoryName = categoryName }
            filterItem.categoryObjectId = category.objectID.uriRepresentation().absoluteString
        }
        if let level = level {
            if let levelId = level.id?.intValue { filterItem.levelId = levelId }
            if let levelName = level.name { filterItem.levelName = levelName }
            filterItem.levelObjectId = level.objectID.uriRepresentation().absoluteString
        }

        if let zone = zoneSelected {
            if let zoneId = zone.id?.intValue { filterItem.zoneId = zoneId }
            if let zoneName = zone.name { filterItem.zoneName = zoneName }
            filterItem.zoneObjectId = zone.objectID.uriRepresentation().absoluteString
        }
        
        let time = socunds + minutes*60 + hours*3600
        
        DatabaseFilterController.shared.saveDeafultFilter(filterItem, menu: menuItem, time: time)
        
        filterDelegate?.saveDefaultFilter()
    }
    
    @objc func go() {
        returnFilter()
        
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
        self.setContentOffset(bottomOffset, animated: true)
    }
    
    func returnFilter() {
        let filterItem = FilterItem(location: "All", levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")
        guard let location = location else { filterDelegate?.filterParametars(filterItem); return }
        
        if let locationName = location.name { filterItem.location = locationName }
        //filterItem.location = location.name! // nije dobro - puca
        // TODO:
        // BUG:
        /*
         Kada u Remote ostane ucitana lokacija na filteru a lokacija se posle obrise, puci ce kada se ponovo udje na Remote ekran a ta vec ucitana lokacija je nil
         */
        filterItem.locationObjectId = location.objectID.uriRepresentation().absoluteString
        
        if let category = category {
            if let categoryId = category.id?.intValue { filterItem.categoryId = categoryId }
            if let categoryName = category.name { filterItem.categoryName = categoryName }
            filterItem.categoryObjectId = category.objectID.uriRepresentation().absoluteString
        }
        
        guard let level = level else { filterDelegate?.filterParametars(filterItem); return }
        if let levelId = level.id?.intValue { filterItem.levelId = levelId }
        if let levelName = level.name { filterItem.levelName = levelName }
        filterItem.levelObjectId = level.objectID.uriRepresentation().absoluteString
        
        guard let zone = zoneSelected else { filterDelegate?.filterParametars(filterItem); return }
        if let zoneId = zone.id?.intValue { filterItem.zoneId = zoneId }
        if let zoneName = zone.name { filterItem.zoneName = zoneName }
        filterItem.zoneObjectId = zone.objectID.uriRepresentation().absoluteString
        filterDelegate?.filterParametars(filterItem)
    }
    
    @objc func updateIndicator(_ notification:Notification) {
        if let info = notification.userInfo as? [String:String] {
            
            if let lamp = info["lamp"] {
                if lamp == "red" {
                    redIndicator.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)

                    self.redIndicator.alpha = 1
                    UIView.animate(withDuration: 0.5, animations: {
                        self.redIndicator.alpha = 0
                        }, completion: { (Bool) in
                            self.redIndicator.backgroundColor = UIColor.clear
                            self.greenIndicator.backgroundColor = UIColor.clear

                    })
                } else if lamp == "green" {
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateIndicator(_:)), name: NSNotification.Name(rawValue: NotificationKey.IndicatorLamp), object: nil)
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.IndicatorLamp), object: nil)
    }


}

extension FilterPullDown: UIScrollViewDelegate{
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if point.y > contentView.frame.size.height + 43 { return nil }
        if point.y > contentView.frame.size.height && (point.x < contentView.frame.size.width/2 - 75 || point.x > contentView.frame.size.width/2 + 75) { return nil }
        return super.hitTest(point, with: event)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 { returnFilter() }
    }
    
}


