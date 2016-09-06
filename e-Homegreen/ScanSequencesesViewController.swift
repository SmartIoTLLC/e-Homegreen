//
//  ScanSequencesesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ScanSequencesesViewController: PopoverVC {
    
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
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var levelFromFilter:String = "All"
    var zoneFromFilter:String = "All"
    var categoryFromFilter:String = "All"
    
    var gateway:Gateway!
    var sequences:[Sequence] = []
    
    var selected:AnyObject?
    
    var button:UIButton!
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    var imageDataOne:NSData?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:NSData?
    var customImageTwo:String?
    var defaultImageTwo:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateSequenceList()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        IDedit.inputAccessoryView = CustomToolBar()
        editCycle.inputAccessoryView = CustomToolBar()
        
        nameEdit.delegate = self
        
        imageSceneOne.userInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanSequencesesViewController.handleTap(_:))))
        imageSceneTwo.userInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScanSequencesesViewController.handleTap(_:))))
        
        broadcastSwitch.tag = 100
        broadcastSwitch.on = false
        broadcastSwitch.addTarget(self, action: #selector(ScanSequencesesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        localcastSwitch.tag = 200
        localcastSwitch.on = false
        localcastSwitch.addTarget(self, action: #selector(ScanSequencesesViewController.changeValue(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        
        btnLevel.tag = 1
        btnZone.tag = 2
        btnCategory.tag = 3
        
        // Do any additional setup after loading the view.
    }
    
    override func sendFilterParametar(filterParametar: FilterItem) {
        levelFromFilter = filterParametar.levelName
        zoneFromFilter = filterParametar.zoneName
        categoryFromFilter = filterParametar.categoryName
        updateSequenceList()
        sequencesTableView.reloadData()
    }
    
    override func sendSearchBarText(text: String) {
        updateSequenceList()
        if !text.isEmpty{
            sequences = self.sequences.filter() {
                sequence in
                if sequence.sequenceName.lowercaseString.rangeOfString(text.lowercaseString) != nil{
                    return true
                }else{
                    return false
                }
            }
        }
        sequencesTableView.reloadData()
        
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
        var predicateArray:[NSPredicate] = []
        predicateArray.append(NSPredicate(format: "gateway == %@", gateway.objectID))
        if levelFromFilter != "All" {
            let levelPredicate = NSPredicate(format: "entityLevel == %@", levelFromFilter)
            predicateArray.append(levelPredicate)
        }
        if zoneFromFilter != "All" {
            let zonePredicate = NSPredicate(format: "sequenceZone == %@", zoneFromFilter)
            predicateArray.append(zonePredicate)
        }
        if categoryFromFilter != "All" {
            let categoryPredicate = NSPredicate(format: "sequenceCategory == %@", categoryFromFilter)
            predicateArray.append(categoryPredicate)
        }
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
            sequences = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    
    func handleTap (gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
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
        if let sceneId = Int(IDedit.text!), let sceneName = nameEdit.text, let address = Int(devAddressThree.text!), let cycles = Int(editCycle.text!) {
            if sceneId <= 32767 && address <= 255 {
                var itExists = false
                var existingSequence:Sequence?
                for sequence in sequences {
                    if sequence.sequenceId == sceneId && sequence.address == address {
                        itExists = true
                        existingSequence = sequence
                    }
                }
                if !itExists {
                    let sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: appDel.managedObjectContext!) as! Sequence
                    sequence.sequenceId = sceneId
                    sequence.sequenceName = sceneName
                    sequence.address = address
                    
                    if let customImageOne = customImageOne{
                        sequence.sequenceImageOneCustom = customImageOne
                        sequence.sequenceImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        sequence.sequenceImageOneDefault = def
                        sequence.sequenceImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            sequence.sequenceImageOneCustom = image.imageId
                            sequence.sequenceImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        sequence.sequenceImageTwoCustom = customImageTwo
                        sequence.sequenceImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        sequence.sequenceImageTwoDefault = def
                        sequence.sequenceImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            sequence.sequenceImageTwoCustom = image.imageId
                            sequence.sequenceImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    sequence.entityLevelId = level?.id
                    sequence.sequenceZoneId = zoneSelected?.id
                    sequence.sequenceCategoryId = category?.id
                    
                    sequence.isBroadcast = broadcastSwitch.on
                    sequence.isLocalcast = localcastSwitch.on
                    sequence.sequenceCycles = cycles
                    sequence.entityLevel = btnLevel.titleLabel!.text!
                    sequence.sequenceZone = btnZone.titleLabel!.text!
                    sequence.sequenceCategory = btnCategory.titleLabel!.text!
                    sequence.gateway = gateway
                    refreshSequenceList()
                } else {
                    existingSequence!.sequenceId = sceneId
                    existingSequence!.sequenceName = sceneName
                    existingSequence!.address = address
                    
                    if let customImageOne = customImageOne{
                        existingSequence!.sequenceImageOneCustom = customImageOne
                        existingSequence!.sequenceImageOneDefault = nil
                    }
                    if let def = defaultImageOne {
                        existingSequence!.sequenceImageOneDefault = def
                        existingSequence!.sequenceImageOneCustom = nil
                    }
                    if let data = imageDataOne{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingSequence!.sequenceImageOneCustom = image.imageId
                            existingSequence!.sequenceImageOneDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    if let customImageTwo = customImageTwo{
                        existingSequence!.sequenceImageTwoCustom = customImageTwo
                        existingSequence!.sequenceImageTwoDefault = nil
                    }
                    if let def = defaultImageTwo {
                        existingSequence!.sequenceImageTwoDefault = def
                        existingSequence!.sequenceImageTwoCustom = nil
                    }
                    if let data = imageDataTwo{
                        if let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: appDel.managedObjectContext!) as? Image{
                            image.imageData = data
                            image.imageId = NSUUID().UUIDString
                            existingSequence!.sequenceImageTwoCustom = image.imageId
                            existingSequence!.sequenceImageTwoDefault = nil
                            gateway.location.user!.addImagesObject(image)
                            
                        }
                    }
                    
                    existingSequence!.entityLevelId = level?.id
                    existingSequence!.sequenceZoneId = zoneSelected?.id
                    existingSequence!.sequenceCategoryId = category?.id
                    
                    existingSequence!.isBroadcast = broadcastSwitch.on
                    existingSequence!.isLocalcast = localcastSwitch.on
                    existingSequence!.sequenceCycles = cycles
                    existingSequence!.entityLevel = btnLevel.titleLabel!.text!
                    existingSequence!.sequenceZone = btnZone.titleLabel!.text!
                    existingSequence!.sequenceCategory = btnCategory.titleLabel!.text!
                    existingSequence!.gateway = gateway
                    refreshSequenceList()
                }
                CoreDataController.shahredInstance.saveChanges()
            }
        }
    }
    
    @IBAction func btnRemove(sender: AnyObject) {
        if sequences.count != 0 {
            for sequence in sequences {
                appDel.managedObjectContext!.deleteObject(sequence)
            }
            CoreDataController.shahredInstance.saveChanges()
            refreshSequenceList()
            self.view.endEditing(true)
        }
    }

}

extension ScanSequencesesViewController: SceneGalleryDelegate{
    
    func backImage(image: Image, imageIndex: Int) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = image.imageId
            imageDataOne = nil
            self.imageSceneOne.image = UIImage(data: image.imageData!)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = image.imageId
            imageDataTwo = nil
            self.imageSceneTwo.image = UIImage(data: image.imageData!)
        }
    }
    
    func backString(strText: String, imageIndex:Int) {
        if imageIndex == 1 {
            defaultImageOne = strText
            customImageOne = nil
            imageDataOne = nil
            self.imageSceneOne.image = UIImage(named: strText)
        }
        if imageIndex == 2 {
            defaultImageTwo = strText
            customImageTwo = nil
            imageDataTwo = nil
            self.imageSceneTwo.image = UIImage(named: strText)
        }
    }
    
    func backImageFromGallery(data: NSData, imageIndex:Int ) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = nil
            imageDataOne = data
            self.imageSceneOne.image = UIImage(data: data)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = nil
            imageDataTwo = data
            self.imageSceneTwo.image = UIImage(data: data)
        }
    }
}

extension ScanSequencesesViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ScanSequencesesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("sequencesCell") as? SequencesCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.labelID.text = "\(sequences[indexPath.row].sequenceId)"
            cell.labelName.text = "\(sequences[indexPath.row].sequenceName)"
            cell.address.text = "\(returnThreeCharactersForByte(Int(sequences[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(sequences[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(sequences[indexPath.row].address)))"
            if let id = sequences[indexPath.row].sequenceImageOneCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageOne.image = UIImage(data: data)
                    }else{
                        if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                            cell.imageOne.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageOne.image = UIImage(named: "lightBulb")
                        }
                    }
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                        cell.imageOne.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageOne.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                    cell.imageOne.image = UIImage(named: defaultImage)
                }else{
                    cell.imageOne.image = UIImage(named: "lightBulb")
                }
            }
            
            if let id = sequences[indexPath.row].sequenceImageTwoCustom{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        cell.imageTwo.image = UIImage(data: data)
                    }else{
                        if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                            cell.imageTwo.image = UIImage(named: defaultImage)
                        }else{
                            cell.imageTwo.image = UIImage(named: "lightBulb")
                        }
                    }
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                        cell.imageTwo.image = UIImage(named: defaultImage)
                    }else{
                        cell.imageTwo.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                    cell.imageTwo.image = UIImage(named: defaultImage)
                }else{
                    cell.imageTwo.image = UIImage(named: "lightBulb")
                }
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
        
        if let levelId = sequences[indexPath.row].entityLevelId as? Int {
            level = DatabaseZoneController.shared.getZoneById(levelId, location: gateway.location)
        }
        if let zoneId = sequences[indexPath.row].sequenceZoneId as? Int {
            zoneSelected = DatabaseZoneController.shared.getZoneById(zoneId, location: gateway.location)
        }
        if let categoryId = sequences[indexPath.row].sequenceCategoryId as? Int {
            category = DatabaseCategoryController.shared.getCategoryById(categoryId, location: gateway.location)
        }
        
        if let level = sequences[indexPath.row].entityLevel {
            btnLevel.setTitle(level, forState: UIControlState.Normal)
        }
        if let zone = sequences[indexPath.row].sequenceZone {
            btnZone.setTitle(zone, forState: UIControlState.Normal)
        }
        if let category = sequences[indexPath.row].sequenceCategory {
            btnCategory.setTitle(category, forState: UIControlState.Normal)
        }
        
        if let id = sequences[indexPath.row].sequenceImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneOne.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }else{
                    imageSceneOne.image = UIImage(named: "lightBulb")
                }
            }
        }else{
            if let defaultImage = sequences[indexPath.row].sequenceImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }else{
                imageSceneOne.image = UIImage(named: "lightBulb")
            }
        }
        
        if let id = sequences[indexPath.row].sequenceImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }else{
                        imageSceneTwo.image = UIImage(named: "lightBulb")
                    }
                }
            }else{
                if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }else{
                    imageSceneTwo.image = UIImage(named: "lightBulb")
                }
            }
        }else{
            if let defaultImage = sequences[indexPath.row].sequenceImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }else{
                imageSceneTwo.image = UIImage(named: "lightBulb")
            }
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
            appDel.managedObjectContext?.deleteObject(sequences[indexPath.row])
            CoreDataController.shahredInstance.saveChanges()
            refreshSequenceList()
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
