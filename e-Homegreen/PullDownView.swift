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
    optional func pullDownSearchParametars (gateway:String, level:String, zone:String, category:String)
}

class PullDownView: UIScrollView,PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
    //    var table:UITableView = UITableView()
    //
    //    var levelList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    //    var zoneList:[String] = ["Zone 1", "Zone 2", "Zone 3", "All"]
    //    var categoryList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    //    var tableList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    
    var senderButton:UIButton?
    var customDelegate : PullDownViewDelegate?
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    var appDel:AppDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.pagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clearColor()
        let pixelOutside:CGFloat = 2
        self.contentSize = CGSizeMake(320, frame.size.height * 2 - pixelOutside)
        
        let redArea:UIView = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        redArea.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        self.addSubview(redArea)
        
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
    }
    var locationButton:UIButton = UIButton()
    var levelButton:UIButton = UIButton()
    var zoneButton:UIButton = UIButton()
    var categoryButton:UIButton = UIButton()
    var goButton:UIButton = UIButton()
    
    func drawMenu(locationText:String, level:String, zone:String, category:String){
        var levelText = "All"
        var zoneText = "All"
        var categoryText = "All"
        if locationText != "All" {
            choosedGateway = returnGatewayForName(locationText)
        }
        if level != "All" {
            levelText = "\(returnZoneWithId(Int(level)!))"
        }
        if level != "All" {
            zoneText = "\(returnZoneWithId(Int(level)!))"
        }
        if level != "All" {
            categoryText = "\(returnCategoryWithId(Int(category)!))"
        }
        let locationLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
        locationLabel.text = "Location"
        locationLabel.textColor = UIColor.whiteColor()
        self.addSubview(locationLabel)
        
        let levelLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
        levelLabel.text = "Level"
        levelLabel.textColor = UIColor.whiteColor()
        self.addSubview(levelLabel)
        
        let zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
        zoneLabel.text = "Zone"
        zoneLabel.textColor = UIColor.whiteColor()
        self.addSubview(zoneLabel)
        
        let categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 180, 100, 40))
        categoryLabel.text = "Category"
        categoryLabel.textColor = UIColor.whiteColor()
        self.addSubview(categoryLabel)
        
        locationButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
        locationButton.backgroundColor = UIColor.grayColor()
        locationButton.titleLabel?.tintColor = UIColor.whiteColor()
        locationButton.setTitle(locationText, forState: UIControlState.Normal)
        locationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        locationButton.layer.cornerRadius = 5
        locationButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        locationButton.layer.borderWidth = 1
        locationButton.tag = 1
        locationButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        locationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(locationButton)
        
        levelButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
        levelButton.backgroundColor = UIColor.grayColor()
        levelButton.titleLabel?.tintColor = UIColor.whiteColor()
        levelButton.setTitle(levelText, forState: UIControlState.Normal)
        levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        levelButton.layer.cornerRadius = 5
        levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        levelButton.layer.borderWidth = 1
        levelButton.tag = 2
        levelButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(levelButton)
        
        zoneButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
        zoneButton.backgroundColor = UIColor.grayColor()
        zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
        zoneButton.setTitle(zoneText, forState: UIControlState.Normal)
        zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        zoneButton.layer.cornerRadius = 5
        zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        zoneButton.layer.borderWidth = 1
        zoneButton.tag = 3
        zoneButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(zoneButton)
        
        categoryButton = UIButton(frame: CGRectMake(110, 180, 150, 40))
        categoryButton.backgroundColor = UIColor.grayColor()
        categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
        categoryButton.setTitle(categoryText, forState: UIControlState.Normal)
        categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        categoryButton.layer.cornerRadius = 5
        categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        categoryButton.layer.borderWidth = 1
        categoryButton.tag = 4
        categoryButton.addTarget(self, action: "menuTable:", forControlEvents: UIControlEvents.TouchUpInside)
        categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(categoryButton)
        
        goButton = UIButton(frame: CGRectMake(55, 250, 150, 40))
        goButton.backgroundColor = UIColor.grayColor()
        goButton.titleLabel?.tintColor = UIColor.whiteColor()
        goButton.setTitle("Go", forState: UIControlState.Normal)
        goButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center
        goButton.layer.cornerRadius = 5
        goButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        goButton.layer.borderWidth = 1
        goButton.tag = 4
        goButton.addTarget(self, action: "goFilter:", forControlEvents: UIControlEvents.TouchUpInside)
        goButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.addSubview(goButton)
        
        if locationText == "All" {
            levelButton.enabled = false
            zoneButton.enabled = false
            categoryButton.enabled = false
        } else {
            levelButton.enabled = true
            zoneButton.enabled = true
            categoryButton.enabled = true
        }
    }
    
    var popoverVC:PopOverViewController = PopOverViewController()
    func goFilter(sender:UIButton) {
        let level = "\(returnZoneName( levelButton.titleLabel!.text!))"
        let zone = "\(returnZoneName(zoneButton.titleLabel!.text!))"
        let category = "\(returnCategoryName(categoryButton.titleLabel!.text!))"
        customDelegate?.pullDownSearchParametars!(locationButton.titleLabel!.text!, level: level, zone: zone, category: category)
        self.setContentOffset(CGPointMake(0, self.parentViewController!.view.frame.size.height - 2), animated: false)
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
        case 3:
            if id == -1 {
                zoneButton.setTitle("All", forState: UIControlState.Normal)
            } else {
                zoneButton.setTitle(text, forState: UIControlState.Normal)
            }
        case 4:
            if id == -1 {
                categoryButton.setTitle("All", forState: UIControlState.Normal)
            } else {
                categoryButton.setTitle(text, forState: UIControlState.Normal)
            }
        default: break
        }
        if locationButton.titleLabel!.text! == "All" {
            levelButton.enabled = false
            zoneButton.enabled = false
            categoryButton.enabled = false
        } else {
            levelButton.enabled = true
            zoneButton.enabled = true
            categoryButton.enabled = true
        }
    }
    
    func returnZoneName(name:String) -> String {
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
    
    func returnCategoryName(name:String) -> String {
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
    
    func returnZoneWithId(id:Int) -> String {
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
    
    func returnCategoryWithId(id:Int) -> String {
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
        senderButton = sender
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        popoverVC = storyboard.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = sender.tag
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
            //            if point.x < 100 || point.x > 150 {
            return nil
            //            }
            
        }
        
        return super.hitTest(point, withEvent: event)
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
