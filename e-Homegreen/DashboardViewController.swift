//
//  DashboardViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreLocation

class DashboardViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
    var locationManager = CLLocationManager()
    var weatherDictionary:[String: String] = ["01d":"weather-clear",
                                              "02d":"weather-few",
                                              "03d":"weather-few",
                                              "04d":"weather-broken",
                                              "09d":"weather-shower",
                                              "10d":"weather-rain",
                                              "11d":"weather-tstorm",
                                              "13d":"weather-snow",
                                              "50d":"weather-mist",
                                              "01n":"weather-moon",
                                              "02n":"weather-few-night",
                                              "03n":"weather-few-night",
                                              "04n":"weather-broken",
                                              "09n":"weather-shower",
                                              "10n":"weather-rain-night",
                                              "11n":"weather-tstorm",
                                              "13n":"weather-snow",
                                              "50n":"weather-mist"]
    var calendar = FSCalendar()
    var clock : SPClockView!
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var lblMinMaxTemp: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblWeather: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        
        let date = Date()
        let calendarUnit = Calendar.current
        let components = (calendarUnit as NSCalendar).components([.hour, .minute], from: date)
        let hour = components.hour
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        navigationItem.titleView = titleView
        titleView.setTitle("Dashboard")
        
        if hour! < 20 && hour! > 6 { backgroundImage.image = UIImage(named: "dashboardDay")
        } else { backgroundImage.image = UIImage(named: "dashboardNight") }
        
        calendar.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
        self.view.addSubview(calendar)
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        calendar.layer.cornerRadius = 10
        
        clock = SPClockView(frame: CGRect(x: 170, y: 220, width: 140, height: 140))
        clock.timeZone = TimeZone.autoupdatingCurrent
        self.view.addSubview(clock)
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let panRecognizer = UIPanGestureRecognizer(target:self, action:#selector(DashboardViewController.detectPan(_:)))
        clock.addGestureRecognizer(panRecognizer)
        
        let panRecognizer1 = UIPanGestureRecognizer(target:self, action:#selector(DashboardViewController.detectPan1(_:)))
        calendar.addGestureRecognizer(panRecognizer1)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let long = NSString(format: "%.15lf", location.coordinate.longitude)
        let lat = NSString(format: "%.15lf", location.coordinate.latitude)
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=bd82977b86bf27fb59a04b61b657fb6f")
    }
    
    @objc func detectPan(_ recognizer:UIPanGestureRecognizer) {
        
        let translation  = recognizer.translation(in: self.view)
        recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x,
                                              y: recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view!)
    }
    
    @objc func detectPan1(_ recognizer:UIPanGestureRecognizer) {
        
        let translation  = recognizer.translation(in: self.view)
        recognizer.view!.center = CGPoint(x: recognizer.view!.center.x + translation.x, y: recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view!)
    }
    
    func getWeatherData(_ urlString:String){
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) -> Void in
            
            if error == nil { DispatchQueue.main.async(execute: { self.setLabel(data!) } ) }
        }) 
        task.resume()
    }
    
    func setLabel(_ weatherData: Data) {
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour, .minute], from: date)
        let hour = components.hour
        
        if hour! < 20 && hour! > 6 { backgroundImage.image = UIImage(named: "dashboardDay")
        } else { backgroundImage.image = UIImage(named: "dashboardNight") }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: weatherData, options:JSONSerialization.ReadingOptions.mutableContainers ) as? NSDictionary {
                if let name = json["name"] as? String { lblPlace.text = name }
                
                if let weather = json["weather"] as? NSArray {
                    
                    if let weatherDict = weather[0] as? NSDictionary {
                        if let main = weatherDict["main"] as? String { lblWeather.text = main }
                        if let icon = weatherDict["icon"] as? String { imageWeather.image = UIImage(named: weatherDictionary[icon]!) }
                    }
                    
                }
                
                if let main = json["main"] as? NSDictionary {
                    if let temp = main["temp"] as? Double { lblTemp.text =  String(format: "%.1f", temp - 273) + "°C" }
                    var str:String!
                    if let temp_min = main["temp_min"] as? Double { str = String(format: "%.1f", temp_min - 273) + "°C/" }
                    
                    if let temp_max = main["temp_max"] as? Double { lblMinMaxTemp.text = str + (String(format: "%.1f", temp_max - 273) + "°C") }
                }
            }
            
        } catch {}
        
    }
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { calendar.isUserInteractionEnabled = true; clock.isUserInteractionEnabled = true
        } else { calendar.isUserInteractionEnabled = false; clock.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { calendar.isUserInteractionEnabled = true; clock.isUserInteractionEnabled = true
        } else { calendar.isUserInteractionEnabled = false; clock.isUserInteractionEnabled = false }
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen()
    }
}
