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
    
    var gateway:Gateway!
    var filterParametar:FilterItem!
    
    var macros:[Macro] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        
        idTextField.inputAccessoryView = CustomToolBar()
        
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
        
        DatabaseMacrosController.shared.createMacro(macroId: macroId, macroName: macroName, location: gateway.location)
        
        getMacros()
    }
    
    @IBAction func removeAllButton(_ sender: AnyObject) {
        
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
    }
    
}
