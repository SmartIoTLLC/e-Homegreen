//
//  ScanFlagViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/7/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanFlagViewController: UIViewController, UITextFieldDelegate, SceneGalleryDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var localcastSwitch: UISwitch!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnLevel: CustomGradientButton!
    
    @IBOutlet weak var flagTableView: UITableView!
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway!
    var flags:[Flag] = []
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
    var selected:AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateFlagList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanFlagViewController.handleTap(_:))))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanFlagViewController.handleTap(_:))))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.enabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.enabled = false
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: #selector(ScanFlagViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: #selector(ScanFlagViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)

    }

    
    override func sendFilterParametar(filterParametar: FilterItem) {
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateFlagList()
        flagTableView.reloadData()
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    
    func refreshFlagList() {
        updateFlagList()
        flagTableView.reloadData()
    }
    
    func saveText(text: String, id: Int) {
        switch id {
        case 2:
            btnLevel.setTitle(text, forState: UIControlState.Normal)
        case 3:
            btnZone.setTitle(text, forState: UIControlState.Normal)
        case 4:
            btnCategory.setTitle(text, forState: UIControlState.Normal)
        default: break
        }
    }
    
    func updateFlagList() {
        let fetchRequest = NSFetchRequest(entityName: "Flag")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "flagId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "flagName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "flagZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "flagCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Flag]
            flags = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func handleTap (gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index).delegate = self
        }
    }
    
    func backString(strText: String, imageIndex:Int) {
        if imageIndex == 1 {
            self.imageSceneOne.image = UIImage(named: strText)
        }
        if imageIndex == 2 {
            self.imageSceneTwo.image = UIImage(named: strText)
        }
    }
    
    func backImageFromGallery(data: NSData, imageIndex:Int ) {
        if imageIndex == 1 {
            self.imageSceneOne.image = UIImage(data: data)
        }
        if imageIndex == 2 {
            self.imageSceneTwo.image = UIImage(data: data)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnLevel(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Popover", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 12
        popoverVC.filterLocation = gateway.location
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCategoryAction(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Popover", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 14
        popoverVC.filterLocation = gateway.location
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnZoneAction(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Popover", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 13
        popoverVC.filterLocation = gateway.location
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let flagId = Int(IDedit.text!), let flagName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if flagId <= 32767 && address <= 255 {
                var itExists = false
                var existingFlag:Flag?
                for flag in flags {
                    if flag.flagId == flagId && flag.address == address {
                        itExists = true
                        existingFlag = flag
                    }
                }
                if !itExists {
                    let flag = NSEntityDescription.insertNewObjectForEntityForName("Flag", inManagedObjectContext: appDel.managedObjectContext!) as! Flag
                    flag.flagId = flagId
                    flag.flagName = flagName
                    flag.address = address
                    flag.flagImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                    flag.flagImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                    flag.isBroadcast = broadcastSwitch.on
                    flag.isLocalcast = localcastSwitch.on
                    flag.entityLevel = btnLevel.titleLabel!.text!
                    flag.flagZone = btnZone.titleLabel!.text!
                    flag.flagCategory = btnCategory.titleLabel!.text!
                    flag.gateway = gateway
                    saveChanges()
                    refreshFlagList()
                } else {
                    existingFlag!.flagId = flagId
                    existingFlag!.flagName = flagName
                    existingFlag!.address = address
                    existingFlag!.flagImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                    existingFlag!.flagImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                    existingFlag!.isBroadcast = broadcastSwitch.on
                    existingFlag!.isLocalcast = localcastSwitch.on
                    existingFlag!.entityLevel = btnLevel.titleLabel!.text!
                    existingFlag!.flagZone = btnZone.titleLabel!.text!
                    existingFlag!.flagCategory = btnCategory.titleLabel!.text!
                    existingFlag!.gateway = gateway
                    saveChanges()
                    refreshFlagList()
                }
            }
        }
        self.view.endEditing(true)
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if flags.count != 0 {
            for flag in flags {
                appDel.managedObjectContext!.deleteObject(flag)
            }
            saveChanges()
            refreshFlagList()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFlag, object: self, userInfo: nil)
        }
        self.view.endEditing(true)
    }


}

extension ScanFlagViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("flagCell") as? FlagCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(flags[indexPath.row].flagId)"
            cell.labelName.text = "\(flags[indexPath.row].flagName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(flags[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(flags[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(flags[indexPath.row].address)))"
            if let flagImage = UIImage(data: flags[indexPath.row].flagImageOne) {
                cell.imageOne.image = flagImage
            }
            if let flagImage = UIImage(data: flags[indexPath.row].flagImageTwo) {
                cell.imageTwo.image = flagImage
            }
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = flags[indexPath.row]
        IDedit.text = "\(flags[indexPath.row].flagId)"
        nameEdit.text = "\(flags[indexPath.row].flagName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(flags[indexPath.row].address)))"
        broadcastSwitch.on = flags[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = flags[indexPath.row].isLocalcast.boolValue
        if let level = flags[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        }
        if let zone = flags[indexPath.row].flagZone {
            btnZone.setTitle(zone, forState: .Normal)
        }
        if let category = flags[indexPath.row].flagCategory {
            btnCategory.setTitle(category, forState: .Normal)
        }
        if let flagImage = UIImage(data: flags[indexPath.row].flagImageOne) {
            imageSceneOne.image = flagImage
        }
        if let flagImage = UIImage(data: flags[indexPath.row].flagImageTwo) {
            imageSceneTwo.image = flagImage
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flags.count
    }
    
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.flagTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
            }
            let cancelDelete = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            deleteMenu.addAction(delete)
            deleteMenu.addAction(cancelDelete)
            if let presentationController = deleteMenu.popoverPresentationController {
                presentationController.sourceView = tableView.cellForRowAtIndexPath(indexPath)
                presentationController.sourceRect = tableView.cellForRowAtIndexPath(indexPath)!.bounds
            }
            self.presentViewController(deleteMenu, animated: true, completion: nil)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            appDel.managedObjectContext?.deleteObject(flags[indexPath.row])
            saveChanges()
            refreshFlagList()
        }
        
    }
}

class FlagCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
}
