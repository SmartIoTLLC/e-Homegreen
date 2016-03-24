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
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var locationNameTextField: UITextField!
    
    @IBOutlet weak var backView: CustomGradientBackground!
    
    @IBOutlet weak var locationMap: MKMapView!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var annotation = MKPointAnnotation()
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusSlider: UISlider!
    
    let locationManager = CLLocationManager()
    
    var appDel:AppDelegate!
    var error:NSError? = nil
    var location:Location?
    var user:User?
    
    var radius:Double = 50.0
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
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        locationMap.mapType = MKMapType.Hybrid
        locationMap.showsUserLocation = true
        
        
        
        
        
        locationNameTextField.layer.borderWidth = 1
        locationNameTextField.layer.cornerRadius = 2
        locationNameTextField.layer.borderColor = UIColor.lightGrayColor().CGColor
        locationNameTextField.attributedPlaceholder = NSAttributedString(string:"Name",
            attributes:[NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        btnCancel.layer.cornerRadius = 2
        btnSave.layer.cornerRadius = 2
        
        locationNameTextField.delegate = self

        
        let lpgr = UILongPressGestureRecognizer(target: self, action:"handleLongPress:")
        lpgr.minimumPressDuration = 0.5
        locationMap.addGestureRecognizer(lpgr)
        
        if let location = location{
            locationNameTextField.text = location.name
            if let longitude = location.longitude, let latitude = location.latitude,let radius = location.radius{
                
                let location = CLLocation(latitude: Double(latitude), longitude: Double(longitude))
                
                annotation.coordinate = location.coordinate
                locationMap.addAnnotation(annotation)
                self.radius = Double(radius)
                radiusLabel.text = "Radius: \(Int(radius))"
                radiusSlider.value = Float(radius)
                addRadiusCircle(location)
                
                let center = location.coordinate
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                self.locationMap.setRegion(region, animated: true)
            }
        }else{
            radiusLabel.text = "Radius: \(Int(radius))"
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
            }
        }

        // Do any additional setup after loading the view.
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if locationNameTextField.text != "" && annotation.coordinate.longitude != 0 && annotation.coordinate.latitude != 0 {
            if location == nil{
                if let user = user{
                    if let newLocation = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: appDel.managedObjectContext!) as? Location{
                        newLocation.name = locationNameTextField.text!
                        newLocation.latitude = annotation.coordinate.latitude
                        newLocation.longitude = annotation.coordinate.longitude
                        newLocation.radius = radius
                        newLocation.user = user
                        saveChanges()
                        delegate?.editAddLocationFinished()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                
            }else{
                location?.name = locationNameTextField.text!
                location?.latitude = annotation.coordinate.latitude
                location?.longitude = annotation.coordinate.longitude
                location?.radius = radius
                saveChanges()
                delegate?.editAddLocationFinished()
                self.dismissViewControllerAnimated(true, completion: nil)
                
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
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func chooseTimerAction(sender: AnyObject) {
        popoverVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("codePopover") as! PopOverViewController
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    @IBAction func changeRadiusAction(sender: UISlider) {
        radius = Double(sender.value)
        radiusLabel.text = "Radius: \(Int(radius))"
        addRadiusCircle(CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude))
    }

}

extension AddLocationXIB : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
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
            //            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
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
