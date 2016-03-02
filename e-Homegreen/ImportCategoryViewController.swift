//
//  ImportCategoryViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 9/19/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

//IPGCW02001_000_000_Categories List
class ImportCategoryViewController: UIViewController, ImportFilesDelegate {
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var categories:[Category] = []
    var gateway:Gateway?
    
    @IBOutlet weak var importCategoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
//        let categories:[CategoryJSON] = DataImporter.createCategoriesFromFile("IPGCW02001_000_000_Categories List.json")!
//        print(categories)
        
        refreshCategoryList()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var txtFrom: UITextField!
    @IBOutlet weak var txtTo: UITextField!
    
    @IBAction func btnScanCategories(sender: AnyObject) {
        
    }
    @IBAction func brnDeleteAll(sender: AnyObject) {
        for var item = 0; item < categories.count; item++ {
            if categories[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(categories[item])
            }
        }
        createCategories(gateway!)
        saveChanges()
        refreshCategoryList()
    }
    
    @IBAction func btnCleearFields(sender: AnyObject) {
        txtFrom.text = ""
        txtTo.text = ""
    }
    
    func backURL(strText: String) {
//        First - Delete all categories
        for var item = 0; item < categories.count; item++ {
            if categories[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(categories[item])
            }
        }
//        Second - Take default categories from bundle
        let categoriesJSONBundle = DataImporter.createCategoriesFromFileFromNSBundle()
//        Third - Add new zones and edit zones from bundle if needed
        if var categoriesJSON = DataImporter.createCategoriesFromFile(strText) {
            if categoriesJSON.count != 0 {
                for categoryJsonBundle in categoriesJSONBundle! {
                    var isExisting = false
                    for categoryJSON in categoriesJSON {
                        if categoryJsonBundle.id == categoryJSON.id {
                            isExisting = true
                        }
                    }
                    if !isExisting {
                        categoriesJSON.append(categoryJsonBundle)
                    }
                }
                for categoryJSON in categoriesJSON {
                    let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                    category.id = categoryJSON.id
                    category.name = categoryJSON.name
                    category.categoryDescription = categoryJSON.description
                    if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                        category.isVisible = NSNumber(bool: false)
                    } else {
                        category.isVisible = NSNumber(bool: true)
                    }
                    category.gateway = gateway!
                    saveChanges()
                }
            } else {
                createCategories(gateway!)
            }
        } else {
            createCategories(gateway!)
        }
        refreshCategoryList()
    }

    @IBAction func btnImportFile(sender: AnyObject) {
        showImportFiles().delegate = self
    }
    
    func createCategories(gateway:Gateway) {
        if let categoriesJSON = DataImporter.createCategoriesFromFileFromNSBundle() {
            for categoryJSON in categoriesJSON {
                let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.gateway) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: false), gateway)
                } else {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.gateway) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: true), gateway)
                }
                saveChanges()
            }
        }
    }
    
    func refreshCategoryList () {
        updateCategoryList()
        importCategoryTableView.reloadData()
    }
    
    
    func updateCategoryList () {
        let fetchRequest = NSFetchRequest(entityName: "Category")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "id", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
            categories = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func isVisibleValueChanged (sender:UISwitch) {
        if sender.on == true {
            categories[sender.tag].isVisible = true
        }else {
            categories[sender.tag].isVisible = false
        }
        saveChanges()
        importCategoryTableView.reloadData()
    }

}
extension ImportCategoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showEditCategory(categories[indexPath.row])
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if ((categories[indexPath.row].id as Int) >= 1 && (categories[indexPath.row].id as Int) <= 19) || (categories[indexPath.row].id as Int) == 255 {
            return false
        }
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            appDel.managedObjectContext?.deleteObject(categories[indexPath.row])
            appDel.saveContext()
            refreshCategoryList()
        }
    }
}
extension ImportCategoryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = importCategoryTableView.dequeueReusableCellWithIdentifier("importCategory") as? ImportCategoryTableViewCell {
            cell.backgroundColor = UIColor.clearColor()
            cell.lblName.text = "\(categories[indexPath.row].id)" + ", \(categories[indexPath.row].name)"
            cell.lblDescription.text = "Desc: \(categories[indexPath.row].categoryDescription)"
            cell.switchVisible.on = categories[indexPath.row].isVisible.boolValue
            cell.switchVisible.tag = indexPath.row
            cell.switchVisible.addTarget(self, action: "isVisibleValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "\(categories[indexPath.row].id). \(categories[indexPath.row].name), Desc: \(categories[indexPath.row].categoryDescription)"
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
}
class ImportCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var switchEnable: UISwitch!
    @IBOutlet weak var switchVisible: UISwitch!
    
}
