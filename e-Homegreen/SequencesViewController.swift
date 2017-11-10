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
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerSequences), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Sequences", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.sequences)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        sequenceCollectionView.isUserInteractionEnabled = true
        
        updateSequencesList()
        changeFullscreenImage(fullscreenButton: fullScreenButton)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { sequenceCollectionView.reloadData() })
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.sequences)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func updateSequencesList(){
        sequences = DatabaseSequencesController.shared.getSequences(filterParametar)
        sequenceCollectionView.reloadData()
    }
    func refreshLocalParametars() {
        sequenceCollectionView.reloadData()
    }
    
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.sequences)
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
}

// Parametar from filter and relaod data
extension SequencesViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(headerTitleSubtitleView, title: "Sequences", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.sequences)
        updateSequencesList()
        TimerForFilter.shared.counterSequences = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.sequences)
        TimerForFilter.shared.startTimer(type: Menu.sequences)
    }
    
    func saveDefaultFilter(){
        view.makeToast(message: "Default filter parametar saved!")
    }
}

extension SequencesViewController: SWRevealViewControllerDelegate{
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left { sequenceCollectionView.isUserInteractionEnabled = true } else { sequenceCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left { sequenceCollectionView.isUserInteractionEnabled = true } else { sequenceCollectionView.isUserInteractionEnabled = false }
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SequenceCollectionViewCell {
            
            cell.setItem(sequences[indexPath.row], filterParametar:filterParametar, tag: indexPath.row)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.sequenceTitle.addGestureRecognizer(longPress)
            
            cell.sequenceImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setSequence(_:))))
            cell.sequenceButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapStop(_:))))

            return cell
        }

        return UICollectionViewCell()
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
                address = [getByte(sequences[tag].gateway.addressOne), getByte(sequences[tag].gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(sequences[tag].gateway.addressOne), getByte(sequences[tag].gateway.addressTwo), getByte(sequences[tag].address)]
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
            //   Take tag from touced views
            let tag = gesture.view!.tag
            let sequenceId = Int(sequences[tag].sequenceId)
            var address:[UInt8] = []
            if sequences[tag].isBroadcast.boolValue {
                address = [0xFF, 0xFF, 0xFF]
            } else if sequences[tag].isLocalcast.boolValue {
                address = [getByte(sequences[tag].gateway.addressOne), getByte(sequences[tag].gateway.addressTwo), 0xFF]
            } else {
                address = [getByte(sequences[tag].gateway.addressOne), getByte(sequences[tag].gateway.addressTwo), getByte(sequences[tag].address)]
            }
            //  0xEF = 239, stops it?
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: sequenceId, cycle: 0xEF), gateway: sequences[tag].gateway)
            cell.commandSentChangeImage()
        }
    }
}


