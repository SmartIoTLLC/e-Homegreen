//
//  ScenesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ScenesViewController: UIViewController, PullDownViewDelegate, UIPopoverPresentationControllerDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SceneCell"
    var pullDown = PullDownView()
    
    var appDel:AppDelegate!
    var scenes:[Scene] = []
    var error:NSError? = nil
    var sidebarMenuOpen : Bool!
    
    var senderButton:UIButton?
    
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var scenesCollectionView: UICollectionView!

    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Scenes)
    
    func pullDownSearchParametars (filterItem:FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Scenes)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Scenes)
        updateSceneList()

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
        
        updateSceneList()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)

        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Scenes)
    }
    
    func updateSceneList(){
        scenes = DatabaseScenesController.shared.getScene(filterParametar)
        scenesCollectionView.reloadData()
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Scenes)
        pullDown.drawMenu(filterParametar)
//        updateSceneList()
        scenesCollectionView.reloadData()
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {

            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            
        } else {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
        }
        var size:CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        scenesCollectionView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
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


