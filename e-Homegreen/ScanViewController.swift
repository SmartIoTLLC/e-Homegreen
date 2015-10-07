//
//  ScanViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/27/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
// UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning,

import UIKit
import CoreData

class ScanViewController: UIViewController, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate{
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var container: UIView!
    
    var scanSceneViewController: ScanScenesViewController!
    var scanDeviceViewController: ScanDevicesViewController!
    var scanSequencesViewController: ScanSequencesesViewController!
    var scanEventsViewController: ScanEventsViewController!
    var scanTimersViewController: ScanTimerViewController!
    var importZoneViewController:ImportZoneViewController!
    var importCategoryViewController: ImportCategoryViewController!
    var scanFlagsViewController: ScanFlagViewController!
    
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var choosedTab:ChoosedTab = .Devices
    var senderButton:UIButton?
    
    enum ChoosedTab {
        case Devices, Scenes, Events, Sequences, Zones, Categories
        func returnStringDescription() -> String {
            switch self {
            case .Devices:
                return ""
            case .Scenes:
                return "Scene"
            case .Events:
                return "Event"
            case .Sequences:
                return "Sequence"
            case .Zones:
                return "Zones"
            case .Categories:
                return "Categories"
            }
        }
    }

//    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    

    
    
    var isPresenting:Bool = true
    var gateway:Gateway?
    var choosedTabArray:[AnyObject] = []
    var progressBar:ProgressBarVC?
    
//    @IBOutlet weak var deviceTableView: UITableView!

    
    func endEditingNow(){
//        rangeFrom.resignFirstResponder()
//        rangeTo.resignFirstResponder()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        scanSceneViewController = storyboard.instantiateViewControllerWithIdentifier("ScanScenes") as! ScanScenesViewController
        scanDeviceViewController = storyboard.instantiateViewControllerWithIdentifier("ScanDevices") as! ScanDevicesViewController
        scanSequencesViewController = storyboard.instantiateViewControllerWithIdentifier("ScanSequences") as! ScanSequencesesViewController
        scanEventsViewController = storyboard.instantiateViewControllerWithIdentifier("ScanEvents") as! ScanEventsViewController
        scanTimersViewController = storyboard.instantiateViewControllerWithIdentifier("ScanTimers") as! ScanTimerViewController
        importZoneViewController = storyboard.instantiateViewControllerWithIdentifier("ImportZone") as! ImportZoneViewController
        importCategoryViewController = storyboard.instantiateViewControllerWithIdentifier("ImportCategory") as! ImportCategoryViewController
        scanFlagsViewController = storyboard.instantiateViewControllerWithIdentifier("ScanFlags") as! ScanFlagViewController
        
        scanSceneViewController.gateway = gateway
        scanDeviceViewController.gateway = gateway
        scanSequencesViewController.gateway = gateway
        scanEventsViewController.gateway = gateway
        scanTimersViewController.gateway = gateway
        importZoneViewController.gateway = gateway
        importCategoryViewController.gateway = gateway
        scanFlagsViewController.gateway = gateway
        
        self.addChildViewController(scanDeviceViewController)
        scanDeviceViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
        container.addSubview(scanDeviceViewController.view)
        scanDeviceViewController.didMoveToParentViewController(self)
        
        // Do any additional setup after loading the view.
    }
    

    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var btnScreenMode: UIButton!
    
    @IBAction func btnScreenMode(sender: AnyObject) {
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            btnScreenMode.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            btnScreenMode.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
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
    func updateSceneList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: "Scene")
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        do {
            let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
            choosedTabArray = fetResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
//        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
//        if let results = fetResults {
//            choosedTabArray = results
//        } else {
//            print("Nije htela...")
//        }
    }
    func updateListFetchingFromCD (entity:String, entityId:String, entityName:String) {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetchRequest = NSFetchRequest(entityName: entity)
        let sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        let sortDescriptorTwo = NSSortDescriptor(key: entityId, ascending: true)
        let sortDescriptorThree = NSSortDescriptor(key: entityName, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        switch entity {
        case "Scene":
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Scene]
                choosedTabArray = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        case "Event":
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Event]
                choosedTabArray = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        case "Sequence":
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Sequence]
                choosedTabArray = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        case "Zones":
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Zone]
                choosedTabArray = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        case "Categories":
            do {
                let fetResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Category]
                choosedTabArray = fetResults!
            } catch let error1 as NSError {
                error = error1
                print("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        
        default:
            print("")
        }
    }
    func refreshSceneList() {
//        updateSceneList()
        updateListFetchingFromCD(choosedTab.returnStringDescription(), entityId: "\(choosedTab.returnStringDescription().lowercaseString)Id", entityName: "\(choosedTab.returnStringDescription().lowercaseString)Name")
//        sceneTableView.reloadData()
    }
    
    @IBAction func backButton(sender: UIStoryboardSegue) {
        self.performSegueWithIdentifier("scanUnwind", sender: self)
    }
    
    
    

    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    @IBAction func btnScenes(sender: AnyObject) {
        
            senderButton = sender as? UIButton
            
            popoverVC = storyboard?.instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
            popoverVC.modalPresentationStyle = .Popover
            popoverVC.preferredContentSize = CGSizeMake(300, 200)
            popoverVC.delegate = self
            popoverVC.indexTab = 6
            if let popoverController = popoverVC.popoverPresentationController {
                popoverController.delegate = self
                popoverController.permittedArrowDirections = .Any
                popoverController.sourceView = sender as? UIView
                popoverController.sourceRect = sender.bounds
                popoverController.backgroundColor = UIColor.lightGrayColor()
                presentViewController(popoverVC, animated: true, completion: nil)
                
            }
    }
    
    @available(iOS 8.0, *)
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func saveText(text: String, id: Int) {
        print(Array(text.characters.reverse()))
        senderButton?.setTitle(text, forState: .Normal)
        if text == "Devices" {
            choosedTab = .Devices
            
            let oldController = childViewControllers.last
            
            self.addChildViewController(scanDeviceViewController)
            scanDeviceViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(scanDeviceViewController.view)
            scanDeviceViewController.didMoveToParentViewController(self)
            oldController!.view.hidden = true
            
            scanDeviceViewController.view.hidden = false
        }
        if text == "Scenes" {
            choosedTab = .Scenes
            
            let oldController = childViewControllers.last
            
            self.addChildViewController(scanSceneViewController)
            scanSceneViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(scanSceneViewController.view)
            scanSceneViewController.didMoveToParentViewController(self)
            oldController!.view.hidden = true
            
            scanSceneViewController.view.hidden = false
        }
        if text == "Events" {
            
            let oldController = childViewControllers.last
            oldController!.view.hidden = true
            
            scanEventsViewController.view.hidden = false
            
            self.addChildViewController(scanEventsViewController)
            scanEventsViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(scanEventsViewController.view)
            scanEventsViewController.didMoveToParentViewController(self)
            
            choosedTab = .Events
        }
        if text == "Sequences" {
            choosedTab = .Sequences
            
            let oldController = childViewControllers.last
            
            self.addChildViewController(scanSequencesViewController)
            scanSequencesViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(scanSequencesViewController.view)
            scanSequencesViewController.didMoveToParentViewController(self)
            
            oldController!.view.hidden = true
            
            scanSequencesViewController.view.hidden = false
        }
        if text == "Zones" {
            choosedTab = .Categories
            
            let oldController = childViewControllers.last
            
            self.addChildViewController(importZoneViewController)
            importZoneViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(importZoneViewController.view)
            importZoneViewController.didMoveToParentViewController(self)
            
            oldController!.view.hidden = true
            
            importZoneViewController.view.hidden = false
        }
        if text == "Categories" {
            choosedTab = .Zones
            
            let oldController = childViewControllers.last
            
            self.addChildViewController(importCategoryViewController)
            importCategoryViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(importCategoryViewController.view)
            importCategoryViewController.didMoveToParentViewController(self)
            
            oldController!.view.hidden = true
            
            importCategoryViewController.view.hidden = false
        }
        if text == "Timers" {
            choosedTab = .Zones
            
            let oldController = childViewControllers.last
            
            self.addChildViewController(scanTimersViewController)
            scanTimersViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(scanTimersViewController.view)
            scanTimersViewController.didMoveToParentViewController(self)
            
            oldController!.view.hidden = true
            
            scanTimersViewController.view.hidden = false
        }
        if text == "Flag" {
            choosedTab = .Zones
            
            let oldController = childViewControllers.last
            
            self.addChildViewController(scanFlagsViewController)
            scanFlagsViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
            container.addSubview(scanFlagsViewController.view)
            scanFlagsViewController.didMoveToParentViewController(self)
            
            oldController!.view.hidden = true
            
            scanFlagsViewController.view.hidden = false
        }
    }
    
    

    
    // ======================= *** TABLE VIEW *** =======================
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    

}




