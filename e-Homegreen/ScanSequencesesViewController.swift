//
//  ScanSequencesesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanSequencesesViewController: UIViewController, UITextFieldDelegate, SceneGalleryDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var editCycle: UITextField!
    
    @IBOutlet weak var sequencesTableView: UITableView!
    
    func endEditingNow(){
        devAddressOne.resignFirstResponder()
        devAddressTwo.resignFirstResponder()
        devAddressThree.resignFirstResponder()
        IDedit.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        var toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        devAddressOne.inputAccessoryView = keyboardDoneButtonView
        devAddressTwo.inputAccessoryView = keyboardDoneButtonView
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
        
        //            if let sceneId = IDedit.text.toInt(), let sceneName = nameEdit.text, let address = devAddressThree.text.toInt() {
        //                if sceneId <= 32767 && address <= 255 {
        //                    switch choosedTab {
        //                    case .Scenes:
        //                        var scene = NSEntityDescription.insertNewObjectForEntityForName("Scene", inManagedObjectContext: appDel.managedObjectContext!) as! Scene
        //                        scene.sceneId = sceneId
        //                        scene.sceneName = sceneName
        //                        scene.sceneImageOne = UIImagePNGRepresentation(imageSceneOne.image)
        //                        scene.sceneImageTwo = UIImagePNGRepresentation(imageSceneTwo.image)
        //                        scene.gateway = gateway!
        //                        saveChanges()
        //                        refreshSceneList()
        //                        NSNotificationCenter.defaultCenter().postNotificationName("refreshSceneListNotification", object: self, userInfo: nil)
        //                    case .Events:
        //                        var event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: appDel.managedObjectContext!) as! Event
        //                        event.eventId = sceneId
        //                        event.eventName = sceneName
        //                        event.eventImageOne = UIImagePNGRepresentation(imageSceneOne.image)
        //                        event.eventImageTwo = UIImagePNGRepresentation(imageSceneTwo.image)
        //                        event.gateway = gateway!
        //                        saveChanges()
        //                        refreshSceneList()
        //                        NSNotificationCenter.defaultCenter().postNotificationName("refreshEventListNotification", object: self, userInfo: nil)
        //                    case .Sequences:
        //                        var sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: appDel.managedObjectContext!) as! Sequence
        //                        sequence.sequenceId = sceneId
        //                        sequence.sequenceName = sceneName
        //                        sequence.sequenceImageOne = UIImagePNGRepresentation(imageSceneOne.image)
        //                        sequence.sequenceImageTwo = UIImagePNGRepresentation(imageSceneTwo.image)
        //                        sequence.gateway = gateway!
        //                        saveChanges()
        //                        refreshSceneList()
        //                        NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
        //                    default:
        //                        assert(false, "Unexprected index")
        //                    }
        //                }
        //            }
        
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        //            if let scene = selected as? Scene {
        //                appDel.managedObjectContext!.deleteObject(scene)
        //                IDedit.text = ""
        //                nameEdit.text = ""
        //                refreshSceneList()
        //                NSNotificationCenter.defaultCenter().postNotificationName("refreshSceneListNotification", object: self, userInfo: nil)
        //            }
        //            if let event = selected as? Event {
        //                appDel.managedObjectContext!.deleteObject(event)
        //                IDedit.text = ""
        //                nameEdit.text = ""
        //                refreshSceneList()
        //                NSNotificationCenter.defaultCenter().postNotificationName("refreshEventListNotification", object: self, userInfo: nil)
        //            }
        //            if let sequence = selected as? Sequence {
        //                appDel.managedObjectContext!.deleteObject(sequence)
        //                IDedit.text = ""
        //                nameEdit.text = ""
        //                refreshSceneList()
        //                NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
        //            }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
                if let cell = tableView.dequeueReusableCellWithIdentifier("sequencesCell") as? SequencesCell {
        //            if choosedTab == .Scenes {
        //                cell.backgroundColor = UIColor.clearColor()
        //                cell.labelID.text = "\(choosedTabArray[indexPath.row].sceneId)"
        //                cell.labelName.text = "\(choosedTabArray[indexPath.row].sceneName)"
        //                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageOne) {
        //                    cell.imageOne.image = sceneImage
        //                }
        //                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageTwo) {
        //                    cell.imageTwo.image = sceneImage
        //                }
        //            } else if choosedTab == .Events {
        //                cell.backgroundColor = UIColor.clearColor()
        //                cell.labelID.text = "\(choosedTabArray[indexPath.row].eventId)"
        //                cell.labelName.text = "\(choosedTabArray[indexPath.row].eventName)"
        //                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageOne) {
        //                    cell.imageOne.image = sceneImage
        //                }
        //                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageTwo) {
        //                    cell.imageTwo.image = sceneImage
        //                }
        //            } else if choosedTab == .Sequences {
        //                cell.backgroundColor = UIColor.clearColor()
        //                cell.labelID.text = "\(choosedTabArray[indexPath.row].sequenceId)"
        //                cell.labelName.text = "\(choosedTabArray[indexPath.row].sequenceName)"
        //                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageOne) {
        //                    cell.imageOne.image = sceneImage
        //                }
        //                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageTwo) {
        //                    cell.imageTwo.image = sceneImage
        //                }
        //            }
                    return cell
                }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "sequnces"
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

}

class SequencesCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    
}
