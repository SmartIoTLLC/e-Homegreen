//
//  PullDownView.swift
//  NewProject
//
//  Created by Vladimir on 6/16/15.
//  Copyright (c) 2015 nswebdevolopment. All rights reserved.
//

import UIKit
import CoreData

@objc protocol PullDownViewDelegate
{
    optional func pullDownSearchParametars (filterParametar: FilterItem)
}

enum FilterFields: Int {
    case Location = 0
    case Gateway = 1
    case Level = 2
    case Zone = 3
    case Category = 4
}
class PullDownView: UIScrollView, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {
    
    var senderButton:UIButton?
    var customDelegate : PullDownViewDelegate?
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    var appDel:AppDelegate!
    
    var locationButton:CustomGradientButton = CustomGradientButton(frame: CGRectMake(110, 30, 150, 40))
    var levelButton:CustomGradientButton = CustomGradientButton(frame: CGRectMake(110, 80, 150, 40))
    var zoneButton:CustomGradientButton = CustomGradientButton(frame: CGRectMake(110, 130, 150, 40))
    var categoryButton:CustomGradientButton = CustomGradientButton(frame: CGRectMake(110, 180, 150, 40))
    var goButton:CustomGradientButton = CustomGradientButton(frame: CGRectMake(55, 250, 150, 40))
    
    var locationButtonReset:UIButton = UIButton(frame: CGRectMake(270, 30, 40, 40))
    var levelButtonReset:UIButton = UIButton(frame: CGRectMake(270, 80, 40, 40))
    var zoneButtonReset:UIButton = UIButton(frame: CGRectMake(270, 130, 40, 40))
    var categoryButtonReset:UIButton = UIButton(frame: CGRectMake(270, 180, 40, 40))
    
    let locationLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
    let levelLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
    let zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
    let categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 180, 100, 40))
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var choosedLocation:Location?
    
    var locationSearch:[String] = []
    //MARK: Creating a menu
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        self.delegate = self
        self.pagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clearColor()
        let pixelOutside:CGFloat = 2
        self.contentSize = CGSizeMake(320, frame.size.height * 2 - pixelOutside)
        
        let blackArea:UIView = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        blackArea.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        self.addSubview(blackArea)
        
        //  RGB za pulldown ruckicu je R: 128/255 G: 128/255 B: 128/255
        
        let pullView:UIImageView = UIImageView(frame: CGRectMake(frame.size.width/2 - 30, frame.size.height, 60, 30))
        pullView.image = UIImage(named: "pulldown")
        //        pullView.backgroundColor = UIColor.whiteColor()
        self.addSubview(pullView)
        
        pullView.userInteractionEnabled = true
        let tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: #selector(PullDownView.tap))
        pullView.addGestureRecognizer(tapRec)
        
        let grayBottomLine = UIView(frame:CGRectMake(0, frame.size.height-2, frame.size.width, 2))
        grayBottomLine.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        self.addSubview(grayBottomLine)
        
        self.delaysContentTouches = false
        
        
        locationLabel.text = "Location"
        locationLabel.textColor = UIColor.whiteColor()
        self.addSubview(locationLabel)
        
        levelLabel.text = "Level"
        levelLabel.textColor = UIColor.whiteColor()
        self.addSubview(levelLabel)
        
        zoneLabel.text = "Zone"
        zoneLabel.textColor = UIColor.whiteColor()
        self.addSubview(zoneLabel)
        
        categoryLabel.text = "Category"
        categoryLabel.textColor = UIColor.whiteColor()
        self.addSubview(categoryLabel)
        
        // Filters
        locationButton.titleLabel?.tintColor = UIColor.whiteColor()
        locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        // Before was tag 1 for Gateway but know it is tag 0 for Location
        locationButton.tag = 0
        locationButton.addTarget(self, action: #selector(PullDownView.menuTable(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(locationButton)
        
        levelButton.titleLabel?.tintColor = UIColor.whiteColor()
        levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        levelButton.tag = 2
        levelButton.addTarget(self, action: #selector(PullDownView.menuTable(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(levelButton)
        
        zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
        zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        zoneButton.tag = 3
        zoneButton.addTarget(self, action: #selector(PullDownView.menuTable(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(zoneButton)
        
        categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
        categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        categoryButton.tag = 4
        categoryButton.addTarget(self, action: #selector(PullDownView.menuTable(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(categoryButton)
        
        // Go button
        goButton.titleLabel?.tintColor = UIColor.whiteColor()
        goButton.setTitle("Go", forState: UIControlState.Normal)
        goButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        goButton.addTarget(self, action: #selector(PullDownView.goFilter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        goButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(goButton)
        
        // Reset filters
        locationButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        locationButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        locationButtonReset.addTarget(self, action: #selector(PullDownView.resetFilter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        locationButtonReset.tag = 1
        locationButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(locationButtonReset)
        
        levelButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        levelButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        levelButtonReset.addTarget(self, action: #selector(PullDownView.resetFilter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        levelButtonReset.tag = 2
        levelButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(levelButtonReset)
        
        zoneButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        zoneButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        zoneButtonReset.addTarget(self, action: #selector(PullDownView.resetFilter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        zoneButtonReset.tag = 3
        zoneButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(zoneButtonReset)
        
        categoryButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        categoryButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        categoryButtonReset.addTarget(self, action: #selector(PullDownView.resetFilter(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        categoryButtonReset.tag = 4
        categoryButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(categoryButtonReset)
    }
    //MARK: Reseting a filter
    func resetFilter(sender : UIButton){
        
        switch sender.tag {
        case 1:
            locationButton.setTitle("All", forState: UIControlState.Normal)
            levelButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        case 2:
            levelButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.setTitle("All", forState: UIControlState.Normal)
            
        case 3:
            zoneButton.setTitle("All", forState: UIControlState.Normal)
        case 4:
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        default:
            print("")
        }

    }
    //MARK: Populating a menu
    func drawMenu(filterItem: FilterItem){
        var locationText = filterItem.location
        var levelText = "All"
        var zoneText = "All"
        var categoryText = "All"
        if filterItem.location != "All" {
            choosedLocation = returnLocationForName(filterItem.location)
        }
        if filterItem.levelName != "All" {
            levelText = "\(filterItem.levelName)"
        }
        if filterItem.zoneName != "All" {
            zoneText = "\(filterItem.zoneName)"
        }
        if filterItem.categoryName != "All" {
            categoryText = "\(filterItem.categoryName)"
        }
        
        locationButton.setTitle(locationText, forState: UIControlState.Normal)
        levelButton.setTitle(levelText, forState: UIControlState.Normal)
        zoneButton.setTitle(zoneText, forState: UIControlState.Normal)
        categoryButton.setTitle(categoryText, forState: UIControlState.Normal)
        
        levelButton.enabled = false
        zoneButton.enabled = false
        categoryButton.enabled = false
        levelButton.userInteractionEnabled = false
        zoneButton.userInteractionEnabled = false
        categoryButton.userInteractionEnabled = false
        if locationText != "All" {
            levelButton.enabled = true
            levelButton.userInteractionEnabled = true
            categoryButton.enabled = true
            categoryButton.userInteractionEnabled = true
        }
        if levelText != "All" {
            zoneButton.enabled = true
            zoneButton.userInteractionEnabled = true
        }
    }
    //MARK: Sending a delegate method when user did scroll menu to hidden it
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0.0 {
            let level = returnZoneId(levelButton.titleLabel!.text!)
            let zone = returnZoneId(zoneButton.titleLabel!.text!)
            let category = returnCategoryId(categoryButton.titleLabel!.text!)
            let levelName = "\(levelButton.titleLabel!.text!)"
            let zoneName = "\(zoneButton.titleLabel!.text!)"
            let categoryName = "\(categoryButton.titleLabel!.text!)"
            customDelegate?.pullDownSearchParametars?(FilterItem(location: locationButton.titleLabel!.text!, levelId: level, zoneId: zone, categoryId: category, levelName: levelName, zoneName: zoneName, categoryName: categoryName))
        }
    }
    //MARK: Sending a delegate method when user pressed a button to filter
    func goFilter(sender:UIButton) {
        let level = returnZoneId( levelButton.titleLabel!.text!)
        let zone = returnZoneId(zoneButton.titleLabel!.text!)
        let category = returnCategoryId(categoryButton.titleLabel!.text!)
        let levelName = "\(levelButton.titleLabel!.text!)"
        let zoneName = "\(zoneButton.titleLabel!.text!)"
        let categoryName = "\(categoryButton.titleLabel!.text!)"
        customDelegate?.pullDownSearchParametars?(FilterItem(location: locationButton.titleLabel!.text!, levelId: level, zoneId: zone, categoryId: category, levelName: levelName, zoneName: zoneName, categoryName: categoryName))
        self.setContentOffset(CGPointMake(0, self.frame.size.height - 2), animated: true)
    }
    //MARK: Delegate for pop over
    func saveText (text : String, id:Int) {
        let tag = senderButton!.tag
        switch tag {
        case FilterFields.Location.rawValue:
            locationButton.setTitle(text, forState: UIControlState.Normal)
            choosedLocation = returnLocationForName(text)
            levelButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        case FilterFields.Level.rawValue:
            if id == -1 {
                levelButton.setTitle("All", forState: UIControlState.Normal)
            } else {
                levelButton.setTitle(text, forState: UIControlState.Normal)
            }
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        case FilterFields.Zone.rawValue:
            if id == -1 {
                zoneButton.setTitle("All", forState: UIControlState.Normal)
            } else {
                zoneButton.setTitle(text, forState: UIControlState.Normal)
            }
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        case FilterFields.Category.rawValue:
            if id == -1 {
                categoryButton.setTitle("All", forState: UIControlState.Normal)
            } else {
                categoryButton.setTitle(text, forState: UIControlState.Normal)
            }
        default: break
        }
        levelButton.enabled = false
        zoneButton.enabled = false
        categoryButton.enabled = false
        levelButton.enabled = false
        zoneButton.enabled = false
        categoryButton.enabled = false
        
        if locationButton.titleLabel!.text! != "All" {
            levelButton.enabled = true
            levelButton.userInteractionEnabled = true
            categoryButton.enabled = true
            categoryButton.userInteractionEnabled = true
        }
        if levelButton.titleLabel!.text! != "All" {
            zoneButton.enabled = true
            zoneButton.userInteractionEnabled = true
        }
    }
    
    //MARK: Calling a pop over
    func menuTable(sender : UIButton){
        let level = "\(returnZoneId( levelButton.titleLabel!.text!))"
        let zone = "\(returnZoneId(zoneButton.titleLabel!.text!))"
        let category = "\(returnCategoryId(categoryButton.titleLabel!.text!))"
        let levelName = "\(levelButton.titleLabel!.text!)"
        let zoneName = "\(zoneButton.titleLabel!.text!)"
        let categoryName = "\(categoryButton.titleLabel!.text!)"
        locationSearch = ["\(locationButton.titleLabel!.text)", level, zone, category, levelName, zoneName, categoryName]
        senderButton = sender
        let storyboard = UIStoryboard(name: "Popover", bundle: NSBundle.mainBundle())
        popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
//        popoverVC.delegate = self
//        popoverVC.indexTab = sender.tag
//        popoverVC.locationSearch = locationSearch
//        popoverVC.filterLocation = choosedLocation
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            self.parentViewController!.presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    func tap(){
       self.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        if point.y < self.frame.size.height + 40 && point.y > self.frame.size.height{
            if point.x < frame.size.width/2 - 30 || point.x > frame.size.width/2 + 30 {
                return nil
            }
            
        }
        if point.y > self.frame.size.height + 30 {
            return nil
            
        }
        return super.hitTest(point, withEvent: event)
    }
    
    //MARK: Database handlers
    func returnLocationForName(locationName:String) -> Location? {
        let fetchRequest = NSFetchRequest(entityName: "Location")
        let predicate = NSPredicate(format: "name == %@", locationName)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Location]
            if fetResults!.count != 0 {
                return fetResults![0]
            } else {
                return nil
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return nil
    }
    
    func returnZoneId(name:String) -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
//                if let id = Int(fetResults![0].id!) {
//                    return id
//                }
                return Int(fetResults![0].id!)
            } else {
                return 0
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return 0
    }
    
    func returnCategoryId(name:String) -> Int {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                if let id = fetResults![0].id as? Int {
                    return id
                }
            } else {
                return 0
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return 0
    }
    
    func returnZoneNameWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name!)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func returnCategoryNameWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name!)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
}