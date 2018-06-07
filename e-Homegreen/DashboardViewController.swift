//
//  DashboardViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreLocation

private struct LocalConstants {
    static let calendarFrame: CGRect = CGRect(x: 50, y: 50, width: 200, height: 200)
    static let clockFrame: CGRect = CGRect(x: 170, y: 220, width: 140, height: 140)
    static let weatherImageSize: CGFloat = 40
    static let minMaxTempLabelSize: CGSize = CGSize(width: 284, height: 21)
    static let placeLabelSize: CGSize = CGSize(width: 138, height: 21)
    static let tempLabelSize: CGSize = CGSize(width: 214, height: 21)
}

struct WeatherApiKeys {
    static let cityName: String = "name"
    static let weather: String = "weather"
    static let weatherState: String = "main"
    static let icon: String = "icon"
    static let temperature: String = "temp"
    static let minTemperature: String = "temp_min"
    static let maxTemperature: String = "temp_max"
}

class DashboardViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, CLLocationManagerDelegate, SWRevealViewControllerDelegate {
    private let locationManager = CLLocationManager()
    private let weatherDictionary:[String: String] = ["01d":"weather-clear",
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
    private let calendar: FSCalendar = FSCalendar(frame: LocalConstants.calendarFrame)
    private let clock : SPClockView = SPClockView(frame: LocalConstants.clockFrame)
    
    private let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    private let backgroundImageView: UIImageView = UIImageView()
    
    private let placeLabel: UILabel = UILabel()
    private let minMaxTempLabel: UILabel = UILabel()
    private let tempLabel: UILabel = UILabel()
    private let weatherLabel: UILabel = UILabel()
    private let weatherImage: UIImageView = UIImageView()
    
    private var menuButton: UIBarButtonItem {
        return self.makeMenuBarButton()
    }
    
    private var fullScreenButton: UIButton {
        return self.makeFullscreenButton()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.revealViewController().delegate = self
        
        setupLocationManager()
        setupBarButtonItems()
        
        addTitleView()
        addBackgroundImageView()
        addCalendar()
        addClock()
        addPlaceLabel()
        addMinMaxTempLabel()
        addTempLabel()
        addWeatherImage()
        addWeatherLabel()
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setBackgroundImage()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    // MARK: - Setup views
    private func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: fullScreenButton)
    }
    
    private func addTitleView() {
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        navigationItem.titleView = titleView
        titleView.setTitle("Dashboard")
    }
    
    private func addBackgroundImageView() {
        view.addSubview(backgroundImageView)
    }
    
    private func addPlaceLabel() {
        placeLabel.font = .tahoma(size: 20)
        
        view.addSubview(placeLabel)
    }
    private func addMinMaxTempLabel() {
        minMaxTempLabel.font = .tahoma(size: 17)
        
        view.addSubview(minMaxTempLabel)
    }
    private func addTempLabel() {
        tempLabel.font = .tahoma(size: 67)
        
        view.addSubview(tempLabel)
    }
    private func addWeatherLabel() {
        weatherLabel.font = .tahoma(size: 17)
        
        view.addSubview(weatherLabel)
    }
    private func addWeatherImage() {
        
        view.addSubview(weatherImage)
    }
    
    private func addCalendar() {
        calendar.tag = 0
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0.55)
        calendar.layer.cornerRadius = 10
        calendar.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(DashboardViewController.detectPan(_:))))
        
        if let centerPoint = defaults.dictionary(forKey: UserDefaults.Dashboard.calendarCenterPoint) {
            if let x = centerPoint["x"] as? CGFloat {
                if let y = centerPoint["y"] as? CGFloat {
                    calendar.center = CGPoint(x: x, y: y)
                }
            }
        }
        
        view.addSubview(calendar)
    }
    
    private func addClock() {
        clock.tag = 1
        clock.timeZone = TimeZone.autoupdatingCurrent
        clock.addGestureRecognizer(UIPanGestureRecognizer(target:self, action:#selector(DashboardViewController.detectPan(_:))))

        if let centerPoint = defaults.dictionary(forKey: UserDefaults.Dashboard.clockCenterPoint) {
            if let x = centerPoint["x"] as? CGFloat {
                if let y = centerPoint["y"] as? CGFloat {
                    clock.center = CGPoint(x: x, y: y)
                }
            }
        }
        
        view.addSubview(clock)
    }
    
    private func setBackgroundImage() {
        let date = Date()
        let calendarUnit = Calendar.current
        let components = (calendarUnit as NSCalendar).components([.hour, .minute], from: date)
        if let hour = components.hour {
            backgroundImageView.image = UIImage(named: (hour < 20 && hour > 6) ? "dashboardDay" : "dashboardNight")
        }
        
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        
        minMaxTempLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(21)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-13)
            } else {
                make.bottom.equalToSuperview().offset(13)
            }
        }
        
        tempLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(minMaxTempLabel.snp.top).offset(8)
            make.leading.equalTo(minMaxTempLabel.snp.leading)
            make.trailing.equalTo(minMaxTempLabel.snp.trailing)
            make.height.equalTo(76)
        }
        
        weatherImage.snp.makeConstraints { (make) in
            make.bottom.equalTo(tempLabel.snp.top)
            make.width.height.equalTo(40)
            make.leading.equalTo(tempLabel.snp.leading)
        }
        
        weatherLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(weatherImage.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(21)
            make.top.equalTo(placeLabel.snp.bottom)
        }
        
        placeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(weatherImage.snp.top)
            make.leading.equalTo(weatherLabel.snp.leading)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(21)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let long = NSString(format: "%.15lf", location.coordinate.longitude)
            let lat = NSString(format: "%.15lf", location.coordinate.latitude)
            getWeatherData(from: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&APPID=5497eeedc15603f26373b258e5e50e75")
        }
    }
    
    @objc private func detectPan(_ recognizer:UIPanGestureRecognizer) {
        
        if let recognizerView = recognizer.view {
            let translation  = recognizer.translation(in: self.view)
            let viewCenter: CGPoint = CGPoint(x: recognizerView.center.x + translation.x, y: recognizerView.center.y + translation.y)
            recognizerView.center = viewCenter
            let viewKey: String = (recognizerView.tag == 0) ? UserDefaults.Dashboard.calendarCenterPoint : UserDefaults.Dashboard.clockCenterPoint
            defaults.setValue(
                ["x": viewCenter.x,
                "y": viewCenter.y],
                forKey: viewKey
            )
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view!)
        }
    }
    
    private func getWeatherData(from urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                
                if error == nil {
                    if let data = data {
                        DispatchQueue.main.async(execute: { self.setWeatherLData(data) } )
                    }
                }
            })
            task.resume()
        }
    }
    
    private func setWeatherLData(_ weatherData: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: weatherData, options:JSONSerialization.ReadingOptions.mutableContainers ) as? NSDictionary {
                
                if let name = json[WeatherApiKeys.cityName] as? String { placeLabel.text = name }
                
                if let weather = json[WeatherApiKeys.weather] as? NSArray {
                    
                    if let weatherDict = weather[0] as? NSDictionary {
                        if let main = weatherDict[WeatherApiKeys.weatherState] as? String { weatherLabel.text = main }
                        if let icon = weatherDict[WeatherApiKeys.icon] as? String { weatherImage.image = UIImage(named: weatherDictionary[icon]!) }
                    }
                    
                }
                
                if let main = json[WeatherApiKeys.weatherState] as? NSDictionary {
                    if let temp = main[WeatherApiKeys.temperature] as? Double { tempLabel.text =  String(format: "%.1f", temp - 273) + "°C" }
                    var str:String!
                    if let temp_min = main[WeatherApiKeys.minTemperature] as? Double { str = String(format: "%.1f", temp_min - 273) + "°C/" }
                    
                    if let temp_max = main[WeatherApiKeys.maxTemperature] as? Double { minMaxTempLabel.text = str + (String(format: "%.1f", temp_max - 273) + "°C") }
                }
            }
            
        } catch {}
        
    }
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        calendar.isUserInteractionEnabled = (position == .left) ? true : false
        clock.isUserInteractionEnabled = (position == .left) ? true : false
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        calendar.isUserInteractionEnabled = (position == .left) ? true : false
        clock.isUserInteractionEnabled = (position == .left) ? true : false
    }
    
}
