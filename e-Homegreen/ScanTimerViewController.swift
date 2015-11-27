//
//  ScanTimerViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanTimerViewController: UIViewController, UITextFieldDelegate, SceneGalleryDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageTimerOne: UIImageView!
    @IBOutlet weak var imageTimerTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var localcastSwitch: UISwitch!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnType: UIButton!
    @IBOutlet weak var btnLevel: CustomGradientButton!
    
    @IBOutlet weak var timerTableView: UITableView!
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway?
    var timers:[Timer] = []
    
    var selected:AnyObject?
    
    func endEditingNow(){
        devAddressOne.resignFirstResponder()
        devAddressTwo.resignFirstResponder()
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
        
        updateTimerList()
        
        devAddressOne.inputAccessoryView = keyboardDoneButtonView
        devAddressTwo.inputAccessoryView = keyboardDoneButtonView
        devAddressThree.inputAccessoryView = keyboardDoneButtonView
        IDedit.inputAccessoryView = keyboardDoneButtonView
        
        nameEdit.delegate = self
        
        imageTimerOne.userInteractionEnabled = true
        imageTimerOne.tag = 1
        imageTimerOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        imageTimerTwo.userInteractionEnabled = true
        imageTimerTwo.tag = 2
        imageTimerTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
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
    
    func refreshTimerList() {
        updateTimerList()
        timerTableView.reloadData()
    }
    
    func updateTimerList() {
        let fetchRequest = NSFetchRequest(entityName: "Timer")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "timerId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "timerName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Timer]
            timers = fetResults!
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
            self.imageTimerOne.image = UIImage(named: strText)
        }
        if imageIndex == 2 {
            self.imageTimerTwo.image = UIImage(named: strText)
        }
    }
    
    func backImageFromGallery(data: NSData, imageIndex:Int ) {
        if imageIndex == 1 {
            self.imageTimerOne.image = UIImage(data: data)
        }
        if imageIndex == 2 {
            self.imageTimerTwo.image = UIImage(data: data)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    @IBAction func btnEdit(sender: AnyObject) {
    }
    @IBAction func btnAdd(sender: AnyObject) {
        if let timerId = Int(IDedit.text!), let timerName = nameEdit.text, let address = Int(devAddressThree.text!), let type = btnType.titleLabel?.text {
            if timerId <= 32767 && address <= 255 && type != "--" {
                var itExists = false
                var existingTimer:Timer?
                for timer in timers {
                    if timer.timerId == timerId && timer.address == address {
                        itExists = true
                        existingTimer = timer
                    }
                }
                if !itExists {
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        let timer = NSEntityDescription.insertNewObjectForEntityForName("Timer", inManagedObjectContext: appDel.managedObjectContext!) as! Timer
                        timer.timerId = timerId
                        timer.timerName = timerName
                        timer.address = address
                        timer.timerImageOne = UIImagePNGRepresentation(imageTimerOne.image!)!
                        timer.timerImageTwo = UIImagePNGRepresentation(imageTimerTwo.image!)!
                        timer.isBroadcast = broadcastSwitch.on
                        timer.isLocalcast = localcastSwitch.on
                        timer.type = type
                        if btnLevel.titleLabel?.text != "--" {
                            timer.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            timer.timeZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            timer.timerCategory = btnCategory.titleLabel!.text!
                        }
                        timer.gateway = gateway!
                        saveChanges()
                        refreshTimerList()
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshTimerListNotification", object: self, userInfo: nil)
                    }
                } else {
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        existingTimer!.timerId = timerId
                        existingTimer!.timerName = timerName
                        existingTimer!.address = address
                        existingTimer!.timerImageOne = UIImagePNGRepresentation(imageTimerOne.image!)!
                        existingTimer!.timerImageTwo = UIImagePNGRepresentation(imageTimerTwo.image!)!
                        existingTimer!.isBroadcast = broadcastSwitch.on
                        existingTimer!.isLocalcast = localcastSwitch.on
                        existingTimer!.type = type
                        if btnLevel.titleLabel?.text != "--" {
                            existingTimer!.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            existingTimer!.timeZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            existingTimer!.timerCategory = btnCategory.titleLabel!.text!
                        }
                        existingTimer!.gateway = gateway!
                        saveChanges()
                        refreshTimerList()
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshTimerListNotification", object: self, userInfo: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
//        if let timer = selected as? Timer {
//            appDel.managedObjectContext!.deleteObject(timer)
//            IDedit.text = ""
//            nameEdit.text = ""
//            devAddressThree.text = ""
//            btnLevel.setTitle("--", forState: UIControlState.Normal)
//            btnZone.setTitle("--", forState: UIControlState.Normal)
//            btnCategory.setTitle("--", forState: UIControlState.Normal)
//            broadcastSwitch.on = false
//            localcastSwitch.on = false
//            btnType.setTitle("--", forState: UIControlState.Normal)
//            saveChanges()
//            refreshTimerList()
//            NSNotificationCenter.defaultCenter().postNotificationName("refreshTimerListNotification", object: self, userInfo: nil)
//        }
        if timers.count != 0 {
            for timer in timers {
                appDel.managedObjectContext!.deleteObject(timer)
            }
            saveChanges()
            refreshTimerList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshTimerListNotification", object: self, userInfo: nil)
            resignFirstRespondersOnTextFields()
        }
    }
    
    func resignFirstRespondersOnTextFields() {
        IDedit.resignFirstResponder()
        nameEdit.resignFirstResponder()
        devAddressOne.resignFirstResponder()
        devAddressTwo.resignFirstResponder()
        devAddressThree.resignFirstResponder()
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
    
    @IBAction func btnZone(sender: AnyObject) {
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
    
  
    @IBAction func btnCategory(sender: AnyObject) {
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
    
    
    @IBAction func btnTimerType(sender: AnyObject) {
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 7
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
    
    func saveText(text: String, id: Int) {
        switch id {
        case 2:
            btnLevel.setTitle(text, forState: UIControlState.Normal)
        case 3:
            btnZone.setTitle(text, forState: UIControlState.Normal)
        case 4:
            btnCategory.setTitle(text, forState: UIControlState.Normal)
        case 7:
            btnType.setTitle(text, forState: UIControlState.Normal)
        default: break
        }
    }
}
extension ScanTimerViewController: UITableViewDelegate {
    
}
extension ScanTimerViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("timerCell") as? TimerCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(timers[indexPath.row].timerId)"
            cell.labelName.text = timers[indexPath.row].timerName
            cell.address.text = "\(returnThreeCharactersForByte(Int(timers[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(timers[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(timers[indexPath.row].address)))"
            if let timerImage = UIImage(data: timers[indexPath.row].timerImageOne) {
                cell.imageOne.image = timerImage
            }
            if let timerImage = UIImage(data: timers[indexPath.row].timerImageTwo) {
                cell.imageTwo.image = timerImage
            }
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "timers"
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = timers[indexPath.row]
        IDedit.text = "\(timers[indexPath.row].timerId)"
        nameEdit.text = "\(timers[indexPath.row].timerName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(timers[indexPath.row].address)))"
        btnType.setTitle("\(timers[indexPath.row].type)", forState: UIControlState.Normal)
        broadcastSwitch.on = timers[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = timers[indexPath.row].isLocalcast.boolValue
        if let level = timers[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        } else {
            btnLevel.setTitle("--", forState: UIControlState.Normal)
        }
        if let zone = timers[indexPath.row].timeZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        } else {
            btnZone.setTitle("--", forState: UIControlState.Normal)
        }
        if let category = timers[indexPath.row].timerCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        } else {
            btnCategory.setTitle("--", forState: UIControlState.Normal)
        }
        if let timerImage = UIImage(data: timers[indexPath.row].timerImageOne) {
            imageTimerOne.image = timerImage
        }
        if let timerImage = UIImage(data: timers[indexPath.row].timerImageTwo) {
            imageTimerTwo.image = timerImage
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.timerTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(timers[indexPath.row])
            saveChanges()
            refreshTimerList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshTimerListNotification", object: self, userInfo: nil)
        }
        
    }
    
}

class TimerCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
}
