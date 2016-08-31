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
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.inputAccessoryView = CustomToolBar()
//        levelTextField.inputAccessoryView = CustomToolBar()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        nameTextField.delegate = self
        levelTextField.delegate = self
        idTextField.delegate = self
        
        if let zoneForEdit = editZone {
            idTextField.text = "\(zoneForEdit.id!.integerValue)"
            nameTextField.text = zoneForEdit.name!
            levelTextField.text = zoneForEdit.zoneDescription
            levelButton.setTitle("", forState: .Normal)
            if let id = zoneForEdit.level?.integerValue{
                if id != 0 {
                    if let level = DatabaseZoneController.shared.getZoneById(id, location: location){
                        self.level = level
                        levelButton.setTitle(level.name, forState: .Normal)
                    }
                }
            }
            idTextField.enabled = false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditZoneViewController.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override func nameAndId(name: String, id: String) {
        level = FilterController.shared.getZoneByObjectId(id)
        levelButton.setTitle(name, forState: .Normal)
    }
    
    @IBAction func levelButton(sender: AnyObject) {
        var popoverList:[PopOverItem] = []
        
        let list:[Zone] = FilterController.shared.getLevelsByLocation(location)
        for item in list {
            popoverList.append(PopOverItem(name: item.name!, id: item.objectID.URIRepresentation().absoluteString))
        }
        
        popoverList.insert(PopOverItem(name: "", id: ""), atIndex: 0)
        openPopover(sender, popOverList:popoverList)
        
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchZones(id:Int, location:Location) -> [Zone]? {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Zone")
        let predicate = NSPredicate(format: "location == %@", location)
        let predicateTwo = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateTwo])
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return nil
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        guard let name = nameTextField.text where name != "" else{
            return
        }
        
        guard let idTemp = idTextField.text, let id = Int(idTemp) else{
            return
        }
        
        if editZone == nil{
            if let zones = fetchZones(id, location: location){
                if zones != []{
                    for item in zones{
                        item.name = name
                        if let level = level{
                            item.level = level.id
                        }else{
                            item.level = 0
                        }
                    }
                }else{
                    if let zoneInsert = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as? Zone{
                        zoneInsert.id = id
                        zoneInsert.name = name
                        zoneInsert.location = location
                        zoneInsert.orderId = id
                        zoneInsert.allowOption = 1
                        zoneInsert.zoneDescription = levelTextField.text
                        if let level = level{
                            zoneInsert.level = level.id
                        }else{
                            zoneInsert.level = 0
                        }
                    }
                }
            }
            CoreDataController.shahredInstance.saveChanges()
        }else{
            editZone?.name = name
            editZone?.zoneDescription = levelTextField.text
            if let level = level{
                editZone?.level = level.id
            }else{
                editZone?.level = 0
            }
            
            CoreDataController.shahredInstance.saveChanges()
            saveChanges()
        }
        delegate?.editZoneFInished()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveChanges() {
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshIBeacon, object: self, userInfo: nil)
    }


}

extension EditZoneViewController : UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EditZoneViewController : UIGestureRecognizerDelegate{
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            self.view.endEditing(true)
            return false
        }
        return true
    }
}

extension EditZoneViewController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.5, 1.5)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension EditZoneViewController : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}

extension UIViewController {
    func showEditZone(zone:Zone?, location:Location) -> EditZoneViewController {
        let editzone = EditZoneViewController(zone: zone, location: location)
        self.presentViewController(editzone, animated: true, completion: nil)
        return editzone
    }
}
