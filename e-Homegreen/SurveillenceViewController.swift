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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSurvailance), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Surveillance", subtitle: "All All All")
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        scrollView.setFilterItem(Menu.surveillance)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        cameraCollectionView.isUserInteractionEnabled = true
        
        fetchSurveillance()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
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
        
        setTitleView(view: headerTitleSubtitleView)        
        
        collectionViewCellSize = calculateCellSize(completion: { cameraCollectionView.reloadData() })                
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        for cell in cameraCollectionView.visibleCells as! [SurveillenceCell] { cell.timer?.invalidate() }
        removeObservers()
    }
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.surveillance)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    @objc func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
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
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    func removeObservers () {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    @objc func cameraParametar(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: cameraCollectionView)
            if let index = cameraCollectionView.indexPathForItem(at: location){
                let cell = cameraCollectionView.cellForItem(at: index)
                showCameraParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - cameraCollectionView.contentOffset.y), surveillance: surveillance[index.row])
            }
        }
    }
    @objc func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.surveillance)
    }
    
    //full screen button from navigation bar
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)
    }
}

// Parametar from filter and relaod data
extension SurveillenceViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Surveillance)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Surveillance)
        updateSubtitle(headerTitleSubtitleView, title: "Surveillance", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
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
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        if position == .left { cameraCollectionView.isUserInteractionEnabled = true } else { cameraCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        if position == .left { cameraCollectionView.isUserInteractionEnabled = true } else { cameraCollectionView.isUserInteractionEnabled = false }
    }
    
    
}

extension SurveillenceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return surveillance.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Surveillance", for: indexPath) as? SurveillenceCell {
            cell.setItem(surveillance[indexPath.row], filterParametar: filterParametar, tag: indexPath.row)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(cameraParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.lblName.addGestureRecognizer(longPress)
            
            return cell
        }
        
        return UICollectionViewCell()
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
        showCamera(CGPoint(x: cell!.center.x, y: cell!.center.y - self.cameraCollectionView.contentOffset.y), surv: surveillance[indexPath.row])
    }
}

extension String {
    
    func removeCharsFromEnd(_ count_:Int) -> String {
        let stringLength = self.count
        
        let substringIndex = (stringLength < count_) ? 0 : stringLength - count_
        
        return self.substring(to: self.index(self.startIndex, offsetBy: substringIndex))
    }
}






