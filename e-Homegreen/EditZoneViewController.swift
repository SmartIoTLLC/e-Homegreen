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

class EditZoneViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var isPresenting: Bool = true
    
    var delegate:EditZoneDelegate?
    
    var editZone:Zone?
    var location:Location?
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var levelTextField: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    init(zone:Zone?, location:Location?){
        super.init(nibName: "EditZoneViewController", bundle: nil)
        transitioningDelegate = self
        self.editZone = zone
        self.location = location
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    func endEditingNow(){
        idTextField.resignFirstResponder()
        levelTextField.resignFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(EditZoneViewController.endEditingNow) )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        idTextField.inputAccessoryView = keyboardDoneButtonView
        levelTextField.inputAccessoryView = keyboardDoneButtonView
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        if UIScreen.mainScreen().scale > 2.5{
            nameTextField.layer.borderWidth = 1
            levelTextField.layer.borderWidth = 1
            idTextField.layer.borderWidth = 1
        }else{
            nameTextField.layer.borderWidth = 0.5
            levelTextField.layer.borderWidth = 0.5
            idTextField.layer.borderWidth = 0.5
        }
        
        nameTextField.layer.cornerRadius = 2
        levelTextField.layer.cornerRadius = 2
        idTextField.layer.cornerRadius = 2
        
        nameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        levelTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        idTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        nameTextField.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        levelTextField.attributedPlaceholder = NSAttributedString(string:"Level",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        idTextField.attributedPlaceholder = NSAttributedString(string:"Descprition",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        nameTextField.delegate = self
        levelTextField.delegate = self
        idTextField.delegate = self
        
        if let zoneForEdit = editZone {
            idTextField.text = "\(zoneForEdit.id!)"
            nameTextField.text = zoneForEdit.name!
            levelTextField.text = "\(zoneForEdit.level!)"
            idTextField.enabled = false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EditZoneViewController.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)

        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
    //FIXME: Ove zone i kategorije su promenjene i nemaju vise gejtvej vec imaju samo lokacije
    @IBAction func saveAction(sender: AnyObject) {
        if let name = nameTextField.text, let id = idTextField.text, let level = levelTextField.text, let levelValid = Int(level), let idValid = Int(id) {
            if editZone == nil{
                if let loc = location, let zones = fetchZones(idValid, location: loc){
                    if zones != []{
                        for item in zones{
                            item.name = name
                            item.level = levelValid
                        }
                    }else{
                        if let zoneInsert = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as? Zone{
                            zoneInsert.id = idValid
                            zoneInsert.name = name
                            zoneInsert.level = levelValid
                            zoneInsert.location = loc
                            zoneInsert.orderId = idValid
                        }
                    }
                }
//                else if let zoneInsert = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as? Zone{
//                    zoneInsert.id = idValid
//                    zoneInsert.name = name
//                    zoneInsert.level = levelValid
//        
//                }
                
                saveChanges()
            }else{
                editZone?.name = name
                editZone?.level = levelValid
                
                saveChanges()
            }
            delegate?.editZoneFInished()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshIBeacon, object: self, userInfo: nil)
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
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
    func showEditZone(zone:Zone?, location:Location?) -> EditZoneViewController {
        let editzone = EditZoneViewController(zone: zone, location: location)
        self.presentViewController(editzone, animated: true, completion: nil)
        return editzone
    }
}
