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
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var sequenceCollectionView: UICollectionView!
    
    var scrollView = FilterPullDown()
    var senderButton:UIButton?
    var sequences:[Sequence] = []
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var filterParametar:FilterItem!
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "SequenceCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Sequences", subtitle: "All All All")
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SequencesViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.sequences)
        NotificationCenter.default.addObserver(self, selector: #selector(SequencesViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSequences), object: nil)
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
            
            sequenceCollectionView.isUserInteractionEnabled = true
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        updateSequencesList()
        changeFullScreeenImage()
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
        sequenceCollectionView.reloadData()
        
    }
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.sequences)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Sequences", subtitle: location + " " + level + " " + zone)
    }
    func updateSequencesList(){
        sequences = DatabaseSequencesController.shared.getSequences(filterParametar)
        sequenceCollectionView.reloadData()
    }
    func refreshLocalParametars() {
//        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Sequences)
//        pullDown.drawMenu(filterParametar)
//        updateSequencesList()
        sequenceCollectionView.reloadData()
    }
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.sequences)
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
}

// Parametar from filter and relaod data
extension SequencesViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.sequences)
        updateSequencesList()
        TimerForFilter.shared.counterSequences = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.sequences)
        TimerForFilter.shared.startTimer(type: Menu.sequences)
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension SequencesViewController: SWRevealViewControllerDelegate{
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            sequenceCollectionView.isUserInteractionEnabled = true
        } else {
            sequenceCollectionView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            sequenceCollectionView.isUserInteractionEnabled = true
        } else {
            sequenceCollectionView.isUserInteractionEnabled = false
        }
    }
    
}

extension SequencesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

extension SequencesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sequences.count
    }
    
    func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let location = gestureRecognizer.location(in: sequenceCollectionView)
            if let index = sequenceCollectionView.indexPathForItem(at: location){
                let cell = sequenceCollectionView.cellForItem(at: index)
                showSequenceParametar(CGPoint(x: cell!.center.x, y: cell!.center.y - sequenceCollectionView.contentOffset.y), sequence: sequences[tag])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SequenceCollectionViewCell

        cell.setItem(sequences[(indexPath as NSIndexPath).row], filterParametar:filterParametar)
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SequencesViewController.openCellParametar(_:)))
        longPress.minimumPressDuration = 0.5
        cell.sequenceTitle.isUserInteractionEnabled = true
        cell.sequenceTitle.addGestureRecognizer(longPress)
        let set:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SequencesViewController.setSequence(_:)))
        cell.sequenceImageView.tag = (indexPath as NSIndexPath).row
        cell.sequenceImageView.isUserInteractionEnabled = true
        cell.sequenceImageView.addGestureRecognizer(set)
        cell.sequenceImageView.clipsToBounds = true
        cell.sequenceImageView.layer.cornerRadius = 5
        
        cell.getImagesFrom(sequences[(indexPath as NSIndexPath).row])
        
        cell.sequenceButton.tag = (indexPath as NSIndexPath).row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SequencesViewController.tapStop(_:)))
        cell.sequenceButton.addGestureRecognizer(tap)
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func setSequence (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            var address:[UInt8] = []
            if sequences[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if sequences[tag].isLocalcast.boolValue {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), 0xFF]
            } else {
                address = [UInt8(Int(sequences[tag].gateway.addressOne)), UInt8(Int(sequences[tag].gateway.addressTwo)), UInt8(Int(sequences[tag].address))]
            }
            let cycles = Int(sequences[tag].sequenceCycles)
            if cycles >= 0 && cycles <= 255 {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: Int(sequences[tag].sequenceId), cycle: UInt8(cycles)), gateway: sequences[tag].gateway)
            }
            let pointInTable = gesture.view?.convert(gesture.view!.bounds.origin, to: sequenceCollectionView)
            let indexPath = sequenceCollectionView.indexPathForItem(at: pointInTable!)
            if let cell = sequenceCollectionView.cellForItem(at: indexPath!) as? SequenceCollectionViewCell {
                cell.commandSentChangeImage()
            }
        }
    }
    func tapStop (_ gesture:UITapGestureRecognizer) {
        //   Take cell from touched point
        let pointInTable = gesture.view?.convert(gesture.view!.bounds.origin, to: sequenceCollectionView)
        let indexPath = sequenceCollectionView.indexPathForItem(at: pointInTable!)
        if let cell = sequenceCollectionView.cellForItem(at: indexPath!) as? SequenceCollectionViewCell {
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
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: sequenceId, cycle: 0xEF), gateway: sequences[tag].gateway)
            cell.commandSentChangeImage()
        }
    }
}


