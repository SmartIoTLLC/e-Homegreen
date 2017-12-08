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
    
    var annotation = MKPointAnnotation()

    let locationManager = CLLocationManager()
    
    var button:UIButton!
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var location:Location?
    var user:User?
    
    var radius:Double = 50
    
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
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    
    @IBOutlet weak var setFilterSwitch: UISwitch!

    @IBAction func saveAction(_ sender: AnyObject) {
        save()
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        cancel()
    }
    @IBAction func chooseTimerAction(_ sender: UIButton) {
        chooseTimer(sender: sender)
    }
    @IBAction func chooseSecurity(_ sender: UIButton) {
        chooseSecurity(via: sender)
    }
    @IBAction func changeRadiusAction(_ sender: UISlider) {
        changedRadius(sender: sender)
    }
    @IBAction func importZone(_ sender: AnyObject) {
        importZone()
    }
    @IBAction func importCategory(_ sender: AnyObject) {
        importCategory()
    }
    @IBAction func importSSID(_ sender: AnyObject) {
        importSSID()
    }

    init(location:Location?, user:User?){
        super.init(nibName: "AddLocationXIB", bundle: nil)
        transitioningDelegate  = self
        modalPresentationStyle = UIModalPresentationStyle.custom
        self.location          = location
        self.user              = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func nameAndId(_ name: String, id: String) {
        if button.tag == 2 {
            if let gateway = DatabaseGatewayController.shared.getGatewayByStringObjectID(id) {
                DatabaseSecurityController.shared.createSecurityForLocation(location!, gateway: gateway)
                securityButton.setTitle(gateway.gatewayDescription, for: UIControlState())
            } else {
                DatabaseSecurityController.shared.removeSecurityForLocation(location!)
                securityButton.setTitle("", for: UIControlState())
            }
        }
        if button.tag == 1 {
            if let timer = DatabaseTimersController.shared.getTimerByStringObjectID(id) {
                location!.timerId = timer.id
                timerButton.setTitle(timer.timerName, for: UIControlState())
            } else {
                location!.timerId = nil
                timerButton.setTitle("", for: UIControlState())
            }
        }
    }
}

// MARK: - Setup views
extension AddLocationXIB {
    func setupViews() {
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        locationMap.mapType = MKMapType.hybrid
        locationMap.showsUserLocation = true
        
        locationNameTextField.delegate = self
        
        idTextField.inputAccessoryView = CustomToolBar()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action:#selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        locationMap.addGestureRecognizer(lpgr)
        
        if let location = location {
            zoneBtn.isEnabled             = true
            categoryBtn.isEnabled         = true
            ssidBtn.isEnabled             = true
            timerButton.isEnabled         = true
            securityButton.isEnabled      = true
            timerArrowButton.isEnabled    = true
            securityArrowButton.isEnabled = true
            
            locationNameTextField.text = location.name
            if let longitude = location.longitude, let latitude = location.latitude,let radius = location.radius {
                
                let locationCoordinate = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
                
                annotation.coordinate = locationCoordinate.coordinate
                locationMap.addAnnotation(annotation)
                self.radius = Double(radius)
                radiusLabel.text = "Radius: \(Int(radius))m"
                radiusSlider.value = Float(radius)
                addRadiusCircle(locationCoordinate)
                if let orderId = location.orderId { idTextField.text = "\(orderId)" }
                if let id = location.timerId {
                    if let timer = DatabaseTimersController.shared.getTimerByid(id) { timerButton.setTitle(timer.timerName, for: UIControlState()) }
                }
                if let security = location.security?.allObjects as? [Security] {
                    if security.count != 0 {
                        if let id = security[0].gatewayId {
                            if let gateway = DatabaseGatewayController.shared.getGatewayByid(id) { securityButton.setTitle(gateway.gatewayDescription, for: UIControlState()) }
                        }
                    }
                }
                if let filter = location.filterOnLocation as? Bool { setFilterSwitch.isOn = filter }
                
                let center = locationCoordinate.coordinate
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.locationMap.setRegion(region, animated: true)
            }
        }else{
            zoneBtn.isEnabled             = false
            categoryBtn.isEnabled         = false
            ssidBtn.isEnabled             = false
            timerButton.isEnabled         = false
            securityButton.isEnabled      = false
            timerArrowButton.isEnabled    = false
            securityArrowButton.isEnabled = false
            
            radiusLabel.text = "Radius: \(Int(radius))m"
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate        = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
        }
        
    }
    
    func endEditingNow(){
        idTextField.resignFirstResponder()
    }
}

// MARK: - Logic
extension AddLocationXIB {
    fileprivate func importZone() {
        if let navVC = UIStoryboard(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImportZone") as? UINavigationController{
            if let importZoneViewController = navVC.topViewController as? ImportZoneViewController {
                importZoneViewController.location = location
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func importCategory() {
        if let navVC = UIStoryboard(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImportCategory") as? UINavigationController{
            if let importCategoryViewController = navVC.topViewController as? ImportCategoryViewController {
                importCategoryViewController.location = location
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func importSSID() {
        if let navVC = UIStoryboard(name: "Settings", bundle: Bundle.main).instantiateViewController(withIdentifier: "ImportSSID") as? UINavigationController{
            if let importSSID = navVC.topViewController as? ImportSSIDViewController {
                importSSID.location = location
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func save() {
        guard let locationName = locationNameTextField.text , locationName != "" else { self.view.makeToast(message: "Write location name"); return }
        
        guard annotation.coordinate.longitude != 0 && annotation.coordinate.latitude != 0 else { self.view.makeToast(message: "Choose location from map"); return }
        
        if let location = location {
            guard let orderId = idTextField.text, let id = Int(orderId) else { self.view.makeToast(message: "Id have to be a number"); return }
            location.name             = locationNameTextField.text!
            location.latitude         = annotation.coordinate.latitude as NSNumber?
            location.longitude        = annotation.coordinate.longitude as NSNumber?
            location.orderId          = id as NSNumber?
            location.radius           = radius as NSNumber?
            location.filterOnLocation = setFilterSwitch.isOn as NSNumber?
            CoreDataController.sharedInstance.saveChanges()
            
            delegate?.editAddLocationFinished()
            self.dismiss(animated: true, completion: nil)
        } else {
            if let user = user {
                if let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Location", into: appDel.managedObjectContext!) as? Location{
                    newLocation.name             = locationNameTextField.text!
                    newLocation.latitude         = annotation.coordinate.latitude as NSNumber?
                    newLocation.longitude        = annotation.coordinate.longitude as NSNumber?
                    newLocation.radius           = radius as NSNumber?
                    newLocation.user             = user
                    newLocation.filterOnLocation = setFilterSwitch.isOn as NSNumber?
                    if let orderId = idTextField.text, let id = Int(orderId) { newLocation.orderId = id as NSNumber?
                    } else { newLocation.orderId = DatabaseLocationController.shared.getNextAvailableId(user) as NSNumber? }
                    createZonesAndCategories(newLocation)
                    CoreDataController.sharedInstance.saveChanges()
                    
                    DatabaseLocationController.shared.startMonitoringLocation(newLocation)
                    
                    delegate?.editAddLocationFinished()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    fileprivate func cancel() {
        if let moc = appDel.managedObjectContext {
            moc.rollback()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    fileprivate func chooseSecurity(via sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Gateway] = DatabaseGatewayController.shared.getGatewayByLocationForSecurity(location!)
        for item in list { popoverList.append(PopOverItem(name: item.gatewayDescription, id: item.objectID.uriRepresentation().absoluteString)) }
        popoverList.insert(PopOverItem(name: "  ", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func chooseTimer(sender: UIButton) {
        button = sender
        var popoverList:[PopOverItem] = []
        let list:[Timer] = DatabaseTimersController.shared.getUserTimers(location!)
        for item in list {
            popoverList.append(PopOverItem(name: item.timerName, id: item.objectID.uriRepresentation().absoluteString))
        }
        popoverList.insert(PopOverItem(name: "  ", id: ""), at: 0)
        openPopover(sender, popOverList:popoverList)
    }
    
    fileprivate func changedRadius(sender: UISlider) {
        radius = Double(sender.value)
        radiusLabel.text = "Radius: \(Int(radius))m"
        addRadiusCircle(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
    }
    
    // tap on map and find coordinate
    func handleLongPress(_ gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizerState.began { return }
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
                if let moc = appDel.managedObjectContext {
                    if let zone = NSEntityDescription.insertNewObject(forEntityName: "Zone", into: moc) as? Zone {
                        if zoneJSON.id == 254 || zoneJSON.id == 255 {
                            (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: false as Bool), location, zoneJSON.id as NSNumber?, 1)
                        } else {
                            (zone.id, zone.name, zone.zoneDescription, zone.level, zone.isVisible, zone.location, zone.orderId, zone.allowOption) = (zoneJSON.id as NSNumber?, zoneJSON.name, zoneJSON.description, zoneJSON.level as NSNumber?, NSNumber(value: true as Bool), location, zoneJSON.id as NSNumber?, 1)
                        }
                        CoreDataController.sharedInstance.saveChanges()
                    }
                }
            }
        }
        if let categoriesJSON = DataImporter.createCategoriesFromFileFromNSBundle() {
            for categoryJSON in categoriesJSON {
                if let moc = appDel.managedObjectContext {
                    if let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: moc) as? Category {
                        if categoryJSON.id == 2 || categoryJSON.id == 3 || categoryJSON.id == 5 || categoryJSON.id == 6 || categoryJSON.id == 7 || categoryJSON.id == 8 || categoryJSON.id == 9 || categoryJSON.id == 10 || categoryJSON.id == 255 {
                            (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id as NSNumber?, categoryJSON.name, categoryJSON.description, NSNumber(value: false as Bool), location, categoryJSON.id as NSNumber?, 3)
                        } else {
                            (category.id, category.name, category.categoryDescription, category.isVisible, category.location, category.orderId, category.allowOption) = (categoryJSON.id as NSNumber?, categoryJSON.name, categoryJSON.description, NSNumber(value: true as Bool), location, categoryJSON.id as NSNumber?, 3)
                        }
                        CoreDataController.sharedInstance.saveChanges()
                    }
                }
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
    
}

// MARK: - TextField Delegate
extension AddLocationXIB : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Gesture recognizer delegate
extension AddLocationXIB : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
        return true
    }
}

// MARK: - MapView delegate
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

// MARK: - Location service
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
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}

extension AddLocationXIB : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}

extension UIViewController {
    func showAddLocation(_ location:Location?, user:User?) -> AddLocationXIB {
        let addLocation = AddLocationXIB(location: location, user:user)
        self.present(addLocation, animated: true, completion: nil)
        return addLocation
    }
}
