//
//  SurveillenceViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class SurveillenceViewController: PopoverVC {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var cameraCollectionView: UICollectionView!
    @IBOutlet weak var imageBack: UIImageView!
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    var timer:Foundation.Timer = Foundation.Timer()
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var scrollView = FilterPullDown()
    var surveillance:[Surveillance] = []
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var data:Data?
    var sidebarMenuOpen : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Surveillance", subtitle: "All All All")
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SurveillenceViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.surveillance)
        NotificationCenter.default.addObserver(self, selector: #selector(SurveillenceViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSurvailance), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        fetchSurveillance()
        changeFullScreeenImage()
    }
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < scrollView.bounds.size.height {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        
        var size:CGSize = CGSize()
        CellSize.calculateSurvCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        cameraCollectionView.reloadData()
        
    }
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    override func viewWillDisappear(_ animated: Bool) {
        for cell in cameraCollectionView.visibleCells as! [SurveillenceCell] {
            cell.timer?.invalidate()
        }
        removeObservers()
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.surveillance)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Surveillance", subtitle: location + " " + level + " " + zone)
    }
    //change fullscreen button if it pressed in other navigation controller
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
//        pullDown.drawMenu(filterParametar)
        fetchSurveillance()
    }
    func refreshSurveillanceList(){
        fetchSurveillance()
    }
    
    //get surv from database
    func fetchSurveillance() {
        surveillance = DatabaseSurveillanceController.shared.getSurveillace(filterParametar)
        cameraCollectionView.reloadData()
    }
    func addObservers () {
        NotificationCenter.default.addObserver(self, selector: #selector(SurveillenceViewController.refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    func removeObservers () {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    func cameraParametar(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: cameraCollectionView)
            if let index = cameraCollectionView.indexPathForItem(at: location){
                let cell = cameraCollectionView.cellForItem(at: index)
                showCameraParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - cameraCollectionView.contentOffset.y), surveillance: surveillance[(index as NSIndexPath).row])
            }
        }
    }
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.surveillance)
    }
    
    //full screen button from navigation bar
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
}

// Parametar from filter and relaod data
extension SurveillenceViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Surveillance)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.surveillance)
        fetchSurveillance()
        TimerForFilter.shared.counterSurvailance = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.surveillance)
        TimerForFilter.shared.startTimer(type: Menu.surveillance)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension SurveillenceViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            cameraCollectionView.isUserInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            cameraCollectionView.isUserInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            cameraCollectionView.isUserInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SurveillenceViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            cameraCollectionView.isUserInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggle(animated: true)
        }
        
    }
}

extension SurveillenceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveillance.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Surveillance", for: indexPath) as! SurveillenceCell
        
        cell.setItem(surveillance[(indexPath as NSIndexPath).row], filterParametar: filterParametar)
        cell.lblName.isUserInteractionEnabled = true
        cell.lblName.tag = (indexPath as NSIndexPath).row
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SurveillenceViewController.cameraParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.lblName.addGestureRecognizer(longPress)
        
        cell.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = cameraCollectionView.cellForItem(at: indexPath)
        showCamera(CGPoint(x: cell!.center.x, y: cell!.center.y - self.cameraCollectionView.contentOffset.y), surv: surveillance[(indexPath as NSIndexPath).row])
    }
}

extension String {
    
    func removeCharsFromEnd(_ count_:Int) -> String {
        let stringLength = self.characters.count
        
        let substringIndex = (stringLength < count_) ? 0 : stringLength - count_
        
        return self.substring(to: self.characters.index(self.startIndex, offsetBy: substringIndex))
    }
}






