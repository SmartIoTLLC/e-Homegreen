//
//  ScanScenesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanScenesViewController: PopoverVC,UITextFieldDelegate, SceneGalleryDelegate {
    
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
    
    @IBOutlet weak var sceneTableView: UITableView!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway!
    var scenes:[Scene] = []
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
    var selected:AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateSceneList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanScenesViewController.handleTap(_:))))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanScenesViewController.handleTap(_:))))
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: #selector(ScanScenesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: #selector(ScanScenesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateSceneList()
        sceneTableView.reloadData()
    }
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    
    func refreshSceneList() {
        updateSceneList()
        sceneTableView.reloadData()
    }
    
    func updateSceneList() {
        let fetchRequest = NSFetchRequest(entityName: "Scene")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "sceneZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "sceneCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            scenes = fetResults!
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
    
    override func saveText(text: String, id: Int) {
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
    
    @IBAction func btnLevel(sender: AnyObject) {
        openPopover(sender, indexTab: 12, location: gateway.location)
    }
    
    @IBAction func btnCategoryAction(sender: AnyObject) {
        openPopover(sender, indexTab: 14, location: gateway.location)
    }
    
    @IBAction func btnZoneAction(sender: AnyObject) {
        openPopover(sender, indexTab: 13, location: gateway.location)
    }
    
    @IBAction func btnAdd(sender: AnyObject) {
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!) {
            if sceneId <= 32767 && address <= 255 {
                var itExists = false
                var existingScene:Scene?
                for scene in scenes {
                    if scene.sceneId == sceneId && scene.address == address {
                        itExists = true
                        existingScene = scene
                    }
                }
                if !itExists {
                    let scene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as! Scene
                    scene.sceneId = sceneId
                    scene.sceneName = sceneName
                    scene.address = address
                    scene.sceneImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                    scene.sceneImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                    scene.isBroadcast = broadcastSwitch.on
                    scene.isLocalcast = localcastSwitch.on
                    scene.entityLevel = btnLevel.titleLabel!.text!
                    scene.sceneZone = btnZone.titleLabel!.text!
                    scene.sceneCategory = btnCategory.titleLabel!.text!
                    scene.gateway = gateway
                    saveChanges()
                    refreshSceneList()
                } else {
                    existingScene!.sceneId = sceneId
                    existingScene!.sceneName = sceneName
                    existingScene!.address = address
                    existingScene!.sceneImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                    existingScene!.sceneImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                    existingScene!.isBroadcast = broadcastSwitch.on
                    existingScene!.isLocalcast = localcastSwitch.on
                    existingScene!.entityLevel = btnLevel.titleLabel!.text!
                    existingScene!.sceneZone = btnZone.titleLabel!.text!
                    existingScene!.sceneCategory = btnCategory.titleLabel!.text!
                    existingScene!.gateway = gateway
                    saveChanges()
                    refreshSceneList()
                }
            }
        }
        self.view.endEditing(true)
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if scenes.count != 0 {
            for scene in scenes {
                appDel.managedObjectContext!.deleteObject(scene)
            }
            saveChanges()
            refreshSceneList()
        }
        self.view.endEditing(true)
    }
    
}

extension ScanScenesViewController:  UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as? SceneCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(scenes[indexPath.row].sceneId)"
            cell.labelName.text = "\(scenes[indexPath.row].sceneName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(scenes[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(scenes[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(scenes[indexPath.row].address)))"
            if let sceneImage = UIImage(data: scenes[indexPath.row].sceneImageOne) {
                cell.imageOne.image = sceneImage
            }
            if let sceneImage = UIImage(data: scenes[indexPath.row].sceneImageTwo) {
                cell.imageTwo.image = sceneImage
            }
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = scenes[indexPath.row]
        IDedit.text = "\(scenes[indexPath.row].sceneId)"
        nameEdit.text = "\(scenes[indexPath.row].sceneName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(scenes[indexPath.row].address)))"
        broadcastSwitch.on = scenes[indexPath.row].isBroadcast.boolValue
        localcastSwitch.on = scenes[indexPath.row].isLocalcast.boolValue
        if let level = scenes[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        }
        if let zone = scenes[indexPath.row].sceneZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        }
        if let category = scenes[indexPath.row].sceneCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        }
        if let sceneImage = UIImage(data: scenes[indexPath.row].sceneImageOne) {
            imageSceneOne.image = sceneImage
        }
        if let sceneImage = UIImage(data: scenes[indexPath.row].sceneImageTwo) {
            imageSceneTwo.image = sceneImage
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scenes.count
    }
    
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.sceneTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(scenes[indexPath.row])
            saveChanges()
            refreshSceneList()
        }
    }
}

class SceneCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
        
}
