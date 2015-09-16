//
//  ScanEventsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
class ScanEventsViewController: UIViewController, UITextFieldDelegate, SceneGalleryDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    @IBOutlet weak var eventTableView: UITableView!
    
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
        var toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        for event in gateway!.events {
            events.append(event as! Event)
        }
        refreshEventList()
        
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
        
        devAddressOne.text = "\(gateway!.addressOne)"
        devAddressTwo.text = "\(gateway!.addressTwo)"
        
        // Do any additional setup after loading the view.
    }
    
    func refreshEventList() {
        updateEventList()
        eventTableView.reloadData()
    }
    
    func updateEventList () {
        var fetchRequest = NSFetchRequest(entityName: "Event")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "eventId", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "eventName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Event]
        if let results = fetResults {
            events = results
        } else {
            println("Nije htela...")
        }
    }
    
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
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
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let sceneId = IDedit.text.toInt(), let sceneName = nameEdit.text, let address = devAddressThree.text.toInt() {
            if sceneId <= 32767 && address <= 255 {
                var event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: appDel.managedObjectContext!) as! Event
                event.eventId = sceneId
                event.eventName = sceneName
                event.eventImageOne = UIImagePNGRepresentation(imageSceneOne.image)
                event.eventImageTwo = UIImagePNGRepresentation(imageSceneTwo.image)
                event.isBroadcast = NSNumber(bool: false)
                event.gateway = gateway!
                saveChanges()
                refreshEventList()
                NSNotificationCenter.defaultCenter().postNotificationName("refreshEventListNotification", object: self, userInfo: nil)
            }
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if let event = selected as? Event {
            appDel.managedObjectContext!.deleteObject(event)
            IDedit.text = ""
            nameEdit.text = ""
            refreshEventList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshEventListNotification", object: self, userInfo: nil)
        }
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
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
