//
//  MacroViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/6/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class MacroViewController: UIViewController {
    
    @IBOutlet weak var idTextField: EditTextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var macrosTableView: UITableView!
    
    @IBOutlet weak var imageSceneOne: UIImageView!
    @IBOutlet weak var imageSceneTwo: UIImageView!
    
    var gateway:Gateway!
    var filterParametar:FilterItem!
    
    var imageDataOne:Data?
    var customImageOne:String?
    var defaultImageOne:String?
    
    var imageDataTwo:Data?
    var customImageTwo:String?
    var defaultImageTwo:String?
    
    var level:Zone?
    var zoneSelected:Zone?
    var category:Category?
    
    var macros:[Macro] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        idTextField.inputAccessoryView = CustomToolBar()
        
        imageSceneOne.isUserInteractionEnabled = true
        imageSceneOne.tag = 1
        imageSceneOne.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MacroViewController.handleTap(_:))))
        imageSceneTwo.isUserInteractionEnabled = true
        imageSceneTwo.tag = 2
        imageSceneTwo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MacroViewController.handleTap(_:))))
        
        getMacros()

        // Do any additional setup after loading the view.
    }
    
    func getMacros() {
        macros = DatabaseMacrosController.shared.getMacrosByLocation(location: gateway.location)
        macrosTableView.reloadData()
    }
    
    @IBAction func addOrEditButton(_ sender: AnyObject) {
        
        guard let id = idTextField.text else{
            self.view.makeToast(message: "ID field can't be empty")
            return
        }
        guard let macroId = Int(id) else{
            self.view.makeToast(message: "ID can be only number")
            return
        }
        guard let macroName = nameTextField.text, macroName != "" else{
            self.view.makeToast(message: "Name field can't be empty")
            return
        }
        
        DatabaseMacrosController.shared.createMacro(macroId: macroId, macroName: macroName, location: gateway.location, macroImageOneDefault: defaultImageOne, macroImageTwoDefault: defaultImageTwo, macroImageOneCustom: customImageOne, macroImageTwoCustom: customImageTwo, imageDataOne: imageDataOne, imageDataTwo: imageDataTwo)
        
        getMacros()
    }
    
    @IBAction func removeAllButton(_ sender: UIButton) {
        showAlertView(sender, message: "Are you sure you want to delete all macros?") { (action) in
            if action == ReturnedValueFromAlertView.delete{
                DatabaseMacrosController.shared.deleteAllMacros(self.gateway)
                self.getMacros()
                self.view.endEditing(true)
            }
        }
    }
    
    func handleTap (_ gesture:UITapGestureRecognizer) {
        if let index = gesture.view?.tag {
            showGallery(index, user: gateway.location.user).delegate = self
        }
    }
    
    


}

extension MacroViewController: SceneGalleryDelegate{
    
    func backImage(_ image: Image, imageIndex: Int) {
        if imageIndex == 1 {
            defaultImageOne = nil
            customImageOne = image.imageId
            imageDataOne = nil
            self.imageSceneOne.image = UIImage(data: image.imageData! as Data)
        }
        if imageIndex == 2 {
            defaultImageTwo = nil
            customImageTwo = image.imageId
            imageDataTwo = nil
            self.imageSceneTwo.image = UIImage(data: image.imageData! as Data)
        }
    }
    
    func backString(_ strText: String, imageIndex:Int) {
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
    
    func backImageFromGallery(_ data: Data, imageIndex:Int ) {
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

extension MacroViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MacroCell") as? MacroCell {
            cell.backgroundColor = UIColor.clear
            
            cell.setItem(macro: macros[indexPath.row])
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return macros.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        idTextField.text = "\(macros[indexPath.row].macroId)"
        nameTextField.text = macros[indexPath.row].name
        
        defaultImageOne = macros[indexPath.row].macroImageOneDefault
        customImageOne = macros[indexPath.row].macroImageOneCustom
        imageDataOne = nil
        
        defaultImageTwo = macros[indexPath.row].macroImageTwoDefault
        customImageTwo = macros[indexPath.row].macroImageTwoCustom
        imageDataTwo = nil
        
        if let id = macros[indexPath.row].macroImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneOne.image = UIImage(data: data)
                }else{
                    if let defaultImage = macros[indexPath.row].macroImageOneDefault{
                        imageSceneOne.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = macros[indexPath.row].macroImageOneDefault{
                    imageSceneOne.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = macros[indexPath.row].macroImageOneDefault{
                imageSceneOne.image = UIImage(named: defaultImage)
            }
        }
        
        if let id = macros[indexPath.row].macroImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageSceneTwo.image = UIImage(data: data)
                }else{
                    if let defaultImage = macros[indexPath.row].macroImageTwoDefault{
                        imageSceneTwo.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = macros[indexPath.row].macroImageTwoDefault{
                    imageSceneTwo.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = macros[indexPath.row].macroImageTwoDefault{
                imageSceneTwo.image = UIImage(named: defaultImage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.macrosTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DatabaseMacrosController.shared.deleteMacro(macros[indexPath.row])
            macros.remove(at: indexPath.row)
            macrosTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension MacroViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class MacroCell: UITableViewCell {
    
    @IBOutlet weak var macroIdLabel: UILabel!
    @IBOutlet weak var macroNameLabel: UILabel!
    @IBOutlet weak var macroActionsLabel: UILabel!
    
    @IBOutlet weak var imagePositive: UIImageView!
    @IBOutlet weak var imageNegative: UIImageView!
    
    func setItem(macro: Macro){
        macroIdLabel.text = "\(macro.macroId)"
        macroNameLabel.text = macro.name
        macroActionsLabel.text = "1"
        
        if let id = macro.macroImageOneCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imagePositive.image = UIImage(data: data)
                }else{
                    if let defaultImage = macro.macroImageOneDefault{
                        imagePositive.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = macro.macroImageOneDefault{
                    imagePositive.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = macro.macroImageOneDefault{
                imagePositive.image = UIImage(named: defaultImage)
            }
        }
        
        if let id = macro.macroImageTwoCustom{
            if let image = DatabaseImageController.shared.getImageById(id){
                if let data =  image.imageData {
                    imageNegative.image = UIImage(data: data)
                }else{
                    if let defaultImage = macro.macroImageTwoDefault{
                        imageNegative.image = UIImage(named: defaultImage)
                    }
                }
            }else{
                if let defaultImage = macro.macroImageTwoDefault{
                    imageNegative.image = UIImage(named: defaultImage)
                }
            }
        }else{
            if let defaultImage = macro.macroImageTwoDefault{
                imageNegative.image = UIImage(named: defaultImage)
            }
        }
    }
    
}
