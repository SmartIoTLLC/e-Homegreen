//
//  ProjectManagerViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/23/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class ProjectManagerViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource, AddUserDelegate {
    
    @IBOutlet weak var usersTableView: UITableView!
    
    var appDel:AppDelegate!
    var users:[User] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        updateUserList()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func changeDataBase(sender: AnyObject) {
        
    }
    
    @IBAction func editDataBase(sender: AnyObject) {
        
    }
    
    func addUserFinished() {
        reloadData()
    }
    
    func reloadData(){
        updateUserList()
        usersTableView.reloadData()
    }
    
    func updateUserList () {
        users = []
        let fetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptorOne = NSSortDescriptor(key: "username", ascending: true)
//        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
//        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne]
//        let predicateOne = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
//        var predicateArray:[NSPredicate] = [predicateOne]

//        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicateType.AndPredicateType, subpredicates: predicateArray)
//        fetchRequest.predicate = compoundPredicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [User]
            users = fetResults!
        } catch  {
            
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("userCell") as? UserCell{
            cell.setItem(users[indexPath.row])
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showAddUser(users[indexPath.row]).delegate = self
    }

}

class UserCell: UITableViewCell{
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userDataBaseNameLabel: UILabel!
    @IBOutlet weak var chooseDatabaseButton: UIButton!
    @IBOutlet weak var editDatabaseButton: UIButton!
    
    func setItem(user:User){
        userNameLabel.text = user.username
    }
    
}
