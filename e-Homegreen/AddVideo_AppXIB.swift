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

enum CommandType:Int {
    case media=0, application, notification
}

class AddVideo_AppXIB: CommonXIBTransitionVC{
    
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
        self.typeOfFile = typeOfFile
        self.device = device
        self.command = command
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        nameTextField.layer.borderWidth = 1
        pathTextField.layer.borderWidth = 1
        
        nameTextField.layer.cornerRadius = 2
        pathTextField.layer.cornerRadius = 2
        
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        pathTextField.layer.borderColor = UIColor.lightGray.cgColor
        
        nameTextField.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
        if typeOfFile == FileType.app {
            pathTextField.attributedPlaceholder = NSAttributedString(string:"Command",
                attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
            pathOrCmdLabel.text = "Command"
        }
        else{
            pathTextField.attributedPlaceholder = NSAttributedString(string:"Path",
                attributes:[NSForegroundColorAttributeName: UIColor.lightGray])
            pathOrCmdLabel.text = "Path"
        }

        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        nameTextField.delegate = self
        pathTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddVideo_AppXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        if let command = command{
            nameTextField.text = command.name
            pathTextField.text = command.comand
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func saveAction(_ sender: AnyObject) {
        guard let name = nameTextField.text , !name.isEmpty, let commandText = pathTextField.text , !commandText.isEmpty else{
            return
        }
        
        if command == nil{
            if let path = NSEntityDescription.insertNewObject(forEntityName: "PCCommand", into: appDel.managedObjectContext!) as? PCCommand{
                
                path.comand = commandText
                if typeOfFile == FileType.video{
                    print("Dodat video fajl")
                    path.commandType = CommandType.media.rawValue as NSNumber?
                }else{
                    print("Dodata aplikacija")
                    path.commandType = CommandType.application.rawValue as NSNumber?
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
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension AddVideo_AppXIB : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showAddVideoAppXIB(_ typeOfFile:FileType, device:Device,command:PCCommand?) -> AddVideo_AppXIB {
        let addInList = AddVideo_AppXIB(typeOfFile:typeOfFile, device:device, command:command)
        self.present(addInList, animated: true, completion: nil)
        return addInList
    }
}
