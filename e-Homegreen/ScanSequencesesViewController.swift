//
//  ScanSequencesesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

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
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var gateway:Gateway?
    var sequences:[Sequence] = []
    
    var selected:AnyObject?
    
    func endEditingNow(){
//        devAddressOne.resignFirstResponder()
//        devAddressTwo.resignFirstResponder()
        devAddressThree.resignFirstResponder()
        IDedit.resignFirstResponder()
        editCycle.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        var toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        for sequenceFromGateway in gateway!.sequences {
            if let sequence = sequenceFromGateway as? Sequence {
                sequences.append(sequence)
                println(sequences.count)
            }
        }
        refreshSequenceList()
        
//        devAddressOne.inputAccessoryView = keyboardDoneButtonView
//        devAddressTwo.inputAccessoryView = keyboardDoneButtonView
        devAddressThree.inputAccessoryView = keyboardDoneButtonView
        IDedit.inputAccessoryView = keyboardDoneButtonView
        editCycle.inputAccessoryView = keyboardDoneButtonView
        
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
    
    func refreshSequenceList() {
        updateSequenceList()
        sequencesTableView.reloadData()
    }
    
    func updateSequenceList () {
        var fetchRequest = NSFetchRequest(entityName: "Sequence")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Sequence]
        if let results = fetResults {
            sequences = results
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
        if let sceneId = IDedit.text.toInt(), let sceneName = nameEdit.text, let address = devAddressThree.text.toInt(), let cycles = editCycle.text.toInt() {
            if sceneId <= 32767 && address <= 255 {
                var sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: appDel.managedObjectContext!) as! Sequence
                sequence.sequenceId = sceneId
                sequence.sequenceName = sceneName
                sequence.address = address
                sequence.sequenceImageOne = UIImagePNGRepresentation(imageSceneOne.image)
                sequence.sequenceImageTwo = UIImagePNGRepresentation(imageSceneTwo.image)
                sequence.isBroadcast = NSNumber(bool: broadcastSwitch.on)
                sequence.sequenceCycles = cycles
                sequence.gateway = gateway!
                saveChanges()
                refreshSequenceList()
                NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
            }
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if let sequence = selected as? Sequence {
            appDel.managedObjectContext!.deleteObject(sequence)
            IDedit.text = ""
            nameEdit.text = ""
            refreshSequenceList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
        }
    }
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("sequencesCell") as? SequencesCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(sequences[indexPath.row].sequenceId)"
            cell.labelName.text = "\(sequences[indexPath.row].sequenceName)"
            if let sceneImage = UIImage(data: sequences[indexPath.row].sequenceImageOne) {
                cell.imageOne.image = sceneImage
            }
            if let sceneImage = UIImage(data: sequences[indexPath.row].sequenceImageTwo) {
                cell.imageTwo.image = sceneImage
            }
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "sequnces"
        return cell
    
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = sequences[indexPath.row]
        IDedit.text = "\(sequences[indexPath.row].sequenceId)"
        nameEdit.text = "\(sequences[indexPath.row].sequenceName)"
        devAddressThree.text = "\(returnThreeCharactersForByte(Int(sequences[indexPath.row].address)))"
        editCycle.text = "\(sequences[indexPath.row].sequenceCycles)"
        broadcastSwitch.on = sequences[indexPath.row].isBroadcast.boolValue
        if let sceneImage = UIImage(data: sequences[indexPath.row].sequenceImageOne) {
            imageSceneOne.image = sceneImage
        }
        if let sceneImage = UIImage(data: sequences[indexPath.row].sequenceImageTwo) {
            imageSceneTwo.image = sceneImage
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sequences.count
    }

}

class SequencesCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    
    
}
