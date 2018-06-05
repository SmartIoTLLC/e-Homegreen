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
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "ScenesCell"
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))

    var scrollView = FilterPullDown()
    var filterParametar:FilterItem!
    
    var scenes:[Scene] = []
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var scenesCollectionView: UICollectionView!
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addObservers()
        
        setupConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { scenesCollectionView.reloadData() })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        scenesCollectionView.isUserInteractionEnabled = true
        
        updateSceneList()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setScrollViewBottomOffset(scrollView: &scrollView)
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
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
    
    func updateSceneList(){
        scenes = DatabaseScenesController.shared.getScene(filterParametar)
        scenesCollectionView.reloadData()
    }
    
    func refreshLocalParametars() {
        scenesCollectionView.reloadData()
    }
    
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.scenes)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.scenes)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}



// MARK: - Collection View Delegate Flow Layout
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

// MARK: - Collection View Data Source
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

}

// MARK: - Logic
extension ScenesViewController {
    func setScene (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            let scene = scenes[tag]
            var address:[UInt8] = []
            
            if scene.isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if scene.isLocalcast.boolValue {
                address = [getByte(scene.gateway.addressOne), getByte(scene.gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(scene.gateway.addressOne), getByte(scene.gateway.addressTwo), getByte(scene.address)]
            }
            let sceneId = Int(scene.sceneId)
            if sceneId >= 0 && sceneId <= 32767 { SendingHandler.sendCommand(byteArray: OutgoingHandler.setScene(address, id: Int(scene.sceneId)), gateway: scene.gateway) }
            
            let location = gesture.location(in: scenesCollectionView)
            if let index = scenesCollectionView.indexPathForItem(at: location) {
                if let cell = scenesCollectionView.cellForItem(at: index) as? SceneCollectionCell {
                    cell.changeImageForOneSecond()
                }
            }
        }
    }
    
    func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == UIGestureRecognizerState.began {
                let location = gestureRecognizer.location(in: scenesCollectionView)
                if let index = scenesCollectionView.indexPathForItem(at: location) {
                    if let cell = scenesCollectionView.cellForItem(at: index) {
                        showSceneParametar(CGPoint(x: cell.center.x, y: cell.center.y - scenesCollectionView.contentOffset.y), scene: scenes[tag])
                    }
                }
            }
        }
    }
}

// MARK: - View setup
extension ScenesViewController {
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
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerScenes), object: nil)
    }
}

// MARK: - SW Reveal View Controller Delegate
extension ScenesViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { scenesCollectionView.isUserInteractionEnabled = true } else { scenesCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { scenesCollectionView.isUserInteractionEnabled = true } else { scenesCollectionView.isUserInteractionEnabled = false }
    }
}
