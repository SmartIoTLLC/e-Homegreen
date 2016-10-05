//
//  ScenesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class ScenesViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "ScenesCell"
    
    var scrollView = FilterPullDown()
    
    var scenes:[Scene] = []
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var scenesCollectionView: UICollectionView!

    var filterParametar:FilterItem!
    
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
        
        updateSceneList()
        changeFullScreeenImage()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Scenes", subtitle: "All All All")
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ScenesViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.scenes)
        NotificationCenter.default.addObserver(self, selector: #selector(ScenesViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerScenes), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
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
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        scenesCollectionView.reloadData()
        
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.scenes)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    
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
    
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Scenes", subtitle: location + " " + level + " " + zone)
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    func updateSceneList(){
        scenes = DatabaseScenesController.shared.getScene(filterParametar)
        scenesCollectionView.reloadData()
    }
    
    func refreshLocalParametars() {
//        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Scenes)
//        pullDown.drawMenu(filterParametar)
//        updateSceneList()
        scenesCollectionView.reloadData()
    }

    // Helper functions
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.scenes)
    }
}

// Parametar from filter and relaod data
extension ScenesViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.scenes)
        updateSceneList()
        TimerForFilter.shared.counterScenes = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.scenes)
        TimerForFilter.shared.startTimer(type: Menu.scenes)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension ScenesViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            scenesCollectionView.isUserInteractionEnabled = true
        } else {
            scenesCollectionView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            scenesCollectionView.isUserInteractionEnabled = true
        } else {
            scenesCollectionView.isUserInteractionEnabled = false
        }
    }
}

extension ScenesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension ScenesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenes.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SceneCollectionCell
        
            cell.setItem(scenes[(indexPath as NSIndexPath).row], filterParametar: filterParametar)
        
            cell.sceneCellLabel.tag = (indexPath as NSIndexPath).row
            cell.sceneCellLabel.isUserInteractionEnabled = true
            
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ScenesViewController.openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.getImagesFrom(scenes[(indexPath as NSIndexPath).row])
            cell.sceneCellLabel.addGestureRecognizer(longPress)
            cell.sceneCellImageView.tag = (indexPath as NSIndexPath).row
            cell.sceneCellImageView.isUserInteractionEnabled = true
            cell.sceneCellImageView.clipsToBounds = true
            cell.sceneCellImageView.layer.cornerRadius = 5
            let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ScenesViewController.setScene(_:)))
            cell.sceneCellImageView.addGestureRecognizer(set)
            cell.btnSet.tag = (indexPath as NSIndexPath).row
            let setTwo:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ScenesViewController.setScene(_:)))
            cell.btnSet.addGestureRecognizer(setTwo)
            return cell
        
    }
    
    func setScene (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if scenes[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if scenes[tag].isLocalcast.boolValue {
                address = [UInt8(Int(scenes[tag].gateway.addressOne)), UInt8(Int(scenes[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(scenes[tag].gateway.addressOne)), UInt8(Int(scenes[tag].gateway.addressTwo)), UInt8(Int(scenes[tag].address))]
            }
            let sceneId = Int(scenes[tag].sceneId)
            if sceneId >= 0 && sceneId <= 32767 {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setScene(address, id: Int(scenes[tag].sceneId)), gateway: scenes[tag].gateway)
            }
            _ = gesture.view!.tag
            let location = gesture.location(in: scenesCollectionView)
            if let index = scenesCollectionView.indexPathForItem(at: location){
                if let cell = scenesCollectionView.cellForItem(at: index) as? SceneCollectionCell {
                    cell.changeImageForOneSecond()
                }
            }
        }
        
    }
    func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: scenesCollectionView)
            if let index = scenesCollectionView.indexPathForItem(at: location){
                let cell = scenesCollectionView.cellForItem(at: index)
                showSceneParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - scenesCollectionView.contentOffset.y), scene: scenes[tag])
            }
        }
    }
}


