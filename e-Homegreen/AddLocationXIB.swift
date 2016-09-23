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

class AddLocationXIB: PopoverVC {
    
    var isPresenting: Bool = true
    
    var delegate:AddEditLocationDelegate?
    
    @IBOutlet weak var zoneBtn: CustomGradientButton!
    @IBOutlet weak var categoryBtn: CustomGradientButton!
    @IBOutlet weak var ssidBtn: CustomGradientButton!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var locationNameTextField: UITextField!
    @IBOutlet weak var idTextField: EditTextField!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var locationMap: MKMapView!
    
    @IBOutlet weak var timerButton: UIButton!
    @IBOutlet weak var securityButton: UIButton!
    @IBOutlet weak var timerArrowButton: UIButton!
    @IBOutlet weak var securityArrowButton: UIButton!
    
    var annotation = MKPointAnnotation()
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var setFilterSwitch: UISwitch!
    
    let locationManager = CLLocationManager()
    
    var button:UIButton!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var location:Location?
    var user:User?
    
    var radius:Double = 50
    
    init(location:Location?, user:User?){
        super.init(nibName: "AddLocationXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.location = location
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddLocationXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        locationMap.mapType = MKMapType.hybrid
        locationMap.showsUserLocation = true
        
        locationNameTextField.delegate = self
        
        idTextField.inputAccessoryView = CustomToolBar()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(AddLocationXIB.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        locationMap.addGestureRecognizer(lpgr)
        
        if let location = location{
            zoneBtn.isEnabled = true
            categoryBtn.isEnabled = true
            ssidBtn.isEnabled = true
            timerButton.isEnabled = true
            securityButton.isEnabled = true
            timerArrowButton.isEnabled = true
            securityArrowButton.isEnabled = true
            
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
                        timerButton.setTitle(timer.timerName, for: UIControlState())
                    }
                }
                if let security = location.security?.allObjects as? [Security]{
                    if security.count != 0{
                        if let id = security[0].gatewayId{
                            if let gateway = DatabaseGatewayController.shared.getGatewayByid(id){
                                securityButton.setTitle(gateway.gatewayDescription, for: UIControlState())
                            }
                        }
                    }
                }
                if let filter = location.filterOnLocation as? Bool{
                    setFilterSwitch.isOn = filter
                }
                
                
                let center = locationCoordinate.coordinate
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.locationMap.setRegion(region, animated: true)
            }
        }else{
            zoneBtn.isEnabled = false
            categoryBtn.isEnabled = false
            ssidBtn.isEnabled = false
            timerButton.isEnabled = false
            securityButton.isEnabled = false
            timerArrowButton.isEnabled = false
            securityArrowButton.isEnabled = false
            
            radiusLabel.text = "Radius: \(Int(radius))m"
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
        }

    }
    
    override func nameAndId(_ name: String, id: String) {
        if button.tag == 2{
            if let gateway = DatabaseGatewayController.shared.getGatewayByStringObjectID(id){
                DatabaseSecurityController.shared.createSecurityForLocation(location!, gateway: gateway)
                securityButton.setTitle(gateway.gatewayDescription, for: UIControlState())
            }else{
                DatabaseSecurityController.shared.removeSecurityForLocation(location!)
                securityButton.setTitle("", for: UIControlState())
            }
        }
        if button.tag == 1{
            if let timer = DatabaseTimersController.shared.getTimerByStringObjectID(id){
                location!.timerId = timer.id
                timerButton.setTitle(timer.timerName, for: UIControlState())
            }else{
                location!.timerId = nil
                timerButton.setTitle("", for: UIControlState())
            }
        }
    }
    
    func endEditingNow(){
        idTextField.resignFirstResponder()
    }
    
    // tap on map and find coordinate
    func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.began {
            return
        }
        if gestureReconizer.state != UIGestureRecognizerState.ended {
            let touchLocation = gestureReconizer.location(in: locationMap)
            let locationCoordinate = locationMap.convert(touchLocation,toCoordinateFrom: locationMap)
            print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
            annotation.coordinate = locationCoordinate
            locationMap.addAnnotation(annotation)
            addRadiusCircle(CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude))
            return
        }

    }
    
    func createZonesAndCategories(_ location:Location) {
        if let zonesJSON = DataImporter.createZonesFromFileFromNSBundle() {
            for zoneJSON in zonesJSON {
                let zone = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: appDel.managedObjectContext!) as! Zone
                if zoneJSON.id == 254 || zoneJSON.id == 255 {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: false as Bool), location, zoneJSON.id as NSNumber?, 1)
                } else {
                    (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: true as Bool), location, zoneJSON.id as NSNumber?, 1)
                }
                CoreDataController.shahredInstance.saveChanges()
                
            }
        }
        if let categoriesJSON = DataImporter.createCategoriesFromFileFromNSBundle() {
            for categoryJSON in categoriesJSON {
                let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: appDel.managedObjectContext!) as! Category
                if categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id as NSNumber?, categoryJSON.name, categoryJSON.description, NSNumber(value: false as Bool), location, categoryJSON.id as NSNumber?, 3)
                } else {
                    (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id as NSNumber?, categoryJSON.name, categoryJSON.description, NSNumber(value: true as Bool), location, categoryJSON.id as NSNumber?, 3)
                }
                CoreDataController.shahredInstance.saveChanges()
            }
        }
    }
    
    //add circle with radius around tap location
    func addRadiusCircle(_ location: CLLocation){
        self.locationMap.delegate = self
        let circle = MKCircle(center: location.coordinate, radius: radius as CLLocationDistance)
        let overlays = locationMap.overlays
        locationMap.removeOverlays(overlays)
        self.locationMap.add(circle)
    }
    
    func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: AnyObject) {
        
        guard let locationName = locationNameTextField.text , locationName != "" else {
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
            location.latitude = annotation.coordinate.latitude as NSNumber?
            location.longitude = annotation.coordinate.longitude as NSNumber?
            location.orderId = id as NSNumber?
            location.radius = radius as NSNumber?
            location.filterOnLocation = setFilterSwitch.isOn as NSNumber?
            CoreDataController.shahredInstance.saveChanges()
            
            delegate?.editAddLocationFinished()
            self.dismiss(animated: true, completion: nil)
        }else{
            if let user = user{
                if let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: appDel.managedObjectContext!) as? Location{
                    newLocation.name = locationNameTextField.text!
                    newLocation.latitude = annotation.coordinate.latitude as NSNumber?
                    newLocation.longitude = annotation.coordinate.longitude as NSNumber?
                    newLocation.radius = radius as NSNumber?
                    newLocation.user = user
                    newLocation.filterOnLocation = setFilterSwitch.isOn as NSNumber?
                    if let orderId = idTextField.text, let id = Int(orderId){
                        newLocation.orderId = id as NSNumber?
                    }else{
                        newLocation.orderId = DatabaseLocationController.shared.getNextAvailableId(user) as NSNumber?
                    }
                    createZonesAndCategories(newLocation)
                    CoreDataController.shahredInstance.saveChanges()
                    
                    DatabaseLocationController.shared.startMonitoringLocation(newLocation)
                    
                    delegate?.editAddLocationFinished()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }

        
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        appDel.managedObjectContext?.rollback()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func chooseTimerAction(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Timer] = DatabaseTimersController.shared.getUserTimers(location!)
        for item in list {
            popoverList.append(PopOverItem(name: item.timerName, id: item.objectID.uriRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "  ", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)

    }
    
    @IBAction func chooseSecurity(_ sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Gateway] = DatabaseGatewayController.shared.getGatewayByLocationForSecurity(location!)
        for item in list {
            popoverList.append(PopOverItem(name: item.gatewayDescription, id: item.objectID.uriRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "  ", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)

    }
    
    @IBAction func changeRadiusAction(_ sender: UISlider) {
        radius = Double(sender.value)
        radiusLabel.text = "Radius: \(Int(radius))m"
        addRadiusCircle(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
    }
    
    @IBAction func importZone(_ sender: AnyObject) {
        
        if let navVC = UIStoryboard(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImportZone") as? UINavigationController{
            if let importZoneViewController = navVC.topViewController as? ImportZoneViewController{
                importZoneViewController.location = location
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func importCategory(_ sender: AnyObject) {
        if let navVC = UIStoryboard(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImportCategory") as? UINavigationController{
            if let importCategoryViewController = navVC.topViewController as? ImportCategoryViewController{
                importCategoryViewController.location = location
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func importSSID(_ sender: AnyObject) {
        if let navVC = UIStoryboard(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImportSSID") as? UINavigationController{
            if let importSSID = navVC.topViewController as? ImportSSIDViewController{
                importSSID.location = location
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    

}

extension AddLocationXIB : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddLocationXIB : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view{
            if touchView.isDescendant(of: backView){
                self.view.endEditing(true)
                return false
            }
        }
        return true
    }
}

extension AddLocationXIB : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.green
            circle.fillColor = UIColor.green.withAlphaComponent(0.25)
            circle.lineWidth = 1
            return circle
        }
        return MKPolylineRenderer()
    }
}

extension AddLocationXIB : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.locationMap.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
        
    }
}

extension AddLocationXIB : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            containerView.addSubview(presentedControllerView)
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension AddLocationXIB : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}

extension UIViewController {
    func showAddLocation(_ location:Location?, user:User?) -> AddLocationXIB {
        let addLocation = AddLocationXIB(location: location, user:user)
        self.present(addLocation, animated: true, completion: nil)
        return addLocation
    }
}
