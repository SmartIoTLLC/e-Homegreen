//
//  ScenesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ScenesViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SceneCell"
    
    var scrollView = FilterPullDown()
    
    var scenes:[Scene] = []
    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var scenesCollectionView: UICollectionView!

    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Scenes)
    
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
        
        updateSceneList()
        changeFullScreeenImage()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Scenes)
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
        
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        scenesCollectionView.reloadData()
        
    }
    
    override func nameAndId(name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1.0, constant: 0.0))
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
    
    func updateSceneList(){
        scenes = DatabaseScenesController.shared.getScene(filterParametar)
        scenesCollectionView.reloadData()
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Scenes)
//        pullDown.drawMenu(filterParametar)
//        updateSceneList()
        scenesCollectionView.reloadData()
    }

}

// Parametar from filter and relaod data
extension ScenesViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Scenes)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Scenes)
        updateSceneList()
    }
}

extension ScenesViewController: SWRevealViewControllerDelegate{
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            scenesCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            scenesCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            scenesCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(ScenesViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            scenesCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
    }
}

extension ScenesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {        return collectionViewCellSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
}

extension ScenesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scenes.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SceneCollectionCell
        
            cell.setItem(scenes[indexPath.row], filterParametar: filterParametar)
        
            cell.sceneCellLabel.tag = indexPath.row
            cell.sceneCellLabel.userInteractionEnabled = true
            
            let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ScenesViewController.openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.getImagesFrom(scenes[indexPath.row])
            cell.sceneCellLabel.addGestureRecognizer(longPress)
            cell.sceneCellImageView.tag = indexPath.row
            cell.sceneCellImageView.userInteractionEnabled = true
            cell.sceneCellImageView.clipsToBounds = true
            cell.sceneCellImageView.layer.cornerRadius = 5
            let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ScenesViewController.setScene(_:)))
            cell.sceneCellImageView.addGestureRecognizer(set)
            cell.btnSet.tag = indexPath.row
            let setTwo:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ScenesViewController.setScene(_:)))
            cell.btnSet.addGestureRecognizer(setTwo)
            return cell
        
    }
    
    func setScene (gesture:UIGestureRecognizer) {
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
                SendingHandler.sendCommand(byteArray: Function.setScene(address, id: Int(scenes[tag].sceneId)), gateway: scenes[tag].gateway)
            }
            let tag = gesture.view!.tag
            let location = gesture.locationInView(scenesCollectionView)
            if let index = scenesCollectionView.indexPathForItemAtPoint(location){
                if let cell = scenesCollectionView.cellForItemAtIndexPath(index) as? SceneCollectionCell {
                    cell.changeImageForOneSecond()
                }
            }
        }
        
    }
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(scenesCollectionView)
            if let index = scenesCollectionView.indexPathForItemAtPoint(location){
                let cell = scenesCollectionView.cellForItemAtIndexPath(index)
                showSceneParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - scenesCollectionView.contentOffset.y), scene: scenes[tag])
            }
        }
    }
}


