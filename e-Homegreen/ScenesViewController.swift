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
        setupSWRevealViewController(menuButton: menuButton)
        
        scenesCollectionView.isUserInteractionEnabled = true
        
        updateSceneList()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerScenes), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Scenes", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.scenes)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { scenesCollectionView.reloadData() })               
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
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    func updateSceneList(){
        scenes = DatabaseScenesController.shared.getScene(filterParametar)
        scenesCollectionView.reloadData()
    }
    
    func refreshLocalParametars() {
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
        updateSubtitle(headerTitleSubtitleView, title: "Scenes", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)        
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
        if position == .left { scenesCollectionView.isUserInteractionEnabled = true } else { scenesCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { scenesCollectionView.isUserInteractionEnabled = true } else { scenesCollectionView.isUserInteractionEnabled = false }
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
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SceneCollectionCell {
            
            cell.setItem(scenes[indexPath.row], filterParametar: filterParametar, tag: indexPath.row)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.sceneCellLabel.addGestureRecognizer(longPress)
            
            cell.sceneCellImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setScene(_:))))
            cell.btnSet.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setScene(_:))))
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    func setScene (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if scenes[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if scenes[tag].isLocalcast.boolValue {
                address = [getByte(scenes[tag].gateway.addressOne), getByte(scenes[tag].gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(scenes[tag].gateway.addressOne), getByte(scenes[tag].gateway.addressTwo), getByte(scenes[tag].address)]
            }
            let sceneId = Int(scenes[tag].sceneId)
            if sceneId >= 0 && sceneId <= 32767 { SendingHandler.sendCommand(byteArray: OutgoingHandler.setScene(address, id: Int(scenes[tag].sceneId)), gateway: scenes[tag].gateway) }
            
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


