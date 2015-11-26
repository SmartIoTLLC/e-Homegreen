//
//  ScanFlagViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 10/7/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanFlagViewController: UIViewController, UITextFieldDelegate, SceneGalleryDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    
    var gateway:Gateway?
    var flags:[Flag] = []
    
    var selected:AnyObject?
    
    func endEditingNow(){
        //        devAddressOne.resignFirstResponder()
        //        devAddressTwo.resignFirstResponder()
        devAddressThree.resignFirstResponder()
        IDedit.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        updateFlagList()
        
        devAddressThree.inputAccessoryView = keyboardDoneButtonView
        IDedit.inputAccessoryView = keyboardDoneButtonView
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway!.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway!.addressTwo)))"
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        
        // Do any additional setup after loading the view.
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
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
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 12
        popoverVC.filterGateway = gateway
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
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 14
        popoverVC.filterGateway = gateway
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
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 13
        popoverVC.filterGateway = gateway
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
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    @IBAction func btnEdit(sender: AnyObject) {
        
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let flagId = Int(IDedit.text!), let flagName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if flagId <= 32767 && address <= 255 {
                var itExists = false
                var existingFlag:Flag?
                for flag in flags {
                    if flag.flagId == flagId && flag.address != address {
                        itExists = true
                        existingFlag = flag
                    }
                }
                if !itExists {
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        let flag = NSEntityDescription.insertNewObjectForEntityForName("Flag", inManagedObjectContext: appDel.managedObjectContext!) as! Flag
                        flag.flagId = flagId
                        flag.flagName = flagName
                        flag.address = address
                        flag.flagImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                        flag.flagImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                        flag.isBroadcast = broadcastSwitch.on
                        flag.isLocalcast = localcastSwitch.on
                        if btnLevel.titleLabel?.text != "--" {
                            flag.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            flag.flagZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            flag.flagCategory = btnCategory.titleLabel!.text!
                        }
                        flag.gateway = gateway!
                        saveChanges()
                        refreshFlagList()
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshFlagListNotification", object: self, userInfo: nil)
                    }
                } else {
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        existingFlag!.flagId = flagId
                        existingFlag!.flagName = flagName
                        existingFlag!.address = address
                        existingFlag!.flagImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                        existingFlag!.flagImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                        existingFlag!.isBroadcast = broadcastSwitch.on
                        existingFlag!.isLocalcast = localcastSwitch.on
                        if btnLevel.titleLabel?.text != "--" {
                            existingFlag!.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            existingFlag!.flagZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            existingFlag!.flagCategory = btnCategory.titleLabel!.text!
                        }
                        existingFlag!.gateway = gateway!
                        saveChanges()
                        refreshFlagList()
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshFlagListNotification", object: self, userInfo: nil)
                    }
                }
            }
        }
        resignFirstRespondersOnTextFields()
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
//        if let flag = selected as? Flag {
//            appDel.managedObjectContext!.deleteObject(flag)
//            IDedit.text = ""
//            nameEdit.text = ""
//            devAddressThree.text = ""
//            btnLevel.setTitle("--", forState: UIControlState.Normal)
//            btnZone.setTitle("--", forState: UIControlState.Normal)
//            btnCategory.setTitle("--", forState: UIControlState.Normal)
//            broadcastSwitch.on = false
//            localcastSwitch.on = false
//            saveChanges()
//            refreshFlagList()
//            NSNotificationCenter.defaultCenter().postNotificationName("refreshFlagListNotification", object: self, userInfo: nil)
//        }
        if flags.count != 0 {
            for flag in flags {
                appDel.managedObjectContext!.deleteObject(flag)
            }
            saveChanges()
            refreshFlagList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshFlagListNotification", object: self, userInfo: nil)
        }
        resignFirstRespondersOnTextFields()
    }
    
    func resignFirstRespondersOnTextFields() {
        IDedit.resignFirstResponder()
        nameEdit.resignFirstResponder()
        devAddressOne.resignFirstResponder()
        devAddressTwo.resignFirstResponder()
        devAddressThree.resignFirstResponder()
    }
    
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
        cell.textLabel?.text = "sequnces"
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
        } else {
            btnLevel.setTitle("--", forState: .Normal)
        }
        if let zone = flags[indexPath.row].flagZone {
            btnZone.setTitle(zone, forState: .Normal)
        } else {
            btnZone.setTitle("--", forState: .Normal)
        }
        if let category = flags[indexPath.row].flagCategory {
            btnCategory.setTitle(category, forState: .Normal)
        } else {
            btnCategory.setTitle("--", forState: .Normal)
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
            // Here needs to be deleted even devices that are from gateway that is going to be deleted
            appDel.managedObjectContext?.deleteObject(flags[indexPath.row])
            saveChanges()
            refreshFlagList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshFlagListNotification", object: self, userInfo: nil)
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
