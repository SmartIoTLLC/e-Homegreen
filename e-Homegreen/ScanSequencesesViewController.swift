//
//  ScanSequencesesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanSequencesesViewController: UIViewController, UITextFieldDelegate, SceneGalleryDelegate, UITableViewDataSource, UITableViewDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var IDedit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var localcastSwitch: UISwitch!
    @IBOutlet weak var editCycle: UITextField!
    @IBOutlet weak var btnZone: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnLevel: CustomGradientButton!
    
    @IBOutlet weak var sequencesTableView: UITableView!
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
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
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        updateSequenceList()
        
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
    
    func changeValue (sender:UISwitch){
        if sender.tag == 100 {
            localcastSwitch.on = false
        } else if sender.tag == 200 {
            broadcastSwitch.on = false
        }
    }
    
    func refreshSequenceList() {
        updateSequenceList()
        sequencesTableView.reloadData()
    }
    
    func updateSequenceList() {
        let fetchRequest = NSFetchRequest(entityName: "Sequence")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
            sequences = fetResults!
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
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    @IBAction func btnEdit(sender: AnyObject) {
    }
    @IBAction func btnAdd(sender: AnyObject) {
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!), let cycles = Int(editCycle.text!) {
            if sceneId <= 32767 && address <= 255 {
                var itExists = false
                var existingSequence:Sequence?
                for sequence in sequences {
                    if sequence.sequenceId == sceneId && sequence.address != address {
                        itExists = true
                        existingSequence = sequence
                    }
                }
                if !itExists {
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        let sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: appDel.managedObjectContext!) as! Sequence
                        sequence.sequenceId = sceneId
                        sequence.sequenceName = sceneName
                        sequence.address = address
                        sequence.sequenceImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                        sequence.sequenceImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                        sequence.isBroadcast = broadcastSwitch.on
                        sequence.isLocalcast = localcastSwitch.on
                        sequence.sequenceCycles = cycles
                        if btnLevel.titleLabel?.text != "--" {
                            sequence.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            sequence.sequenceZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            sequence.sequenceCategory = btnCategory.titleLabel!.text!
                        }
                        sequence.gateway = gateway!
                        saveChanges()
                        refreshSequenceList()
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
                    }
                } else {
                    if btnLevel.titleLabel!.text != "--" && btnCategory.titleLabel!.text != "--" {
                        existingSequence!.sequenceId = sceneId
                        existingSequence!.sequenceName = sceneName
                        existingSequence!.address = address
                        existingSequence!.sequenceImageOne = UIImagePNGRepresentation(imageSceneOne.image!)!
                        existingSequence!.sequenceImageTwo = UIImagePNGRepresentation(imageSceneTwo.image!)!
                        existingSequence!.isBroadcast = broadcastSwitch.on
                        existingSequence!.isLocalcast = localcastSwitch.on
                        existingSequence!.sequenceCycles = cycles
                        if btnLevel.titleLabel?.text != "--" {
                            existingSequence!.entityLevel = btnLevel.titleLabel!.text!
                        }
                        if btnZone.titleLabel?.text != "--" {
                            existingSequence!.sequenceZone = btnZone.titleLabel!.text!
                        }
                        if btnCategory.titleLabel?.text != "--" {
                            existingSequence!.sequenceCategory = btnCategory.titleLabel!.text!
                        }
                        existingSequence!.gateway = gateway!
                        saveChanges()
                        refreshSequenceList()
                        NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
                    }
                }
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
//        if let sequence = selected as? Sequence {
//            appDel.managedObjectContext!.deleteObject(sequence)
//            IDedit.text = ""
//            nameEdit.text = ""
//            devAddressThree.text = ""
//            btnLevel.setTitle("--", forState: UIControlState.Normal)
//            btnZone.setTitle("--", forState: UIControlState.Normal)
//            btnCategory.setTitle("--", forState: UIControlState.Normal)
//            broadcastSwitch.on = false
//            localcastSwitch.on = false
//            saveChanges()
//            refreshSequenceList()
//            NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
//        }
        if sequences.count != 0 {
            for sequence in sequences {
                appDel.managedObjectContext!.deleteObject(sequence)
            }
            saveChanges()
            refreshSequenceList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("sequencesCell") as? SequencesCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(sequences[indexPath.row].sequenceId)"
            cell.labelName.text = "\(sequences[indexPath.row].sequenceName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(sequences[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(sequences[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(sequences[indexPath.row].address)))"
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
        localcastSwitch.on = sequences[indexPath.row].isLocalcast.boolValue
        if let level = sequences[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        } else {
            btnLevel.setTitle("--", forState: UIControlState.Normal)
        }
        if let zone = sequences[indexPath.row].sequenceZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        } else {
            btnZone.setTitle("--", forState: UIControlState.Normal)
        }
        if let category = sequences[indexPath.row].sequenceCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        } else {
            btnCategory.setTitle("--", forState: UIControlState.Normal)
        }
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
    func  tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            let deleteMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive){(action) -> Void in
                self.tableView(self.sequencesTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
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
            appDel.managedObjectContext?.deleteObject(sequences[indexPath.row])
            saveChanges()
            refreshSequenceList()
            NSNotificationCenter.defaultCenter().postNotificationName("refreshSequenceListNotification", object: self, userInfo: nil)
        }
        
    }

}

class SequencesCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!
    @IBOutlet weak var address: UILabel!
    
}
