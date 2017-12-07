//
//  EditZoneViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/2/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

protocol EditZoneDelegate{
    func editZoneFInished()
}

class EditZoneViewController: PopoverVC {
    
    var isPresenting: Bool = true
    
    var delegate:EditZoneDelegate?
    
    var editZone:Zone?
    var level:Zone?
    var location:Location!
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    @IBOutlet weak var levelButton: CustomGradientButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    init(zone:Zone?, location:Location){
        super.init(nibName: "EditZoneViewController", bundle: nil)
        transitioningDelegate = self
        self.editZone = zone
        self.location = location
        modalPresentationStyle = UIModalPresentationStyle.custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.inputAccessoryView = CustomToolBar()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        nameTextField.delegate = self
        levelTextField.delegate = self
        idTextField.delegate = self
        
        if let zoneForEdit = editZone {
            idTextField.text = "\(zoneForEdit.id!.intValue)"
            nameTextField.text = zoneForEdit.name!
            levelTextField.text = zoneForEdit.zoneDescription
            levelButton.setTitle("", for: UIControlState())
            if let id = zoneForEdit.level?.intValue{
                if id != 0 {
                    if let level = DatabaseZoneController.shared.getZoneById(id, location: location) {
                        self.level = level
                        levelButton.setTitle(level.name, for: UIControlState())
                    }
                }
            }
            idTextField.isEnabled = false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditZoneViewController.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override func nameAndId(_ name: String, id: String) {
        level = FilterController.shared.getZoneByObjectId(id)
        levelButton.setTitle(name, for: UIControlState())
    }
    
    @IBAction func levelButton(_ sender: AnyObject) {
        var popoverList:[PopOverItem] = []
        
        let list:[Zone] = FilterController.shared.getLevelsByLocation(location)
        for item in list { popoverList.append(PopOverItem(name: item.name!, id: item.objectID.uriRepresentation().absoluteString)) }
        
        popoverList.insert(PopOverItem(name: "", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
        
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fetchZones(_ id:Int, location:Location) -> [Zone]? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Zone.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", location)
        let predicateTwo = NSPredicate(format: "id == %@", NSNumber(value: id as Int))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateTwo])
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Zone]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(String(describing: error)), \(error!.userInfo)")
           // abort()
        }
        return nil
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        
        guard let name = nameTextField.text , name != "" else { return }
        guard let idTemp = idTextField.text, let id = Int(idTemp) else { return }
        
        if editZone == nil {
            if let zones = fetchZones(id, location: location) {
                if zones != [] {
                    for item in zones {
                        item.name = name
                        if let level = level { item.level = level.id } else { item.level = 0 }
                    }
                } else {
                    if let zoneInsert = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: appDel.managedObjectContext!) as? Zone {
                        zoneInsert.id = id as NSNumber?
                        zoneInsert.name = name
                        zoneInsert.location = location
                        zoneInsert.orderId = id as NSNumber?
                        zoneInsert.allowOption = 1
                        zoneInsert.isVisible = true
                        zoneInsert.zoneDescription = levelTextField.text
                        if let level = level { zoneInsert.level = level.id } else { zoneInsert.level = 0 }
                    }
                }
            }
            CoreDataController.sharedInstance.saveChanges()
        } else {
            editZone?.name = name
            editZone?.zoneDescription = levelTextField.text
            if let level = level { editZone?.level = level.id } else { editZone?.level = 0 }
            
            CoreDataController.sharedInstance.saveChanges()
            saveChanges()
        }
        delegate?.editZoneFInished()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveChanges() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshIBeacon), object: self, userInfo: nil)
    }


}

extension EditZoneViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditZoneViewController : UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if touch.view!.isDescendant(of: backView) { dismissEditing(); return false }
        return true
    }
}

extension EditZoneViewController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}

extension EditZoneViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed == self { return self } else { return nil }
    }
    
}

extension UIViewController {
    func showEditZone(_ zone:Zone?, location:Location) -> EditZoneViewController {
        let editzone = EditZoneViewController(zone: zone, location: location)
        self.present(editzone, animated: true, completion: nil)
        return editzone
    }
}
