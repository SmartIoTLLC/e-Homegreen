//
//  AddLocationXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/10/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

protocol AddEditLocationDelegate{
    func editAddLocationFinished()
}

class AddLocationXIB: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, PopOverIndexDelegate, UIPopoverPresentationControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var isPresenting: Bool = true
    
    var delegate:AddEditLocationDelegate?
    
    var popoverVC:PopOverViewController = PopOverViewController()
    
    @IBOutlet weak var backViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var idTextField: EditTextField!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var locationMap: MKMapView!
    
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var securityButton: UIButton!
    
    var annotation = MKPointAnnotation()
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    
    let locationManager = CLLocationManager()
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var location:Location?
    var user:User?
    
    var radius:Double = 0
    init(location:Location?, user:User?){
        super.init(nibName: "AddLocationXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
        self.location = location
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        locationMap.mapType = MKMapType.Hybrid
        locationMap.showsUserLocation = true
        
        locationNameTextField.delegate = self
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(InsertGatewayAddressXIB.endEditingNow) )
        let toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        idTextField.inputAccessoryView = keyboardDoneButtonView

        
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(AddLocationXIB.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        locationMap.addGestureRecognizer(lpgr)
        
        if let location = location{
            topConstraint.constant = 150
            backViewHeight.constant = 553
            locationNameTextField.text = location.name
            if let longitude = location.longitude, let latitude = location.latitude,let radius = location.radius{
                
                let locationCoordinate = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
                
                annotation.coordinate = locationCoordinate.coordinate
                locationMap.addAnnotation(annotation)
                self.radius = Double(radius)
                radiusLabel.text = "Radius: \(Int(radius))m"
                radiusSlider.value = Float(radius)
                addRadiusCircle(locationCoordinate)
                if let orderId = location.orderId {
                    idTextField.text = "\(orderId)"
                }
                if let id = location.timerId{
                    if let timer = DatabaseTimersController.shared.getTimerByid(id){
                        timerButton.setTitle(timer.timerName, forState: .Normal)
                    }
                }
                if let security = location.security?.allObjects as? [Security]{
                    if security.count != 0{
                        if let id = security[0].gatewayId{
                            if let gateway = DatabaseGatewayController.shared.getGatewayByid(id){
                                securityButton.setTitle(gateway.gatewayDescription, forState: .Normal)
                            }
                        }
                    }
                }
                
                
                let center = locationCoordinate.coordinate
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.locationMap.setRegion(region, animated: true)
            }
        }else{
            topConstraint.constant = 8
            backViewHeight.constant = 411
            radiusLabel.text = "Radius: \(Int(radius))m"
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
        }

    }
    
    func endEditingNow(){
        idTextField.resignFirstResponder()
    }
    
    // tap on map and find coordinate
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.Began {
            return
        }
        if gestureReconizer.state != UIGestureRecognizerState.Ended {
            let touchLocation = gestureReconizer.locationInView(locationMap)
            let locationCoordinate = locationMap.convertPoint(touchLocation,toCoordinateFromView: locationMap)
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            annotation.coordinate = locationCoordinate
            locationMap.addAnnotation(annotation)
            addRadiusCircle(CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude))
            return
        }

    }
    func createZonesAndCategories(location:Location) {
        if let zonesJSON = DataImporter.createZonesFromFileFromNSBundle() {
            for zoneJSON in zonesJSON {
                let zone = NSEntityDescription.insertNewObjectForEntityForName("Zone", inManagedObjectContext: appDel.managedObjectContext!) as! Zone
                if zoneJSON.id == 254 || zoneJSON.id == 255 {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: false), location, zoneJSON.id)
                } else {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId) = (zoneJSON.id, zoneJSON.name, zoneJSON.description, zoneJSON.level, NSNumber(bool: true), location, zoneJSON.id)
                }
                saveChanges()
                
            }
        }
        if let categoriesJSON = DataImporter.createCategoriesFromFileFromNSBundle() {
            for categoryJSON in categoriesJSON {
                let category = NSEntityDescription.insertNewObjectForEntityForName("Category", inManagedObjectContext: appDel.managedObjectContext!) as! Category
                if categoryJSON.id == 1 || categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: false), location, categoryJSON.id)
                } else {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId) = (categoryJSON.id, categoryJSON.name, categoryJSON.description, NSNumber(bool: true), location, categoryJSON.id)
                }
                saveChanges()
            }
        }
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.locationMap.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        
    }
    
    //add circle with radius around tap location
    func addRadiusCircle(location: CLLocation){
        self.locationMap.delegate = self
        let circle = MKCircle(centerCoordinate: location.coordinate, radius: radius as CLLocationDistance)
        let overlays = locationMap.overlays
        locationMap.removeOverlays(overlays)
        self.locationMap.addOverlay(circle)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.greenColor()
            circle.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.25)
            circle.lineWidth = 1
            return circle
        }
        return MKPolylineRenderer()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissViewController () {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        
        guard let locationName = locationNameTextField.text where locationName != "" else {
            self.view.makeToast(message: "Write location name")
            return
        }
        
        guard annotation.coordinate.longitude != 0 && annotation.coordinate.latitude != 0 else{
            self.view.makeToast(message: "Choose location from map")
            return
        }
        
        if let location = location{
            guard let orderId = idTextField.text, let id = Int(orderId) else{
                self.view.makeToast(message: "Id have to be a number")
                return
            }
            location.name = locationNameTextField.text!
            location.latitude = annotation.coordinate.latitude
            location.longitude = annotation.coordinate.longitude
            location.orderId = id
            location.radius = radius
            saveChanges()
            
            delegate?.editAddLocationFinished()
            self.dismissViewControllerAnimated(true, completion: nil)
        }else{
            if let user = user{
                if let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: appDel.managedObjectContext!) as? Location{
                    newLocation.name = locationNameTextField.text!
                    newLocation.latitude = annotation.coordinate.latitude
                    newLocation.longitude = annotation.coordinate.longitude
                    newLocation.radius = radius
                    newLocation.user = user
                    if let orderId = idTextField.text, let id = Int(orderId){
                        newLocation.orderId = id
                    }else{
                        newLocation.orderId = DatabaseLocationController.shared.getNextAvailableId(user)
                    }
                    createZonesAndCategories(newLocation)
                    saveChanges()
                    
                    DatabaseLocationController.shared.startMonitoringLocation(newLocation)
                    
                    delegate?.editAddLocationFinished()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
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
    
    @IBAction func cancelAction(sender: UIButton) {
        appDel.managedObjectContext?.rollback()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func chooseTimerAction(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
        popoverVC.modalPresentationStyle = .Popover
        popoverVC.preferredContentSize = CGSizeMake(300, 200)
        popoverVC.delegate = self
        if sender.tag == 1{
            popoverVC.indexTab = 27
            popoverVC.popOver = PopOver.Timers
            popoverVC.timerList = DatabaseTimersController.shared.getUserTimers(location!)
        }else{
            popoverVC.indexTab = 28
            popoverVC.popOver = PopOver.Security
            popoverVC.gateways = DatabaseGatewayController.shared.getGatewayByLocationForSecurity(location!)
        }
        if let popoverController = popoverVC.popoverPresentationController {
            popoverController.delegate = self
            popoverController.permittedArrowDirections = .Any
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = sender.bounds
            popoverController.backgroundColor = UIColor.lightGrayColor()
            presentViewController(popoverVC, animated: true, completion: nil)
        }
    }
    
    
    
    func returnObjectIDandTypePopover(objectId: NSManagedObjectID?, popOver:Int) {
        if popOver == PopOver.Security.rawValue{
            if let location = location, let objectid = objectId{
                if let gateway = DatabaseGatewayController.shared.getGatewayByObjectID(objectid){
                    DatabaseSecurityController.shared.createSecurityForLocation(location, gateway: gateway)
                    securityButton.setTitle(gateway.gatewayDescription, forState: .Normal)
                    
                }
            }
        }
        if popOver == PopOver.Timers.rawValue{
            if let location = location, let objectid = objectId{
                if let timer = DatabaseTimersController.shared.getTimerByObjectID(objectid){
                    location.timerId = timer.id
                    timerButton.setTitle(timer.timerName, forState: .Normal)
                }
            }
        }
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func changeRadiusAction(sender: UISlider) {
        radius = Double(sender.value)
        radiusLabel.text = "Radius: \(Int(radius))m"
        addRadiusCircle(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
    }
    
    @IBAction func importZone(sender: AnyObject) {
        
        if let navVC = UIStoryboard(name: "Settings", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ImportZone") as? UINavigationController{
            if let importZoneViewController = navVC.topViewController as? ImportZoneViewController{
                importZoneViewController.location = location
                self.presentViewController(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func importCategory(sender: AnyObject) {
        if let navVC = UIStoryboard(name: "Settings", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ImportCategory") as? UINavigationController{
            if let importCategoryViewController = navVC.topViewController as? ImportCategoryViewController{
                importCategoryViewController.location = location
                self.presentViewController(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func importSSID(sender: AnyObject) {
        if let navVC = UIStoryboard(name: "Settings", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ImportSSID") as? UINavigationController{
            if let importSSID = navVC.topViewController as? ImportSSIDViewController{
                importSSID.location = location
                self.presentViewController(navVC, animated: true, completion: nil)
            }
        }
    }
    

}

extension AddLocationXIB : UIViewControllerAnimatedTransitioning {
    
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
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}



extension AddLocationXIB : UIViewControllerTransitioningDelegate {
    
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
    
}

extension UIViewController {
    func showAddLocation(location:Location?, user:User?) -> AddLocationXIB {
        let addLocation = AddLocationXIB(location: location, user:user)
        self.presentViewController(addLocation, animated: true, completion: nil)
        return addLocation
    }
}
