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
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnType: UIButton!
    
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
        
        for timer in gateway!.timers {
            timers.append(timer as! Timer)
        }
//        refreshTimerList()
        
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
        
        devAddressOne.text = "\(gateway!.addressOne)"
        devAddressTwo.text = "\(gateway!.addressTwo)"
        
        // Do any additional setup after loading the view.
    }
    
    func refreshTimerList() {
        updateTimerList()
        timerTableView.reloadData()
    }
    
    func updateTimerList () {
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
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let timerId = Int(IDedit.text!), let timerName = nameEdit.text, let address = Int(devAddressThree.text!), let type = btnType.titleLabel?.text {
            if timerId <= 32767 && address <= 255 && type != "--" {
                let timer = NSEntityDescription.insertNewObjectForEntityForName("Timer", inManagedObjectContext: appDel.managedObjectContext!) as! Timer
                timer.timerId = timerId
                timer.timerName = timerName
                timer.timerImageOne = UIImagePNGRepresentation(imageTimerOne.image!)!
                timer.timerImageTwo = UIImagePNGRepresentation(imageTimerTwo.image!)!
                timer.isBroadcast = NSNumber(bool: false)
                timer.address = address
                timer.type = type
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
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if let timer = selected as? Timer {
            appDel.managedObjectContext!.deleteObject(timer)
            IDedit.text = ""
            nameEdit.text = ""
            devAddressThree.text = ""
            btnZone.titleLabel?.text = "--"
            btnCategory.titleLabel?.text = "--"
            btnType.titleLabel?.text = "--"
            saveChanges()
            refreshTimerList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshTimerListNotification", object: self, userInfo: nil)
        }
    }
    @IBAction func btnZone(sender: AnyObject) {
        popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        popoverVC.indexTab = 3
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
        popoverVC.indexTab = 4
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
        case 3:
            btnZone.setTitle(text, forState: UIControlState.Normal)
        case 4:
            btnCategory.setTitle(text, forState: UIControlState.Normal)
        case 7:
            btnType.setTitle(text, forState: UIControlState.Normal)
        default: break
        }
    }
    
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
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
        if let _ = timers[indexPath.row].timeZone {
            btnZone.titleLabel?.text = "\(timers[indexPath.row].timeZone)"
        } else {
            btnZone.titleLabel?.text = "--"
        }
        if let _ = timers[indexPath.row].timerCategory {
            btnCategory.titleLabel?.text = "\(timers[indexPath.row].timerCategory)"
        } else {
            btnCategory.titleLabel?.text = "--"
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
    
}

class TimerCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    
}
