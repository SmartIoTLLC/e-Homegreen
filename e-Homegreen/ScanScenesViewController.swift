//
//  ScanScenesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanScenesViewController: UIViewController,UITextFieldDelegate, SceneGalleryDelegate, UITableViewDataSource, UITableViewDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
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
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway?
    var scenes:[Scene] = []
    
    var selected:AnyObject?
    
    func endEditingNow(){
//        devAddressOne.resignFirstResponder()
//        devAddressTwo.resignFirstResponder()
        devAddressThree.resignFirstResponder()
        IDedit.resignFirstResponder()
    }
    
    func resignFirstRespondersOnTextFields() {
        IDedit.resignFirstResponder()
        nameEdit.resignFirstResponder()
        devAddressOne.resignFirstResponder()
        devAddressTwo.resignFirstResponder()
        devAddressThree.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        updateSceneList()
        
        devAddressThree.inputAccessoryView = keyboardDoneButtonView
        IDedit.inputAccessoryView = keyboardDoneButtonView
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleTap:"))
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway!.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway!.addressTwo)))"
        
        // Do any additional setup after loading the view.
    }
    
    override func sendFilterParametar(gateway: String, level: String, zone: String, category: String, levelName: String, zoneName: String, categoryName: String) {
        
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
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
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
    override func viewDidAppear(animated: Bool) {
        resignFirstRespondersOnTextFields()
    }
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
//    func returnThreeCharactersForByte (number:Int) -> String {
//        return String(format: "%03d",number)
//    }
    @IBAction func btnEdit(sender: AnyObject) {
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
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        let scene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as! Scene
                        scene.sceneId = sceneId
                        scene.sceneName = sceneName
                        scene.address = address
                        scene.sceneImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                        scene.sceneImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                        scene.isBroadcast = broadcastSwitch.on
                        scene.isLocalcast = localcastSwitch.on
                        if btnLevel.titleLabel?.text != "--" {
                            scene.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            scene.sceneZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            scene.sceneCategory = btnCategory.titleLabel!.text!
                        }
                        scene.gateway = gateway!
                        saveChanges()
                        refreshSceneList()
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshScene, object: self, userInfo: nil)
                    }
                } else {
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        existingScene!.sceneId = sceneId
                        existingScene!.sceneName = sceneName
                        existingScene!.address = address
                        existingScene!.sceneImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                        existingScene!.sceneImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                        existingScene!.isBroadcast = broadcastSwitch.on
                        existingScene!.isLocalcast = localcastSwitch.on
                        if btnLevel.titleLabel?.text != "--" {
                            existingScene!.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            existingScene!.sceneZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            existingScene!.sceneCategory = btnCategory.titleLabel!.text!
                        }
                        existingScene!.gateway = gateway!
                        saveChanges()
                        refreshSceneList()
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshScene, object: self, userInfo: nil)
                    }
                }
            }
        }
        resignFirstRespondersOnTextFields()
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
//        if let scene = selected as? Scene {
//            appDel.managedObjectContext!.deleteObject(scene)
//            IDedit.text = ""
//            nameEdit.text = ""
//            devAddressThree.text = ""
//            btnLevel.setTitle("--", forState: UIControlState.Normal)
//            btnZone.setTitle("--", forState: UIControlState.Normal)
//            btnCategory.setTitle("--", forState: UIControlState.Normal)
//            broadcastSwitch.on = false
//            localcastSwitch.on = false
//            saveChanges()
//            refreshSceneList()
//            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshScene, object: self, userInfo: nil)
//            resignFirstRespondersOnTextFields()
//        }
        if scenes.count != 0 {
            for scene in scenes {
                appDel.managedObjectContext!.deleteObject(scene)
            }
            saveChanges()
            refreshSceneList()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshScene, object: self, userInfo: nil)
        }
        resignFirstRespondersOnTextFields()
    }
    
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
        } else {
            btnLevel.setTitle("--", forState: UIControlState.Normal)
        }
        if let zone = scenes[indexPath.row].sceneZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        } else {
            btnZone.setTitle("--", forState: UIControlState.Normal)
        }
        if let category = scenes[indexPath.row].sceneCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        } else {
            btnCategory.setTitle("--", forState: UIControlState.Normal)
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
            // Here needs to be deleted even devices that are from gateway that is going to be deleted
            appDel.managedObjectContext?.deleteObject(scenes[indexPath.row])
            saveChanges()
            refreshSceneList()
            NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshScene, object: self, userInfo: nil)
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
