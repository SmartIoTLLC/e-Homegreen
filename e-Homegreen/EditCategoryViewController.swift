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

class EditCategoryViewController: CommonXIBTransitionVC {
    
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
        
        self.category = category
        self.location = location
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        idTextField.inputAccessoryView = CustomToolBar()

        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        idTextField.delegate = self
        
        if  let category = category{
            idTextField.text = "\(category.id!)"
            nameTextField.text = category.name
            descriptionTextField.text = category.categoryDescription
            idTextField.isEnabled = false
        }
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
    
    func fetchCategory(_ id:Int, location:Location) -> [Category]? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Category.fetchRequest()
        let predicate = NSPredicate(format: "location == %@", location)
        let predicateTwo = NSPredicate(format: "id == %@", NSNumber(value: id as Int))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicateTwo])
        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.fetch(fetchRequest) as? [Category]
            return fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return nil
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
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
                        if let categoryNew = NSEntityDescription.insertNewObject(forEntityName: "Category", into: appDel.managedObjectContext!) as? Category{
                            categoryNew.id = idValid as NSNumber?
                            categoryNew.name = name
                            if let desc = descriptionTextField.text{
                                categoryNew.categoryDescription = desc
                            }
                            categoryNew.location = location
                            categoryNew.orderId = idValid as NSNumber?
                            categoryNew.allowOption = 3
                            categoryNew.isVisible = true
                        }
                    }
                }else if let categoryNew = NSEntityDescription.insertNewObject(forEntityName: "Category", into: appDel.managedObjectContext!) as? Category{
                    categoryNew.id = idValid as NSNumber?
                    categoryNew.name = name
                    categoryNew.allowOption = 3
                    if let desc = descriptionTextField.text{
                        categoryNew.categoryDescription = desc
                    }
                    CoreDataController.shahredInstance.saveChanges()
                }
            }else{
                category?.name = name
                if let desc = descriptionTextField.text{
                    category?.categoryDescription = desc
                }
                CoreDataController.shahredInstance.saveChanges()
            }
            delegate?.editCategoryFInished()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelAction(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension EditCategoryViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UIViewController {
    func showEditCategory(_ category:Category?, location:Location?) -> EditCategoryViewController{
        let editCategory = EditCategoryViewController(category: category, location: location)
        self.present(editCategory, animated: true, completion: nil)
        return editCategory
    }
}
