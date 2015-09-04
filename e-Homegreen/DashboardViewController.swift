//
//  DashboardViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreLocation

class DashboardViewController: CommonViewController, FSCalendarDataSource, FSCalendarDelegate, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var lblPlace: UILabel!
    @IBOutlet weak var lblMinMaxTemp: UILabel!
    @IBOutlet weak var lblTemp: UILabel!
    @IBOutlet weak var lblWeather: UILabel!
    @IBOutlet weak var imageWeather: UIImageView!
    
    var locationManager = CLLocationManager()
//    var backgroundImage = UIImageView()
    

    @IBOutlet weak var backgroundImage: UIImageView!
    
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
    
//    @IBOutlet weak var calendar: FSCalendar!
    var calendar = FSCalendar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        commonConstruct()
        let date = NSDate()
        let calendarUnit = NSCalendar.currentCalendar()
        let components = calendarUnit.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        
        if hour < 20 && hour > 6{
            backgroundImage.image = UIImage(named: "day")
        }else{
            backgroundImage.image = UIImage(named: "night")
        }
//        backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
//        self.view.insertSubview(backgroundImageView, atIndex: 0)
        
        calendar.frame = CGRectMake(50, 50, 200, 200)
        self.view.addSubview(calendar)
        calendar.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.55)
        calendar.layer.cornerRadius = 10
        
        var clock:SPClockView = SPClockView(frame: CGRectMake(170, 220, 140, 140))
        clock.timeZone = NSTimeZone.localTimeZone()
        self.view.addSubview(clock)
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        var panRecognizer = UIPanGestureRecognizer(target:self, action:"detectPan:")
        clock.addGestureRecognizer(panRecognizer)
        
        var panRecognizer1 = UIPanGestureRecognizer(target:self, action:"detectPan1:")
        calendar.addGestureRecognizer(panRecognizer1)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        println("")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var location = locations.last as! CLLocation
        let long = NSString(format: "%.15lf", location.coordinate.longitude)
        let lat = NSString(format: "%.15lf", location.coordinate.latitude)
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detectPan(recognizer:UIPanGestureRecognizer) {
        var translation  = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x,
            recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointMake(0, 0), inView: self.view!)
    }
    
    func detectPan1(recognizer:UIPanGestureRecognizer) {
        var translation  = recognizer.translationInView(self.view)
        recognizer.view!.center = CGPointMake(recognizer.view!.center.x + translation.x,
            recognizer.view!.center.y + translation.y)
        recognizer.setTranslation(CGPointMake(0, 0), inView: self.view!)
    }
    
    func getWeatherData(urlString:String){
        let url = NSURL(string: urlString)
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!){(data,response,error) in
            if error == nil{
                dispatch_async(dispatch_get_main_queue(), {
                    self.setLabel(data)
                    
                })
            }
        }
        task.resume()
    }
    
    func setLabel(weatherData: NSData){
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate: date)
        let hour = components.hour
        
        if hour < 20 && hour > 6{
            backgroundImage.image = UIImage(named: "day")
        }else{
            backgroundImage.image = UIImage(named: "night")
        }
//        backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
//        self.view.insertSubview(backgroundImageView, atIndex: 0)
        var jsonError: NSError?
        let json = NSJSONSerialization.JSONObjectWithData(weatherData, options: nil, error: &jsonError) as! NSDictionary
        if jsonError == nil{
//            println(json)
            if let name = json["name"] as? String{
                lblPlace.text = name
            }
            
            if let weather = json["weather"] as? NSArray{
                
                if let weatherDict = weather[0] as? NSDictionary {
                    if let main = weatherDict["main"] as? String{
                        lblWeather.text = main
                    }
                    if let icon = weatherDict["icon"] as? String{
                        imageWeather.image = UIImage(named: weatherDictionary[icon]!)
                    }
                    
                }

                
            }
           
            if let main = json["main"] as? NSDictionary{
                if let temp = main["temp"] as? Double {
                    lblTemp.text =  String(format: "%.1f", temp - 273) + "°C"
                }
                var str:String!
                if let temp_min = main["temp_min"] as? Double{
                   str = String(format: "%.1f", temp_min - 273) + "°C/"
                }
                
                if let temp_max = main["temp_max"] as? Double{
                   lblMinMaxTemp.text = str.stringByAppendingString(String(format: "%.1f", temp_max - 273) + "°C") 
                }
            }
            
            
        }
        
    }

    
}
