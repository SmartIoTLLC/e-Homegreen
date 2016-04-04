//
//  EditCategoryViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/2/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

protocol EditCategoryDelegate{
    func editCategoryFInished()
}

class EditCategoryViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    var isPresenting: Bool = true
    
    var category:Category?
    var delegate:EditCategoryDelegate?
    var location:Location?
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    init(category:Category?, location:Location?){
        super.init(nibName: "EditCategoryViewController", bundle: nil)
        transitioningDelegate = self
        self.category = category
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        idTextField.inputAccessoryView = keyboardDoneButtonView

        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)

        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        idTextField.delegate = self
        
        if  let category = category{
            idTextField.text = "\(category.id)"
            nameTextField.text = category.name
            descriptionTextField.text = category.categoryDescription
            idTextField.enabled = false
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCategory(id:Int, location:Location) -> [Category]? {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Category")
        let predicate = NSPredicate(format: "location == %@", location)
        let predicateTwo = NSPredicate(format: "id == %@", NSNumber(integer: id))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateTwo])
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return nil
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if let name = nameTextField.text, let id = idTextField.text, let idValid = Int(id) {
            if category == nil{
                if let location = location, let category = fetchCategory(idValid, location: location){
                    if category != []{
                        for item in category{
                            item.name = name
                            if let desc = descriptionTextField.text{
                                item.categoryDescription = desc
                            }
                        }
                    }else{
                        if let categoryNew = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as? Category{
                            categoryNew.id = idValid
                            categoryNew.name = name
                            if let desc = descriptionTextField.text{
                                categoryNew.categoryDescription = desc
                            }
                            categoryNew.location = location
                        }
                    }
                }else if let categoryNew = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as? Category{
                    categoryNew.id = idValid
                    categoryNew.name = name
                    if let desc = descriptionTextField.text{
                        categoryNew.categoryDescription = desc
                    }
                    saveChanges()
                }
            }else{
                category?.name = name
                if let desc = descriptionTextField.text{
                    category?.categoryDescription = desc
                }
                saveChanges()
            }
            delegate?.editCategoryFInished()
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

extension EditCategoryViewController : UIViewControllerAnimatedTransitioning {
    
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



extension EditCategoryViewController : UIViewControllerTransitioningDelegate {
    
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
    func showEditCategory(category:Category?, location:Location?) -> EditCategoryViewController{
        let editCategory = EditCategoryViewController(category: category, location: location)
        self.presentViewController(editCategory, animated: true, completion: nil)
        return editCategory
    }
}