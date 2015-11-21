//
//  ScanEventsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanEventsViewController: UIViewController, UITextFieldDelegate, SceneGalleryDelegate, UITableViewDataSource, UITableViewDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
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
    
    @IBOutlet weak var eventTableView: UITableView!
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway?
    var events:[Event] = []
    
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
        
        updateEventList()
        
//        devAddressOne.inputAccessoryView = keyboardDoneButtonView
//        devAddressTwo.inputAccessoryView = keyboardDoneButtonView
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
    
    func refreshEventList() {
        updateEventList()
        eventTableView.reloadData()
    }
    
    func updateEventList() {
        let fetchRequest = NSFetchRequest(entityName: "Event")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
            events = fetResults!
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
    
    override func viewWillAppear(animated: Bool) {
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if sceneId <= 32767 && address <= 255 {
                if btnLevel.titleLabel!.text != "--" && btnZone.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                    let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: appDel.managedObjectContext!) as! Event
                    event.eventId = sceneId
                    event.eventName = sceneName
                    event.eventImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                    event.eventImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                    event.isBroadcast = broadcastSwitch.on
                    event.isLocalcast = localcastSwitch.on
                    if btnLevel.titleLabel?.text != "--" {
                        event.entityLevel = btnLevel.titleLabel!.text!
                    }
                    if btnZone.titleLabel?.text != "--" {
                        event.eventZone = btnZone.titleLabel!.text!
                    }
                    if btnCategory.titleLabel?.text != "--" {
                        event.eventCategory = btnCategory.titleLabel!.text!
                    }
                    event.gateway = gateway!
                    saveChanges()
                    refreshEventList()
                    NSNotificationCenter.defaultCenter().postNotificationName("refreshEventListNotification", object: self, userInfo: nil)
                }
            }
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if let event = selected as? Event {
            appDel.managedObjectContext!.deleteObject(event)
            IDedit.text = ""
            nameEdit.text = ""
            devAddressThree.text = ""
            btnLevel.setTitle("--", forState: UIControlState.Normal)
            btnZone.setTitle("--", forState: UIControlState.Normal)
            btnCategory.setTitle("--", forState: UIControlState.Normal)
            broadcastSwitch.on = false
            localcastSwitch.on = false
            saveChanges()
            refreshEventList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshEventListNotification", object: self, userInfo: nil)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("eventsCell") as? EventsCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(events[indexPath.row].eventId)"
            cell.labelName.text = "\(events[indexPath.row].eventName)"
            if let sceneImage = UIImage(data: events[indexPath.row].eventImageOne) {
                cell.imageOne.image = sceneImage
            }
            if let sceneImage = UIImage(data: events[indexPath.row].eventImageTwo) {
                cell.imageTwo.image = sceneImage
            }
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "sequnces"
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = events[indexPath.row]
        IDedit.text = "\(events[indexPath.row].eventId)"
        nameEdit.text = "\(events[indexPath.row].eventName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(events[indexPath.row].address)))"
        broadcastSwitch.on = events[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = events[indexPath.row].isLocalcast.boolValue
        if let level = events[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        } else {
            btnLevel.setTitle("--", forState: UIControlState.Normal)
        }
        if let zone = events[indexPath.row].eventZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        } else {
            btnZone.setTitle("--", forState: UIControlState.Normal)
        }
        if let category = events[indexPath.row].eventCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        } else {
            btnCategory.setTitle("--", forState: UIControlState.Normal)
        }
        if let sceneImage = UIImage(data: events[indexPath.row].eventImageOne) {
            imageSceneOne.image = sceneImage
        }
        if let sceneImage = UIImage(data: events[indexPath.row].eventImageTwo) {
            imageSceneTwo.image = sceneImage
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

}

class EventsCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    
}
