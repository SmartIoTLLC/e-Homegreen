//
//  ScanEventsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanEventsViewController: PopoverVC {
    
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
    @IBOutlet weak var reportSwitch: UISwitch!
    
    @IBOutlet weak var eventTableView: UITableView!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway!
    var events:[Event] = []
    
    var selected:AnyObject?
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateEventList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        // Do any additional setup after loading the view.
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateEventList()
        eventTableView.reloadData()
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
//        let predicate = NSPredicate(format: "gateway == %@", gateway.objectID)
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "eventZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "eventCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
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
    
    @IBAction func btnLevel(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Zone] = FilterController.shared.getLevelsByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnCategoryAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Category] = FilterController.shared.getCategoriesByLocation(gateway.location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    @IBAction func btnZoneAction(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        if let level = level{
            let list:[Zone] = FilterController.shared.getZoneByLevel(gateway.location, parentZone: level)
            for item in list {
                popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
            }
        }
        
        popoverList.insert(PopOverItem(name: "All", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    override func nameAndId(name: String, id: String) {
        
        switch button.tag{
        case 1:
            level = FilterController.shared.getZoneByObjectId(id)
            btnZone.setTitle("All", forState: .Normal)
            zoneSelected = nil
            break
        case 2:
            zoneSelected = FilterController.shared.getZoneByObjectId(id)
            break
        case 3:
            category = FilterController.shared.getCategoryByObjectId(id)
            break
        default:
            break
        }
        
        button.setTitle(name, forState: .Normal)
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if sceneId <= 32767 && address <= 255 {
                var itExists = false
                var existingEvent:Event?
                for event in events {
                    if event.eventId == sceneId && event.address == address {
                        itExists = true
                        existingEvent = event
                    }
                }
                if !itExists {
                    let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: appDel.managedObjectContext!) as! Event
                    event.eventId = sceneId
                    event.eventName = sceneName
                    event.address = address
                    event.eventImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                    event.eventImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                    event.isBroadcast = broadcastSwitch.on
                    event.isLocalcast = localcastSwitch.on
                    event.report = reportSwitch.on
                    event.entityLevel = btnLevel.titleLabel!.text!
                    event.eventZone = btnZone.titleLabel!.text!
                    event.eventCategory = btnCategory.titleLabel!.text!
                    event.gateway = gateway
                    saveChanges()
                    refreshEventList()
                } else {
                    existingEvent!.eventId = sceneId
                    existingEvent!.eventName = sceneName
                    existingEvent!.address = address
                    existingEvent!.eventImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                    existingEvent!.eventImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                    existingEvent!.isBroadcast = broadcastSwitch.on
                    existingEvent!.isLocalcast = localcastSwitch.on
                    existingEvent!.report = reportSwitch.on
                    existingEvent!.entityLevel = btnLevel.titleLabel!.text!
                    existingEvent!.eventZone = btnZone.titleLabel!.text!
                    existingEvent!.eventCategory = btnCategory.titleLabel!.text!
                    existingEvent!.gateway = gateway
                    saveChanges()
                    refreshEventList()
                }
            }
        }
    }

    @IBAction func btnRemove(sender: AnyObject) {
        if events.count != 0 {
            for event in events {
                appDel.managedObjectContext!.deleteObject(event)
            }
            saveChanges()
            refreshEventList()
            self.view.endEditing(true)
        }
    }
}

extension ScanEventsViewController: SceneGalleryDelegate{
    
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
}

extension ScanEventsViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanEventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("eventsCell") as? EventsCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(events[indexPath.row].eventId)"
            cell.labelName.text = "\(events[indexPath.row].eventName)"
            print("\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressOne)))")
            print("\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressTwo)))")
            print("\(returnThreeCharactersForByte(Int(events[indexPath.row].address)))")
            cell.address.text = "\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(events[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(events[indexPath.row].address)))"
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
        reportSwitch.on = events[indexPath.row].report.boolValue
        if let level = events[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        }
        if let zone = events[indexPath.row].eventZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        }
        if let category = events[indexPath.row].eventCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
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
    
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.eventTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(events[indexPath.row])
            saveChanges()
            refreshEventList()
        }
        
    }
}

class EventsCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
}
