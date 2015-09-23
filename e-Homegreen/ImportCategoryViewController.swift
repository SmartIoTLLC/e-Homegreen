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
class ImportCategoryViewController: UIViewController {
    
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
    
    @IBAction func brnDeleteAll(sender: AnyObject) {
        for var item = 0; item < categories.count; item++ {
            if categories[item].gateway.objectID == gateway!.objectID {
                appDel.managedObjectContext!.deleteObject(categories[item])
            }
        }
        saveChanges()
        refreshCategoryList()
    }

    @IBAction func btnImportFile(sender: AnyObject) {
        if let categoriesJSON = DataImporter.createCategoriesFromFile("IPGCW02001_000_000_Categories List.json") {
            for categoryJSON in categoriesJSON {
                let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                category.id = categoryJSON.id
                category.name = categoryJSON.name
                category.categoryDescription = categoryJSON.description
                category.gateway = gateway!
                saveChanges()
            }
        }
        refreshCategoryList()
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

}
extension ImportCategoryViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
extension ImportCategoryViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "\(categories[indexPath.row].id). \(categories[indexPath.row].name), Desc: \(categories[indexPath.row].categoryDescription)"
        return cell
        
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
}
class ImportCategoryTableViewCell: UITableViewCell {
    
}