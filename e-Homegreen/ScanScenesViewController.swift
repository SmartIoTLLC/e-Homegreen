//
//  ScanScenesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanScenesViewController: UIViewController,UITextFieldDelegate, SceneGalleryDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    
    @IBOutlet weak var sceneTableView: UITableView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        var toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        for scene in gateway!.scenes {
            scenes.append(scene as! Scene)
        }
        refreshSceneList()
        
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
        
        // Do any additional setup after loading the view.
    }
    
    func refreshSceneList() {
        updateSceneList()
        sceneTableView.reloadData()
    }
    
    func updateSceneList () {
        var fetchRequest = NSFetchRequest(entityName: "Scene")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Scene]
        if let results = fetResults {
            scenes = results
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
                var scene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as! Scene
                scene.sceneId = sceneId
                scene.sceneName = sceneName
                scene.sceneImageOne = UIImagePNGRepresentation(imageSceneOne.image)
                scene.sceneImageTwo = UIImagePNGRepresentation(imageSceneTwo.image)
                scene.isBroadcast = NSNumber(bool: false)
                scene.gateway = gateway!
                saveChanges()
                refreshSceneList()
                NSNotificationCenter.defaultCenter().postNotificationName("refreshSceneListNotification", object: self, userInfo: nil)
            }
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if let scene = selected as? Scene {
            appDel.managedObjectContext!.deleteObject(scene)
            IDedit.text = ""
            nameEdit.text = ""
            refreshSceneList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshSceneListNotification", object: self, userInfo: nil)
        }
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as? SceneCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(scenes[indexPath.row].sceneId)"
            cell.labelName.text = "\(scenes[indexPath.row].sceneName)"
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
    
}

class SceneCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    
}
