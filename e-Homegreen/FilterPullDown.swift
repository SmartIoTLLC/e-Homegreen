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
        contentView.addSubview(bottomLine)
        
        //create signal indicators
        greenIndicator.backgroundColor = UIColor.clear
        self.addSubview(greenIndicator)
        redIndicator.backgroundColor = UIColor.clear
        self.addSubview(redIndicator)
        
        //create pull down image
        pullView.image = UIImage(named: "pulldown")
        self.addSubview(pullView)
        
        //reset default button
        resetTimeButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetTimeButton.addTarget(self, action: #selector(resetTime), for: .touchUpInside)
        contentView.addSubview(resetTimeButton)
        
        // secunds label
        secundsLabel.text = "s"
        secundsLabel.textAlignment = .center
        secundsLabel.textColor = UIColor.white
        contentView.addSubview(secundsLabel)
        
        //secunds textfield
        secundsTextField.borderStyle = .roundedRect
        secundsTextField.inputAccessoryView = CustomToolBar()
        secundsTextField.keyboardType = .numberPad
        contentView.addSubview(secundsTextField)
        secundsTextField.text = "0"
        secundsTextField.backgroundColor = UIColor.white
        
        //minutes label
        minLabel.text = "m"
        minLabel.textAlignment = .center
        minLabel.textColor = UIColor.white
        contentView.addSubview(minLabel)
        
        //minutes textfield
        minTextField.borderStyle = .roundedRect
        minTextField.inputAccessoryView = CustomToolBar()
        minTextField.keyboardType = .numberPad
        contentView.addSubview(minTextField)
        minTextField.text = "0"
        minTextField.backgroundColor = UIColor.white
        
        //hours label
        hoursLabel.text = "h"
        hoursLabel.textAlignment = .center
        hoursLabel.textColor = UIColor.white
        contentView.addSubview(hoursLabel)
        
        //hours text field
        hoursTextField.borderStyle = .roundedRect
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
        chooseLocationButon.tag = 0
        contentView.addSubview(chooseLocationButon)
        
        //reset location
        resetLocationButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetLocationButton.addTarget(self, action: #selector(resetLocations(_:)), for: .touchUpInside)
        contentView.addSubview(resetLocationButton)
        
        //level label
        levelLabel.text = "Level"
        levelLabel.textAlignment = .left
        levelLabel.textColor = UIColor.white
        contentView.addSubview(levelLabel)
        
        //choose level button
        chooseLevelButon.setTitle("All", for: UIControlState())
        chooseLevelButon.addTarget(self, action: #selector(openLevels(_:)), for: .touchUpInside)
        chooseLevelButon.tag = 1
        contentView.addSubview(chooseLevelButon)
        
        //reset level
        resetLevelButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetLevelButton.addTarget(self, action: #selector(resetLevel(_:)), for: .touchUpInside)
        contentView.addSubview(resetLevelButton)
        
        //zone label
        zoneLabel.text = "Zone"
        zoneLabel.textAlignment = .left
        zoneLabel.textColor = UIColor.white
        contentView.addSubview(zoneLabel)
        
        //choose zone button
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseZoneButon.addTarget(self, action: #selector(openZones(_:)), for: .touchUpInside)
        chooseZoneButon.tag = 2
        contentView.addSubview(chooseZoneButon)
        
        //reset zone
        resetZoneButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetZoneButton.addTarget(self, action: #selector(resetZone(_:)), for: .touchUpInside)
        contentView.addSubview(resetZoneButton)
        
        //category label
        categoryLabel.text = "Category"
        categoryLabel.textAlignment = .left
        categoryLabel.textColor = UIColor.white
        contentView.addSubview(categoryLabel)
        
        //choose category button
        chooseCategoryButon.setTitle("All", for: UIControlState())
        chooseCategoryButon.addTarget(self, action: #selector(openCategories(_:)), for: .touchUpInside)
        chooseCategoryButon.tag = 3
        contentView.addSubview(chooseCategoryButon)
        
        //reset category
        resetCategoryButton.setImage(UIImage(named: "exit"), for: UIControlState())
        resetCategoryButton.addTarget(self, action: #selector(resetCategory(_:)), for: .touchUpInside)
        contentView.addSubview(resetCategoryButton)
        
        //GO button
        goButon.setTitle("Go", for: UIControlState())
        goButon.addTarget(self, action: #selector(go), for: .touchUpInside)
        contentView.addSubview(goButon)
        
    }
    
    //MARK: Seetup constraint
    
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
    
    func setBottomLineAndPullDownImageConstraint() {
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(2)
        }
        
        pullView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(37)
            make.width.equalTo(120)
        }
        
        greenIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom)
            make.centerX.equalToSuperview().inset(-15)
            make.height.equalTo(12)
            make.width.equalTo(30)
        }
        
        redIndicator.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom)
            make.centerX.equalToSuperview().offset(15)
            make.height.equalTo(12)
            make.width.equalTo(30)
        }

    }
    
    func setDefaultValueConstraint(){
        resetTimeButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }
        
        secundsLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(resetTimeButton.snp.centerY)
            make.trailing.equalTo(resetTimeButton.snp.leading).inset(-3)
            make.height.equalTo(35)
            make.width.equalTo(20)
        }
        
        secundsTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(secundsLabel.snp.centerY)
            make.trailing.equalTo(secundsLabel.snp.leading).inset(-3)
            make.height.equalTo(35)
            make.width.equalTo(40)
        }

        minLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(secundsTextField.snp.centerY)
            make.trailing.equalTo(secundsTextField.snp.leading).inset(-3)
            make.height.equalTo(35)
            make.width.equalTo(20)
        }
 
        minTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(minLabel.snp.centerY)
            make.trailing.equalTo(minLabel.snp.leading).inset(-3)
            make.height.equalTo(35)
            make.width.equalTo(40)
        }
        
        hoursLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minTextField.snp.centerY)
            make.trailing.equalTo(minTextField.snp.leading).inset(-3)
            make.height.equalTo(35)
            make.width.equalTo(20)
        }

        hoursTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(hoursLabel.snp.centerY)
            make.trailing.equalTo(hoursLabel.snp.leading).inset(-3)
            make.height.equalTo(35)
            make.width.equalTo(40)
        }
        
        setAsDefaultButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(hoursTextField.snp.centerY)
            make.height.equalTo(35)
            make.trailing.equalTo(hoursTextField.snp.leading).offset(-5)
            make.leading.equalToSuperview().offset(10)
        }
        
    }
    
    func setLocationConstraint() {
        locationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(setAsDefaultButton.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(35)
            make.width.equalTo(80)
        }
        
        chooseLocationButon.snp.makeConstraints { (make) in
            make.centerY.equalTo(locationLabel.snp.centerY)
            make.leading.equalTo(locationLabel.snp.trailing).offset(20)
            make.trailing.equalTo(resetLocationButton.snp.leading).inset(-20)
            make.height.equalTo(35)
        }
        
        resetLocationButton.snp.makeConstraints { (make) in
            make.height.equalTo(35)
            make.width.equalTo(35)
            make.centerY.equalTo(chooseLocationButon.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
        }
    }
    
    func setLevelConstraint(){
        levelLabel.snp.makeConstraints { (make) in
            make.top.equalTo(locationLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(35)
            make.width.equalTo(80)
        }
        
        chooseLevelButon.snp.makeConstraints { (make) in
            make.centerY.equalTo(levelLabel.snp.centerY)
            make.leading.equalTo(levelLabel.snp.trailing).offset(20)
            make.trailing.equalTo(resetLevelButton.snp.leading).inset(-20)
            make.height.equalTo(35)
        }
        
        resetLevelButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(chooseLevelButon.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }
    }
    
    func setZonesConstraint(){
        zoneLabel.snp.makeConstraints { (make) in
            make.top.equalTo(levelLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(35)
            make.width.equalTo(80)
        }
        
        chooseZoneButon.snp.makeConstraints { (make) in
            make.centerY.equalTo(zoneLabel.snp.centerY)
            make.leading.equalTo(zoneLabel.snp.trailing).offset(20)
            make.trailing.equalTo(resetZoneButton.snp.leading).inset(-20)
            make.height.equalTo(35)
        }
        
        resetZoneButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(chooseZoneButon.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }

    }
    
    func setCategoryConstraint(){
        categoryLabel.snp.makeConstraints { (make) in
            make.top.equalTo(zoneLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(35)
            make.width.equalTo(80)
        }
        
        chooseCategoryButon.snp.makeConstraints { (make) in
            make.centerY.equalTo(categoryLabel.snp.centerY)
            make.leading.equalTo(categoryLabel.snp.trailing).offset(20)
            make.trailing.equalTo(resetCategoryButton.snp.leading).inset(-20)
            make.height.equalTo(35)
        }
        
        resetCategoryButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(chooseCategoryButon.snp.centerY)
            make.trailing.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.width.equalTo(35)
        }

    }
    
    func setGo() {
        goButon.snp.makeConstraints { (make) in
            make.width.equalTo(chooseCategoryButon.snp.width).dividedBy(2)
            make.trailing.equalTo(chooseCategoryButon.snp.trailing)
            make.top.equalTo(chooseCategoryButon.snp.bottom).offset(10)
            make.height.equalTo(35)
        }
    }
    
    func openLocations(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Location] = FilterController.shared.getLocationForFilterByUser()
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    func resetLocations(_ sender : UIButton) {
        location = nil
        level = nil
        zoneSelected = nil
        category = nil
        chooseLocationButon.setTitle("All", for: UIControlState())
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseLevelButon.setTitle("All", for: UIControlState())
        chooseCategoryButon.setTitle("All", for: UIControlState())
    }
    
    func openLevels(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location {
            let list:[Zone] = FilterController.shared.getLevelsByLocation(location)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    func resetLevel(_ sender : UIButton) {
        level = nil
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControlState())
        chooseLevelButon.setTitle("All", for: UIControlState())
    }
    
    func openZones(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location, let level = level {
            let list:[Zone] = FilterController.shared.getZoneByLevel(location, parentZone: level)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }

        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    func resetZone(_ sender : UIButton) {
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControlState())
    }
    
    func openCategories(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let location = location{
            let list:[Category] = FilterController.shared.getCategoriesByLocation(location)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC {  vc.openPopover(sender, popOverList:popoverList) }
    }
    
    func resetCategory(_ sender : UIButton) {
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
    
    func setDefaultParametar(){
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
        if let category = category{
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
    
    func go() {
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
    
    func updateIndicator(_ notification:Notification) {
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


