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
    optional func pullDownSearchParametars (gateway:String, level:String, zone:String, category:String, levelName:String, zoneName:String, categoryName:String)
}

class PullDownView: UIScrollView, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate, UIScrollViewDelegate {
    
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
    
    var locationSearch:[String] = []
    
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
        tapRec.addTarget(self, action: "tap")
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
        locationButton.tag = 1
        locationButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(locationButton)
        
        levelButton.titleLabel?.tintColor = UIColor.whiteColor()
        levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        levelButton.tag = 2
        levelButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(levelButton)
        
        zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
        zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        zoneButton.tag = 3
        zoneButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(zoneButton)
        
        categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
        categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        categoryButton.tag = 4
        categoryButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(categoryButton)
        
        // Go button
        goButton.titleLabel?.tintColor = UIColor.whiteColor()
        goButton.setTitle("Go", forState: UIControlState.Normal)
        goButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        goButton.addTarget(self, action: "goFilter:", forControlEvents: UIControlEvents.TouchUpInside)
        goButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(goButton)
        
        // Reset filters
        locationButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        locationButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        locationButtonReset.addTarget(self, action: "resetFilter:", forControlEvents: UIControlEvents.TouchUpInside)
        locationButtonReset.tag = 1
        locationButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(locationButtonReset)
        
        levelButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        levelButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        levelButtonReset.addTarget(self, action: "resetFilter:", forControlEvents: UIControlEvents.TouchUpInside)
        levelButtonReset.tag = 2
        levelButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(levelButtonReset)
        
        zoneButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        zoneButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        zoneButtonReset.addTarget(self, action: "resetFilter:", forControlEvents: UIControlEvents.TouchUpInside)
        zoneButtonReset.tag = 3
        zoneButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(zoneButtonReset)
        
        categoryButtonReset.setImage(UIImage(named: "exit"), forState: UIControlState.Normal)
        categoryButtonReset.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        categoryButtonReset.addTarget(self, action: "resetFilter:", forControlEvents: UIControlEvents.TouchUpInside)
        categoryButtonReset.tag = 4
        categoryButtonReset.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(categoryButtonReset)
    }
    
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
    
    func drawMenu(locationText:String, level:String, zone:String, category:String, locationSearch:[String]){
        self.locationSearch = locationSearch
        var levelText = "All"
        var zoneText = "All"
        var categoryText = "All"
        if locationText != "All" {
            choosedGateway = returnGatewayForName(locationText)
        }
        if level != "All" {
            levelText = "\(level)"
        }
        if zone != "All" {
            zoneText = "\(zone)"
        }
        if category != "All" {
            categoryText = "\(category)"
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
        print("\(locationText), \(levelText), \(zoneText)")
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
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("Ovo je mozda odgovor na sve sto sam mislio da je opproblem: \(scrollView.contentOffset)")
        if scrollView.contentOffset.y > 0.0 {
            let level = "\(returnZoneId(levelButton.titleLabel!.text!))"
            let zone = "\(returnZoneId(zoneButton.titleLabel!.text!))"
            let category = "\(returnCategoryId(categoryButton.titleLabel!.text!))"
            let levelName = "\(levelButton.titleLabel!.text!)"
            let zoneName = "\(zoneButton.titleLabel!.text!)"
            let categoryName = "\(categoryButton.titleLabel!.text!)"
            customDelegate?.pullDownSearchParametars!(locationButton.titleLabel!.text!, level: level, zone: zone, category: category, levelName: levelName, zoneName: zoneName, categoryName: categoryName)
        }
    }
    var popoverVC:PopOverViewController = PopOverViewController()
    func goFilter(sender:UIButton) {
        let level = "\(returnZoneId( levelButton.titleLabel!.text!))"
        let zone = "\(returnZoneId(zoneButton.titleLabel!.text!))"
        let category = "\(returnCategoryId(categoryButton.titleLabel!.text!))"
        let levelName = "\(levelButton.titleLabel!.text!)"
        let zoneName = "\(zoneButton.titleLabel!.text!)"
        let categoryName = "\(categoryButton.titleLabel!.text!)"
        customDelegate?.pullDownSearchParametars!(locationButton.titleLabel!.text!, level: level, zone: zone, category: category, levelName: levelName, zoneName: zoneName, categoryName: categoryName)
        print(self.parentViewController!.parentViewController!)
        self.setContentOffset(CGPointMake(0, self.frame.size.height - 2), animated: true)
    }
    var choosedGateway:Gateway?
    func returnGatewayForName(gatewayName:String) -> Gateway? {
        let fetchRequest = NSFetchRequest(entityName: "Gateway")
        let predicate = NSPredicate(format: "name == %@", gatewayName)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Gateway]
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
    
    func saveText (text : String, id:Int) {
        let tag = senderButton!.tag
        switch tag {
        case 1:
            locationButton.setTitle(text, forState: UIControlState.Normal)
            choosedGateway = returnGatewayForName(text)
            levelButton.setTitle("All", forState: UIControlState.Normal)
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        case 2:
            if id == -1 {
                levelButton.setTitle("All", forState: UIControlState.Normal)
            } else {
                levelButton.setTitle(text, forState: UIControlState.Normal)
            }
            zoneButton.setTitle("All", forState: UIControlState.Normal)
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        case 3:
            if id == -1 {
                zoneButton.setTitle("All", forState: UIControlState.Normal)
            } else {
                zoneButton.setTitle(text, forState: UIControlState.Normal)
            }
            categoryButton.setTitle("All", forState: UIControlState.Normal)
        case 4:
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
    
    func returnZoneId(name:String) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].id)"
            } else {
                return "\(name)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func returnCategoryId(name:String) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            if fetResults!.count != 0 {
                return "\(fetResults![0].id)"
            } else {
                return "\(name)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func returnZoneNameWithId(id:Int) -> String {
        let fetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "id == %@", NSNumber(integer: id))
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            if fetResults!.count != 0 {
                return "\(fetResults![0].name)"
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
                return "\(fetResults![0].name)"
            } else {
                return "\(id)"
            }
        } catch _ as NSError {
            print("Unresolved error")
            abort()
        }
        return ""
    }
    
    func menuTable(sender : UIButton){
        print("\(sender.tag):\(sender.enabled):\(sender)")
        
        let level = "\(returnZoneId( levelButton.titleLabel!.text!))"
        let zone = "\(returnZoneId(zoneButton.titleLabel!.text!))"
        let category = "\(returnCategoryId(categoryButton.titleLabel!.text!))"
        let levelName = "\(levelButton.titleLabel!.text!)"
        let zoneName = "\(zoneButton.titleLabel!.text!)"
        let categoryName = "\(categoryButton.titleLabel!.text!)"
        locationSearch = ["\(locationButton.titleLabel!.text)", level, zone, category, levelName, zoneName, categoryName]
        senderButton = sender
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = sender.tag
        popoverVC.locationSearch = locationSearch
        popoverVC.filterGateway = choosedGateway
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

    
}