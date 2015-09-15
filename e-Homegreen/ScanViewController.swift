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
    
    var scanSceneViewController: UIViewController!
    var scanDeviceViewController: UIViewController!
    
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var choosedTab:ChoosedTab = .Devices
    var senderButton:UIButton?
    
    enum ChoosedTab {
        case Devices, Scenes, Events, Sequences
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
        
        var storyboard = UIStoryboard(name: "Main", bundle: nil)

        scanSceneViewController = storyboard.instantiateViewControllerWithIdentifier("ScanScenes") as! ScanScenesViewController
        scanDeviceViewController = storyboard.instantiateViewControllerWithIdentifier("ScanDevices") as! ScanDevicesViewController
        
        scanSceneViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
        container.addSubview(scanSceneViewController.view)
        self.addChildViewController(scanSceneViewController)

        var gradient:CAGradientLayer = CAGradientLayer()
        if self.view.frame.size.height > self.view.frame.size.width {
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        } else {
            gradient.frame = CGRectMake(0, 0, self.view.frame.size.width, 64)
        }
        gradient.colors = [UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor , UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)


//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshDeviceList", name: "refreshDeviceListNotification", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "nameReceivedFromPLC:", name: "PLCdidFindNameForDevice", object: nil)
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
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    func updateSceneList () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: "Scene")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "sceneId", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "sceneName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Scene]
        if let results = fetResults {
            choosedTabArray = results
        } else {
            println("Nije htela...")
        }
    }
    func updateListFetchingFromCD (entity:String, entityId:String, entityName:String) {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        var fetchRequest = NSFetchRequest(entityName: entity)
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: entityId, ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: entityName, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway == %@", gateway!.objectID)
        fetchRequest.predicate = predicate
        switch entity {
        case "Scene":
            if let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Scene] {
                choosedTabArray = fetResults
            }
        case "Event":
            if let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Event] {
                choosedTabArray = fetResults
            }
        case "Sequence":
            if let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Sequence] {
                choosedTabArray = fetResults
            }
        default:
            println()
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
                popoverController.sourceView = sender as! UIView
                popoverController.sourceRect = sender.bounds
                popoverController.backgroundColor = UIColor.lightGrayColor()
                presentViewController(popoverVC, animated: true, completion: nil)
                
            }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func saveText(strText: String) {
        println(reverse(strText))
        senderButton?.setTitle(strText, forState: .Normal)
        if strText == "Devices" {
            choosedTab = .Devices
            
            
//            var newController = storyboard!.instantiateViewControllerWithIdentifier("ScanDevices") as! ScanDevicesViewController
//            let oldController = childViewControllers.last as! UIViewController
//            
//            oldController.willMoveToParentViewController(nil)
//            addChildViewController(newController)
//            newController.view.frame = oldController.view.frame
//            
//            oldController.removeFromParentViewController()
//            newController.didMoveToParentViewController(self)
            
            let oldController = childViewControllers.last as! UIViewController
            oldController.view.hidden = true
            
            scanDeviceViewController.view.hidden = false
            
            self.addChildViewController(scanDeviceViewController)
            container.addSubview(scanDeviceViewController.view)
            scanDeviceViewController.didMoveToParentViewController(self)
            
//            scanDeviceViewController.view.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height)
//            container.addSubview(scanDeviceViewController.view)
//            sceneTableView.reloadData()
//            sceneView.hidden = true
//            deviceView.hidden = false
        }
        if strText == "Scenes" {
            choosedTab = .Scenes
            
            let oldController = childViewControllers.last as! UIViewController
            oldController.view.hidden = true
            
            scanSceneViewController.view.hidden = false
            
            self.addChildViewController(scanSceneViewController)
            container.addSubview(scanSceneViewController.view)
            scanSceneViewController.didMoveToParentViewController(self)
            
//            updateListFetchingFromCD("Scene", entityId: "sceneId", entityName: "sceneName")
//            sceneTableView.reloadData()
//            sceneView.hidden = false
//            deviceView.hidden = true
        }
        if strText == "Events" {
            choosedTab = .Events
            updateListFetchingFromCD("Event", entityId: "eventId", entityName: "eventName")
//            sceneTableView.reloadData()
//            sceneView.hidden = false
//            deviceView.hidden = true
        }
        if strText == "Sequences" {
            choosedTab = .Sequences
            updateListFetchingFromCD("Sequence", entityId: "sequenceId", entityName: "sequenceName")
//            sceneTableView.reloadData()
//            sceneView.hidden = false
//            deviceView.hidden = true
        }
    }
    
    

    
    // ======================= *** TABLE VIEW *** =======================
    
    func returnThreeCharactersForByte (number:Int) -> String {
        return String(format: "%03d",number)
    }
    
    var selected:AnyObject?
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if tableView == sceneTableView {
//            if choosedTab == .Scenes {
//                selected = choosedTabArray[indexPath.row]
//                IDedit.text = "\(choosedTabArray[indexPath.row].sceneId)"
//                nameEdit.text = "\(choosedTabArray[indexPath.row].sceneName)"
//                devAddressThree.text = "\(returnThreeCharactersForByte(Int(choosedTabArray[indexPath.row].address)))"
//                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageOne) {
//                    imageSceneOne.image = sceneImage
//                }
//                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageTwo) {
//                    imageSceneTwo.image = sceneImage
//                }
//            }
//            if choosedTab == .Events {
//                selected = choosedTabArray[indexPath.row]
//                IDedit.text = "\(choosedTabArray[indexPath.row].eventId)"
//                nameEdit.text = "\(choosedTabArray[indexPath.row].eventName)"
//                devAddressThree.text = "\(returnThreeCharactersForByte(Int(choosedTabArray[indexPath.row].address)))"
//                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageOne) {
//                    imageSceneOne.image = sceneImage
//                }
//                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageTwo) {
//                    imageSceneTwo.image = sceneImage
//                }
//            }
//            if choosedTab == .Sequences {
//                selected = choosedTabArray[indexPath.row]
//                IDedit.text = "\(choosedTabArray[indexPath.row].sequenceId)"
//                nameEdit.text = "\(choosedTabArray[indexPath.row].sequenceName)"
//                devAddressThree.text = "\(returnThreeCharactersForByte(Int(choosedTabArray[indexPath.row].address)))"
//                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageOne) {
//                    imageSceneOne.image = sceneImage
//                }
//                if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageTwo) {
//                    imageSceneTwo.image = sceneImage
//                }
//            }
//        }
//    }
//    
}

class ScanCell:UITableViewCell{
    
    @IBOutlet weak var lblRow: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var isEnabledSwitch: UISwitch!
    @IBOutlet weak var isVisibleSwitch: UISwitch!
}

class SceneCell:UITableViewCell{
    
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var imageOne: UIImageView!
    @IBOutlet weak var imageTwo: UIImageView!

    
}
