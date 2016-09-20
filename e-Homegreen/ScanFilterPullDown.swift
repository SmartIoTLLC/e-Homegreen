//
//  ScanFilterPullDown.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/28/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol ScanFilterPullDownDelegate{
    func scanFilterParametars (filterItem: FilterItem)
}

class ScanFilterPullDown: UIScrollView {

    var scanFilterDelegate : ScanFilterPullDownDelegate?
    
    var bottom = NSLayoutConstraint()
    
    var height = NSLayoutConstraint()
    
    let contentView = UIView()
    let bottomLine = UIView()
    let pullView:UIImageView = UIImageView()
    
    let redIndicator = UIView()
    let greenIndicator = UIView()
    
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
    
    var location:Location!
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
        self.pagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clearColor()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Create and add content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        contentView.clipsToBounds = true
        self.addSubview(contentView)
        
        //create and add bottom gray line
        bottomLine.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomLine)
        
        //create signal indicators
        greenIndicator.backgroundColor = UIColor.clearColor()
        greenIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(greenIndicator)
        redIndicator.backgroundColor = UIColor.clearColor()
        redIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(redIndicator)
        
        //create pull down image
        pullView.image = UIImage(named: "pulldown")
        pullView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(pullView)
        
        //location label
        locationLabel.text = "Location"
        locationLabel.textAlignment = .Left
        locationLabel.textColor = UIColor.whiteColor()
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)
        
        //choose location button
        chooseLocationButon.setTitle("All", forState: .Normal)
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
        chooseLevelButon.addTarget(self, action: #selector(ScanFilterPullDown.openLevels(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        chooseLevelButon.tag = 1
        contentView.addSubview(chooseLevelButon)
        
        //reset level
        resetLevelButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetLevelButton.translatesAutoresizingMaskIntoConstraints = false
        resetLevelButton.addTarget(self, action: #selector(ScanFilterPullDown.resetLevel(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        chooseZoneButon.addTarget(self, action: #selector(ScanFilterPullDown.openZones(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        chooseZoneButon.tag = 2
        contentView.addSubview(chooseZoneButon)
        
        //reset zone
        resetZoneButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetZoneButton.translatesAutoresizingMaskIntoConstraints = false
        resetZoneButton.addTarget(self, action: #selector(ScanFilterPullDown.resetZone(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
        chooseCategoryButon.addTarget(self, action: #selector(ScanFilterPullDown.openCategories(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        chooseCategoryButon.tag = 3
        contentView.addSubview(chooseCategoryButon)
        
        //reset category
        resetCategoryButton.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        resetCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        resetCategoryButton.addTarget(self, action: #selector(ScanFilterPullDown.resetCategory(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(resetCategoryButton)
        
        //GO button
        goButon.setTitle("Go", forState: .Normal)
        goButon.translatesAutoresizingMaskIntoConstraints = false
        goButon.addTarget(self, action: #selector(FilterPullDown.go), forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(goButon)
        
    }
    
    func setItem(view: UIView, location: Location){
        
        self.location = location
        chooseLocationButon.setTitle(location.name, forState: .Normal)
        
        //set content view constraint
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        
        bottom = NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -600)
        self.addConstraint(bottom)
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
        
        height = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        view.addConstraint(height)
        
        setBottomLineAndPullDownImageConstraint()
        
        setLocationConstraint()
        
        setLevelConstraint()
        
        setZonesConstraint()
        
        setCategoryConstraint()
        
        setGo()        
        
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
        
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 37))
        
        pullView.addConstraint(NSLayoutConstraint(item: pullView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 120))
        
        //setGreenIndicator
        self.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: -15))
        
        greenIndicator.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 12))
        
        greenIndicator.addConstraint(NSLayoutConstraint(item: greenIndicator, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
        
        //setRedIndicator
        self.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 15))
        
        redIndicator.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 12))
        
        redIndicator.addConstraint(NSLayoutConstraint(item: redIndicator, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 30))
    }
    
    func setLocationConstraint(){
        
        //location label
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: contentView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 20))
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
    
    func setGo(){
        
        //set go button constraints
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0))
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 25))
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: chooseCategoryButon, attribute: NSLayoutAttribute.Width, multiplier: 0.5, constant: 0))
    }
    
    func openLevels(sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openPopover(sender, popOverList:popoverList)
        }
    }
    
    func resetLevel(sender : UIButton){
        level = nil
        zoneSelected = nil
        chooseZoneButon.setTitle("All", forState: .Normal)
        chooseLevelButon.setTitle("All", forState: .Normal)
    }
    
    func openZones(sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openPopover(sender, popOverList:popoverList)
        }
    }
    
    func resetZone(sender : UIButton){
        zoneSelected = nil
        chooseZoneButon.setTitle("All", forState: .Normal)
    }
    
    func openCategories(sender : UIButton){
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        if let vc = self.parentViewController as? PopoverVC{
            vc.openPopover(sender, popOverList:popoverList)
        }
    }
    
    func resetCategory(sender : UIButton){
        category = nil
        chooseCategoryButon.setTitle("All", forState: .Normal)
    }
    
    func setButtonTitle(text:String, id:String){
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            button.setTitle(text, forState: .Normal)
            zoneSelected = nil
            chooseZoneButon.setTitle("All", forState: .Normal)
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            button.setTitle(text, forState: .Normal)
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            button.setTitle(text, forState: .Normal)
            break
        default:
            break
        }
        
        
    }
    
    func go(){
        
        returnFilter()
        
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
        self.setContentOffset(bottomOffset, animated: true)
        
    }
    
    func returnFilter(){
        let filterItem = FilterItem(location: location.name!, levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")

        filterItem.locationObjectId = location.objectID.URIRepresentation().absoluteString
        if let category = category{
            filterItem.categoryId = category.id!.integerValue
            filterItem.categoryName = category.name!
            filterItem.categoryObjectId = category.objectID.URIRepresentation().absoluteString
        }
        guard let level = level else{
            scanFilterDelegate?.scanFilterParametars(filterItem)
            return
        }
        
        filterItem.levelId = level.id!.integerValue
        filterItem.levelName = level.name!
        filterItem.levelObjectId = level.objectID.URIRepresentation().absoluteString
        guard let zone = zoneSelected else{
            scanFilterDelegate?.scanFilterParametars(filterItem)
            return
        }
        filterItem.zoneId = zone.id!.integerValue
        filterItem.zoneName = zone.name!
        filterItem.zoneObjectId = zone.objectID.URIRepresentation().absoluteString
        scanFilterDelegate?.scanFilterParametars(filterItem)
    }
    
    func addObservers(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanFilterPullDown.updateIndicator(_:)), name: NotificationKey.IndicatorLamp, object: nil)
    }
    
    func removeObservers(){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.IndicatorLamp, object: nil)
    }
    
    func updateIndicator(notification:NSNotification){
        if let info = notification.userInfo as? [String:String]{
            
            redIndicator.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
            greenIndicator.backgroundColor = UIColor(red: 24/255, green: 202/255, blue: 0/255, alpha: 1.0)
            
            if let lamp = info["lamp"]{
                if lamp == "red" {
                    
                    self.redIndicator.alpha = 1
                    UIView.animateWithDuration(0.5, animations: {
                        self.redIndicator.alpha = 0
                        }, completion: { (Bool) in
                            self.redIndicator.backgroundColor = UIColor.clearColor()
                            self.greenIndicator.backgroundColor = UIColor.clearColor()
                            
                    })
                }else if lamp == "green" {
                    
                    self.greenIndicator.alpha = 1
                    UIView.animateWithDuration(0.5, animations: {
                        self.greenIndicator.alpha = 0
                        }, completion: { (Bool) in
                            self.redIndicator.backgroundColor = UIColor.clearColor()
                            self.greenIndicator.backgroundColor = UIColor.clearColor()
                    })
                }else{
                    print("INDICATOR ERROR")
                }
            }
            
            
        }
    }

    

}

extension ScanFilterPullDown: UIScrollViewDelegate{
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if point.y > contentView.frame.size.height + 30 {
            return nil
        }
        return super.hitTest(point, withEvent: event)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0{
            
            returnFilter()
        }
    }
    
}
