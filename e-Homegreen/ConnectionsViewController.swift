//
//  ConnectionsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 7/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

struct LocationDevice {
    var device:AnyObject
    var typeOfLocationDevice:TypeOfLocationDevice
}

enum TypeOfLocationDevice{
    case Gateway, Surveillance
    var description:String{
        switch self{
        case Gateway: return "e-Homegreen"
        case Surveillance: return "Surveillance"
        }
    }
    static let allValues = [Gateway, Surveillance]
}

class CollapsableViewModel {
    let location: Location
    var children: [LocationDevice]
    var isCollapsed: Bool
    
    init(location: Location, children: [LocationDevice] = [], isCollapsed: Bool = false) {
        self.location = location
        self.children = children
        self.isCollapsed = isCollapsed
    }
}

class ConnectionsViewController: UIViewController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UIPopoverPresentationControllerDelegate, PopOverIndexDelegate, GatewayCellDelegate, SurveillanceCellDelegate, AddEditLocationDelegate, AddEditGatewayDelegate, AddEditSurveillanceDelegate  {
    
    @IBOutlet weak var ipHostTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    var backgroundImageView = UIImageView()
    var gateways:[Gateway] = []
    var appDel:AppDelegate!
    var error:NSError? = nil
    
    var user:User!
    
    @IBOutlet weak var gatewayTableView: UITableView!
    @IBOutlet weak var topView: UIView!
    
    var isPresenting:Bool = false
    
    var locationList:[CollapsableViewModel] = []
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    var index = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        transitioningDelegate = self
    }
    
    @IBAction func btnAddNewConnection(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNewGatewayList", name: NotificationKey.Gateway.Refresh, object: nil)
        self.showAddLocation(nil, user: user).delegate = self
        
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
        if sender.identifier == "scanUnwind" {
            print("nesto adadad")
        }
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
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            if id == "scanUnwind" {
                let unwindSegue = SegueUnwind(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
                    
                })
                return unwindSegue
            }
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = self
        self.commonConstruct()
        
        gatewayTableView.estimatedRowHeight = 44.0
        gatewayTableView.rowHeight = UITableViewAutomaticDimension
        
        // Do any additional setup after loading the view.
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
//        fetchGateways()
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshGatewayListWithNewData", name: NotificationKey.RefreshDevice, object: nil)
        
        // This is aded because highlighted was calling itself fast and late because of this property of UIScrollView
        gatewayTableView.delaysContentTouches = false
        // Not a permanent solution as Apple can deside to change view hierarchy inf the future
        for currentView in gatewayTableView.subviews {
            if let view = currentView as? UIScrollView {
                (currentView as! UIScrollView).delaysContentTouches = false
            }
        }
        
        updateLocationList()
    }
    
    
    @IBAction func addNewElementInLocation(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        index = sender.tag
        popoverVC.indexTab = 26
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func deleteLocation(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Delete location?", preferredStyle: .ActionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.appDel.managedObjectContext?.deleteObject(self.locationList[sender.tag].location)
            self.reloadLocations()
        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })

        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)

    }
    
    @IBAction func editLocation(sender: AnyObject) {
        self.showAddLocation(locationList[sender.tag].location, user: nil).delegate = self
    }
    

    
    func saveText(text: String, id: Int) {
        if TypeOfLocationDevice.Gateway.description == text{
            self.showConnectionSettings(nil, location: locationList[index].location).delegate = self
        }
        if TypeOfLocationDevice.Surveillance.description == text{
            showSurveillanceSettings(nil, location: locationList[index].location).delegate = self
        }
    }
    
    //delegati kada dodajemo gateway i surveillance
    
    func add_editGatewayFinished() {
        editLocation()
    }
    
    func editAddLocationFinished() {
        reloadLocations()
    }
    
    func add_editSurveillanceFinished(){
        editLocation()
    }
    
    func reloadLocations(){
        updateLocationList()
        gatewayTableView.reloadData()
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
   // popunjavam location list sa elementima lokacije, izvucem lokaciju i onda iz svake lokacije listu gatewaya i surveillance
    func updateLocationList(){
        locationList = []
        let location = returnLocations()
        
        for item in location{
            var listOfChildrenDevice:[LocationDevice] = []
            if let listOfGateway = item.gateways {
                for gateway in listOfGateway{
                    listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Gateway))
                }
            }
            if let listOfSurveillance = item.surveillances {
                for surv in listOfSurveillance{
                    listOfChildrenDevice.append(LocationDevice(device: surv, typeOfLocationDevice: .Surveillance))
                }
            }
            locationList.append(CollapsableViewModel(location: item, children: listOfChildrenDevice))
        }
    }
    
    func editLocation(){
        let locationEdit = locationList[index].location
        locationList[index].children = []
        var listOfChildrenDevice:[LocationDevice] = []
        if let listOfGateway = locationEdit.gateways {
            for gateway in listOfGateway{
                listOfChildrenDevice.append(LocationDevice(device: gateway, typeOfLocationDevice: .Gateway))
            }
        }
        if let listOfSurveillance = locationEdit.surveillances {
            for surv in listOfSurveillance{
                listOfChildrenDevice.append(LocationDevice(device: surv, typeOfLocationDevice: .Surveillance))
            }
        }
        locationList[index].children = listOfChildrenDevice
        gatewayTableView.reloadData()
    }
    
    func returnLocations () -> [Location] {
        let fetchRequest:NSFetchRequest = NSFetchRequest(entityName: "Location")
        let sortDescriptorTwo = NSSortDescriptor(key: "name", ascending: true)
        let predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [sortDescriptorTwo]
        fetchRequest.predicate = predicate
        do {
            let fetchResults = try appDel.managedObjectContext!.executeFetchRequest(fetchRequest) as? [Location]
            return fetchResults!
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        return []
    }
    
    override func viewDidAppear(animated: Bool) {
        appDel.establishAllConnections()
    }
    override func viewDidDisappear(animated: Bool) {
        appDel.establishAllConnections()
    }
    override func viewWillAppear(animated: Bool) {
        gatewayTableView.reloadData()
        gatewayTableView.userInteractionEnabled = true
    }
    
    func commonConstruct() {
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.frame = CGRectMake(0, 64, Common.screenWidth , Common.screenHeight-64)
        self.view.insertSubview(backgroundImageView, atIndex: 0)
    }
    
    @IBAction func btnSaveConnection(sender: AnyObject) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // delegatske funkcije za tranziciju ekrana
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.center.x += containerView!.bounds.size.width
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
    
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
    

    
    func saveChanges() {
        do {
            try appDel.managedObjectContext!.save()
        } catch let error1 as NSError {
            error = error1
            print("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
    

}

extension ConnectionsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.row == 0{
            if let cell = tableView.dequeueReusableCellWithIdentifier("locationCell") as? LocationCell {
                cell.setItem(locationList[indexPath.section].location, isColapsed: locationList[indexPath.section].isCollapsed)
                cell.addButton.tag = indexPath.section
                cell.editButton.tag = indexPath.section
                cell.deleteButton.tag = indexPath.section
                return cell
            }
        }else{
            let location = locationList[indexPath.section]
            let device = location.children[indexPath.row - 1]
            switch device.typeOfLocationDevice{
            case TypeOfLocationDevice.Gateway:
                if let cell = tableView.dequeueReusableCellWithIdentifier("gatewayCell") as? GatewayCell {
                    if let gateway = device.device as? Gateway{
                        cell.delegate = self
                        cell.setItem(gateway)
                    }
                    return cell
                }
                break
            
            case TypeOfLocationDevice.Surveillance:
                if let cell = tableView.dequeueReusableCellWithIdentifier("survCell") as? SurvCell {
                    if let surv = device.device as? Surveillance{
                        cell.delegate = self
                        cell.setItem(surv)
                    }
                    return cell
                }
                break
            
            }
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locationList[section].isCollapsed{
            return (locationList[section].children).count + 1
        }else{
            return 1
        }
        
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.clearColor()
        return footer
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return locationList.count
    }
    
    //delegatske funkcije za brisanje i gatewaya i surveillance, za skeniranje uredjaja
    
    func deleteSurveillance(surveillance:Surveillance){
        let optionMenu = UIAlertController(title: nil, message: "Delete camera?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.appDel.managedObjectContext?.deleteObject(surveillance)
            dispatch_async(dispatch_get_main_queue(),{
                self.editLocation()
            })
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    func scanURL(surveillance:Surveillance){
        showCameraUrls(self.view.center, surveillance: surveillance)
    }
    
    func scanDevice(gateway: Gateway) {
        performSegueWithIdentifier("scan", sender: gateway)
        gatewayTableView.userInteractionEnabled = false
    }
    
    func deleteGateway(gateway: Gateway) {
        let optionMenu = UIAlertController(title: nil, message: "Delete e-Homegreen?", preferredStyle: .ActionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            self.appDel.managedObjectContext?.deleteObject(gateway)
            dispatch_async(dispatch_get_main_queue(),{
                self.editLocation()
            })
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }
    
    func changeSwitchValue(gateway:Gateway, gatewaySwitch:UISwitch){
        if gatewaySwitch.on == true {
            gateway.turnedOn = true
        }else {
            gateway.turnedOn = false
        }
        saveChanges()
        gatewayTableView.reloadData()
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshDevice, object: self, userInfo: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "scan" {
                if let vc = segue.destinationViewController as? ScanViewController {
                    if let gateway = sender as? Gateway{
                        vc.gateway = gateway
                    }
                }
            }
    }
    
}

extension ConnectionsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 0{
            locationList[indexPath.section].isCollapsed = !locationList[indexPath.section].isCollapsed
            tableView.reloadData()
//            tableView.reloadSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.None)
        }else{
            let device = locationList[indexPath.section].children[indexPath.row - 1]
            if let surv = device.device as? Surveillance{
                dispatch_async(dispatch_get_main_queue(),{
                    self.showSurveillanceSettings(surv, location: nil).delegate = self
                })
            }
            if let gateway = device.device as? Gateway{
                dispatch_async(dispatch_get_main_queue(),{
                    self.showConnectionSettings(gateway, location: nil).delegate = self
                })
            }
        }
        index = indexPath.section
    }

}

protocol GatewayCellDelegate{
    func deleteGateway(gateway:Gateway)
    func scanDevice(gateway:Gateway)
    func changeSwitchValue(gateway:Gateway, gatewaySwitch:UISwitch)
}

// Gateway cell
class GatewayCell: UITableViewCell {
    
    var gateway:Gateway?
    var delegate:GatewayCellDelegate?
    @IBOutlet weak var lblGatewayDeviceNumber: UILabel!
    @IBOutlet weak var lblGatewayDescription: MarqueeLabel!
    var gradientLayer: CAGradientLayer?
    
    @IBOutlet weak var buttonGatewayScan: UIButton!
    @IBOutlet weak var switchGatewayState: UISwitch!
    
    @IBOutlet weak var add1: UILabel!
    @IBOutlet weak var add2: UILabel!
    @IBOutlet weak var add3: UILabel!
    
    @IBAction func scanDevicesAction(sender: AnyObject) {
        if let gate = gateway{
            delegate?.scanDevice(gate)
        }
    }
    
    @IBAction func deleteGateway(sender: AnyObject) {
        if let gate = gateway{
            delegate?.deleteGateway(gate)
        }
    }
    
    @IBAction func changeSwitchValue(sender: AnyObject) {
        if let gatewaySwitch = sender as? UISwitch, let gate = gateway{
            delegate?.changeSwitchValue(gate, gatewaySwitch: gatewaySwitch)
        }
    }
    
    override func awakeFromNib() {
        self.add1.layer.cornerRadius = 2
        self.add2.layer.cornerRadius = 2
        self.add3.layer.cornerRadius = 2
        self.add1.clipsToBounds = true
        self.add2.clipsToBounds = true
        self.add3.clipsToBounds = true
        
        self.add1.layer.borderWidth = 1
        self.add2.layer.borderWidth = 1
        self.add3.layer.borderWidth = 1
        
        self.add1.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.add2.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.add3.layer.borderColor = UIColor.darkGrayColor().CGColor
        
    }
    
    func setItem(gateway:Gateway){
        
        self.gateway = gateway
        
        self.lblGatewayDescription.text = gateway.gatewayDescription
        self.lblGatewayDeviceNumber.text = "\(gateway.devices.count) device(s)"
        self.add1.text = returnThreeCharactersForByte(Int(gateway.addressOne))
        self.add2.text = returnThreeCharactersForByte(Int(gateway.addressTwo))
        self.add3.text = returnThreeCharactersForByte(Int(gateway.addressThree))
        self.switchGatewayState.on = gateway.turnedOn.boolValue
        if gateway.turnedOn.boolValue {
            self.buttonGatewayScan.enabled = true
        } else {
            self.buttonGatewayScan.enabled = false
        }
    }
    
    override func drawRect(rect: CGRect) {
        var rectNew = CGRectMake(3, 3, rect.size.width - 6, rect.size.height - 6)
        let path = UIBezierPath(roundedRect: rectNew,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 1
        
        UIColor.darkGrayColor().setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor().e_homegreenColor().CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor, UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 0.35, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:self.bounds.width , y:0)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
    
}
//location cell
class LocationCell: UITableViewCell {
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    func setItem(location:Location, isColapsed:Bool){
        locationNameLabel.text = location.name
        if isColapsed{
            arrowImage.image = UIImage(named: "strelica_gore")
        }else{
            arrowImage.image = UIImage(named: "strelica_dole")
        }
    }
    
}

