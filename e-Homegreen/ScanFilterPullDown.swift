//
//  ScanFilterPullDown.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 7/28/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol ScanFilterPullDownDelegate{
    func scanFilterParametars (_ filterItem: FilterItem)
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
        self.isPagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        //Create and add content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        contentView.clipsToBounds = true
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
        
        //location label
        locationLabel.text = "Location"
        locationLabel.textAlignment = .left
        locationLabel.textColor = UIColor.white
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)
        
        //choose location button
        chooseLocationButon.setTitle("All", for: UIControl.State())
        chooseLocationButon.translatesAutoresizingMaskIntoConstraints = false
        chooseLocationButon.tag = 0
        contentView.addSubview(chooseLocationButon)
        
        //reset location
        resetLocationButton.setImage(UIImage(named: "exit"), for: UIControl.State())
        resetLocationButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(resetLocationButton)
        
        //level label
        levelLabel.text = "Level"
        levelLabel.textAlignment = .left
        levelLabel.textColor = UIColor.white
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(levelLabel)
        
        //choose level button
        chooseLevelButon.setTitle("All", for: UIControl.State())
        chooseLevelButon.translatesAutoresizingMaskIntoConstraints = false
        chooseLevelButon.addTarget(self, action: #selector(openLevels(_:)), for: .touchUpInside)
        chooseLevelButon.tag = 1
        contentView.addSubview(chooseLevelButon)
        
        //reset level
        resetLevelButton.setImage(UIImage(named: "exit"), for: UIControl.State())
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
        chooseZoneButon.setTitle("All", for: UIControl.State())
        chooseZoneButon.translatesAutoresizingMaskIntoConstraints = false
        chooseZoneButon.addTarget(self, action: #selector(openZones(_:)), for: .touchUpInside)
        chooseZoneButon.tag = 2
        contentView.addSubview(chooseZoneButon)
        
        //reset zone
        resetZoneButton.setImage(UIImage(named: "exit"), for: UIControl.State())
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
        chooseCategoryButon.setTitle("All", for: UIControl.State())
        chooseCategoryButon.translatesAutoresizingMaskIntoConstraints = false
        chooseCategoryButon.addTarget(self, action: #selector(openCategories(_:)), for: .touchUpInside)
        chooseCategoryButon.tag = 3
        contentView.addSubview(chooseCategoryButon)
        
        //reset category
        resetCategoryButton.setImage(UIImage(named: "exit"), for: UIControl.State())
        resetCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        resetCategoryButton.addTarget(self, action: #selector(resetCategory(_:)), for: .touchUpInside)
        contentView.addSubview(resetCategoryButton)
        
        //GO button
        goButon.setTitle("Go", for: UIControl.State())
        goButon.translatesAutoresizingMaskIntoConstraints = false
        goButon.addTarget(self, action: #selector(go), for: .touchUpInside)
        contentView.addSubview(goButon)
        
    }
    
    func setItem(_ view: UIView, location: Location){
        
        self.location = location
        chooseLocationButon.setTitle(location.name, for: UIControl.State())
        
        //set content view constraint
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        
        bottom = NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -600)
        self.addConstraint(bottom)
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        
        height = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1, constant: 0)
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
    
    func setLocationConstraint(){
        
        //location label
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: locationLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 20))
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
        contentView.addConstraint(NSLayoutConstraint(item: resetLocationButton, attribute: .leading, relatedBy: .equal, toItem: chooseLocationButon, attribute: .trailing, multiplier: 1.0, constant: 20))
    }
    
    func setLevelConstraint(){
        
        // level label
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 10))
        contentView.addConstraint(NSLayoutConstraint(item: levelLabel, attribute: .top, relatedBy: .equal, toItem: locationLabel, attribute: .bottom, multiplier: 1.0, constant: 30))
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
        contentView.addConstraint(NSLayoutConstraint(item: zoneLabel, attribute: .top, relatedBy: .equal, toItem: levelLabel, attribute: .bottom, multiplier: 1.0, constant: 30))
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
        contentView.addConstraint(NSLayoutConstraint(item: categoryLabel, attribute: .top, relatedBy: .equal, toItem: zoneLabel, attribute: .bottom, multiplier: 1.0, constant: 30))
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
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: .top, relatedBy: .equal, toItem: chooseCategoryButon, attribute: .bottom, multiplier: 1.0, constant: 25))
        contentView.addConstraint(NSLayoutConstraint(item: goButon, attribute: .width, relatedBy: .equal, toItem: chooseCategoryButon, attribute: .width, multiplier: 0.5, constant: 0))
    }
    
    @objc func openLevels(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = DatabaseZoneController.shared.getLevelsByLocation(location)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    @objc func resetLevel(_ sender : UIButton) {
        level = nil
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControl.State())
        chooseLevelButon.setTitle("All", for: UIControl.State())
    }
    
    @objc func openZones(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level {
            let list:[Zone] = DatabaseZoneController.shared.getZoneByLevel(location, parentZone: level)
            for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    @objc func resetZone(_ sender : UIButton) {
        zoneSelected = nil
        chooseZoneButon.setTitle("All", for: UIControl.State())
    }
    
    @objc func openCategories(_ sender : UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = DatabaseCategoryController.shared.getCategoriesByLocation(location)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), at: 0)
        if let vc = self.parentViewController as? PopoverVC { vc.openPopover(sender, popOverList:popoverList) }
    }
    
    @objc func resetCategory(_ sender : UIButton) {
        category = nil
        chooseCategoryButon.setTitle("All", for: UIControl.State())
    }
    
    func setButtonTitle(_ text:String, id:String) {
        switch button.tag {
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            button.setTitle(text, for: UIControl.State())
            zoneSelected = nil
            chooseZoneButon.setTitle("All", for: UIControl.State())
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            button.setTitle(text, for: UIControl.State())
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            button.setTitle(text, for: UIControl.State())
            break
        default:
            break
        }
    }
    
    @objc func go() {
        returnFilter()
        
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height + self.contentInset.bottom)
        self.setContentOffset(bottomOffset, animated: true)
    }
    
    func returnFilter() {
        let filterItem = FilterItem(location: location.name!, levelId: 0, zoneId: 0, categoryId: 0, levelName: "All", zoneName: "All", categoryName: "All")

        filterItem.locationObjectId = location.objectID.uriRepresentation().absoluteString
        if let category = category{
            filterItem.categoryId = category.id!.intValue
            filterItem.categoryName = category.name!
            filterItem.categoryObjectId = category.objectID.uriRepresentation().absoluteString
        }
        guard let level = level else { scanFilterDelegate?.scanFilterParametars(filterItem); return }
        
        filterItem.levelId = level.id!.intValue
        filterItem.levelName = level.name!
        filterItem.levelObjectId = level.objectID.uriRepresentation().absoluteString
        
        guard let zone = zoneSelected else { scanFilterDelegate?.scanFilterParametars(filterItem); return }
        
        filterItem.zoneId = zone.id!.intValue
        filterItem.zoneName = zone.name!
        filterItem.zoneObjectId = zone.objectID.uriRepresentation().absoluteString
        scanFilterDelegate?.scanFilterParametars(filterItem)
    }
    
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateIndicator(_:)), name: NSNotification.Name(rawValue: NotificationKey.IndicatorLamp), object: nil)
    }
    
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.IndicatorLamp), object: nil)
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

    

}

extension ScanFilterPullDown: UIScrollViewDelegate{
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if point.y > contentView.frame.size.height + 30 { return nil }
        return super.hitTest(point, with: event)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 { returnFilter() }
    }
    
}
