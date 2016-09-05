//
//  SequencesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class SequencesViewController: PopoverVC {

    @IBOutlet weak var sequenceCollectionView: UICollectionView!
    
    var scrollView = FilterPullDown()
    var senderButton:UIButton?
    
    var sequences:[Sequence] = []
    
    var sidebarMenuOpen : Bool!
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRectMake(0, 0, CGFloat.max, 44))
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    private let reuseIdentifier = "SequenceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Sequences)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.redColor())
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Sequences", subtitle: "All, All, All")

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Sequences)
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SequencesViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.Sequences)
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
        
        updateSequencesList()
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
        sequenceCollectionView.reloadData()
        
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
    
    func defaultFilter(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            scrollView.setDefaultFilterItem(Menu.Sequences)
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
    
    func updateSubtitle(location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Sequences", subtitle: location + ", " + level + ", " + zone)
    }
    
    func updateSequencesList(){
        sequences = DatabaseSequencesController.shared.getSequences(filterParametar)
        sequenceCollectionView.reloadData()
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Sequences)
//        pullDown.drawMenu(filterParametar)
//        updateSequencesList()
        sequenceCollectionView.reloadData()
    } 

}

// Parametar from filter and relaod data
extension SequencesViewController: FilterPullDownDelegate{
    func filterParametars(filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Sequences)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Sequences)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.Sequences)
        updateSequencesList()
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension SequencesViewController: SWRevealViewControllerDelegate{
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            sequenceCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            sequenceCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            sequenceCollectionView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            let tap = UITapGestureRecognizer(target: self, action: #selector(SequencesViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            sequenceCollectionView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
}

extension SequencesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

extension SequencesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sequences.count
    }
    
    func openCellParametar (gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            let location = gestureRecognizer.locationInView(sequenceCollectionView)
            if let index = sequenceCollectionView.indexPathForItemAtPoint(location){
                let cell = sequenceCollectionView.cellForItemAtIndexPath(index)
                showSequenceParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - sequenceCollectionView.contentOffset.y), sequence: sequences[tag])
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SequenceCollectionViewCell

        cell.setItem(sequences[indexPath.row], filterParametar:filterParametar)
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SequencesViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.sequenceTitle.userInteractionEnabled = true
        cell.sequenceTitle.addGestureRecognizer(longPress)
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SequencesViewController.setSequence(_:)))
        cell.sequenceImageView.tag = indexPath.row
        cell.sequenceImageView.userInteractionEnabled = true
        cell.sequenceImageView.addGestureRecognizer(set)
        cell.sequenceImageView.clipsToBounds = true
        cell.sequenceImageView.layer.cornerRadius = 5
        
        cell.getImagesFrom(sequences[indexPath.row])
        
        cell.sequenceButton.tag = indexPath.row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SequencesViewController.tapStop(_:)))
        cell.sequenceButton.addGestureRecognizer(tap)
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 5
    }
    
    func setSequence (gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if sequences[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if sequences[tag].isLocalcast.boolValue {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), UInt8(Int(sequences[tag].address))]
            }
            if let cycles = sequences[tag].sequenceCycles as? Int {
                if cycles >= 0 && cycles <= 255 {
                    SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequences[tag].sequenceId), cycle: UInt8(cycles)), gateway: sequences[tag].gateway)
                }
            } else {
                SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequences[tag].sequenceId), cycle: 0x00), gateway: sequences[tag].gateway)
            }
            let pointInTable = gesture.view?.convertPoint(gesture.view!.bounds.origin, toView: sequenceCollectionView)
            let indexPath = sequenceCollectionView.indexPathForItemAtPoint(pointInTable!)
            if let cell = sequenceCollectionView.cellForItemAtIndexPath(indexPath!) as? SequenceCollectionViewCell {
                cell.commandSentChangeImage()
            }
        }
    }
    func tapStop (gesture:UITapGestureRecognizer) {
        //   Take cell from touched point
        let pointInTable = gesture.view?.convertPoint(gesture.view!.bounds.origin, toView: sequenceCollectionView)
        let indexPath = sequenceCollectionView.indexPathForItemAtPoint(pointInTable!)
        if let cell = sequenceCollectionView.cellForItemAtIndexPath(indexPath!) as? SequenceCollectionViewCell {
            //   Take tag from touced vies
            let tag = gesture.view!.tag
            let sequenceId = Int(sequences[tag].sequenceId)
            var address:[UInt8] = []
            if sequences[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if sequences[tag].isLocalcast.boolValue {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), UInt8(Int(sequences[tag].address))]
            }
            //  0xEF = 239, stops it?
            SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: sequenceId, cycle: 0xEF), gateway: sequences[tag].gateway)
            cell.commandSentChangeImage()
        }
    }
}


