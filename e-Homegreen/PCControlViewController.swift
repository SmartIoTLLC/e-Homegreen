//
//  PCControlViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class PCControlViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    var scrollView = FilterPullDown()
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    
    var sidebarMenuOpen : Bool!
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    
    @IBOutlet weak var pccontrolCollectionView: UICollectionView!
    var pcs:[Device] = []
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .PCControl)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("PC Control", subtitle: "All All All")
        
        pccontrolCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .PCControl)
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PCControlViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.PCControl)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        updatePCList()
        changeFullScreeenImage()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        pccontrolCollectionView.reloadData()
        
    }
    
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateSubtitle(location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("PC Control", subtitle: location + " " + level + " " + zone)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func defaultFilter(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            scrollView.setDefaultFilterItem(Menu.PCControl)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @IBAction func fullScreen(sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.sharedApplication().statusBarHidden {
            UIApplication.sharedApplication().statusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        } else {
            UIApplication.sharedApplication().statusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    func changeFullScreeenImage(){
        if UIApplication.sharedApplication().statusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), forState: UIControlState.Normal)
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), forState: UIControlState.Normal)
        }
    }
    
    func updatePCList(){
        pcs = DatabaseDeviceController.shared.getPCs(filterParametar)
        pccontrolCollectionView.reloadData()
    }
    
    @IBAction func changeSliderValue(sender: AnyObject) {
        guard let slider = sender as? UISlider else {
            return
        }
        guard let tag = sender.tag else {
            return
        }
        let address = [Byte(Int(pcs[tag].gateway.addressOne)), Byte(Int(pcs[tag].gateway.addressTwo)), Byte(Int(pcs[tag].address))]
        let value = Byte(Int(slider.value * 100))
        if value == 0x00 {
            SendingHandler.sendCommand(byteArray: Function.setPCVolume(address, volume: pcs[tag].pcVolume, mute: 0x01), gateway: pcs[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: Function.setPCVolume(address, volume: value), gateway: pcs[tag].gateway)
            pcs[tag].pcVolume = value
        }
    }

}

// Parametar from filter and relaod data
extension PCControlViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .PCControl)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .PCControl)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.PCControl)
        updatePCList()
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension PCControlViewController: SWRevealViewControllerDelegate{
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            pccontrolCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            pccontrolCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            pccontrolCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(PCControlViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            pccontrolCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
    
    func openNotificationSettings(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            if let index = gestureRecognizer.view?.tag {
                print("DUGO DRZANJE LABELE TAG: \(index)")
                self.showPCNotifications(self.pcs[index])
            }
        }
    }
}

extension PCControlViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pccontrolCell", forIndexPath: indexPath) as? PCControlCell{
            cell.setItem(pcs[indexPath.row], tag: indexPath.row, filterParametar: filterParametar)
            cell.pccontrolTitleLabel.tag = indexPath.row
            
            let volume = Float(pcs[indexPath.row].pcVolume)
            cell.pccontrolSlider.value = volume/100

            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(PCControlViewController.openNotificationSettings(_:)))
            longGesture.minimumPressDuration = 0.5
            cell.pccontrolTitleLabel.addGestureRecognizer(longGesture)
            
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pcs.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_main_queue(),{
            self.showPCInterface(self.pcs[indexPath.row])
        })
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
}
