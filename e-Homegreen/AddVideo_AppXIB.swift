//
//  AddVideo_AppXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/10/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

protocol ImportPathDelegate{
    func importFinished()
}

class AddVideo_AppXIB: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var pathTextField: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var pathOrCmdLabel: UILabel!
    
    var typeOfFile:FileType!
    var device:Device!
    var command:PCCommand?
    
    var delegate:ImportPathDelegate?
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    init(typeOfFile:FileType, device:Device, command:PCCommand?){
        super.init(nibName: "AddVideo_AppXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.typeOfFile = typeOfFile
        self.device = device
        self.command = command
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        nameTextField.layer.borderWidth = 1
        pathTextField.layer.borderWidth = 1
        
        nameTextField.layer.cornerRadius = 2
        pathTextField.layer.cornerRadius = 2
        
        nameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        pathTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        nameTextField.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        if typeOfFile == FileType.App {
            pathTextField.attributedPlaceholder = NSAttributedString(string:"Command",
                attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
            pathOrCmdLabel.text = "Command"
        }
        else{
            pathTextField.attributedPlaceholder = NSAttributedString(string:"Path",
                attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
            pathOrCmdLabel.text = "Path"
        }

        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        nameTextField.delegate = self
        pathTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: Selector("dismissViewController"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        if let command = command{
            nameTextField.text = command.name
            pathTextField.text = command.comand
        }
        
        // Do any additional setup after loading the view.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func saveAction(sender: AnyObject) {
        guard let name = nameTextField.text where !name.isEmpty, let commandText = pathTextField.text where !commandText.isEmpty else{
            return
        }
        
        if command == nil{
            if let path = NSEntityDescription.insertNewObjectForEntityForName("PCCommand", inManagedObjectContext: appDel.managedObjectContext!) as? PCCommand{
                
                path.comand = commandText
                if typeOfFile == FileType.Video{
                    path.isRunCommand = false
                }else{
                    path.isRunCommand = true
                }
                path.name = name
                path.device = device
                
            }
        }else{
            command?.name = name
            command?.comand = commandText
        }
        CoreDataController.shahredInstance.saveChanges()
        delegate?.importFinished()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}

extension AddVideo_AppXIB : UIViewControllerAnimatedTransitioning {
    
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



extension AddVideo_AppXIB : UIViewControllerTransitioningDelegate {
    
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
    func showAddVideoAppXIB(typeOfFile:FileType, device:Device,command:PCCommand?) -> AddVideo_AppXIB {
        let addInList = AddVideo_AppXIB(typeOfFile:typeOfFile, device:device, command:command)
        self.presentViewController(addInList, animated: true, completion: nil)
        return addInList
    }
}
