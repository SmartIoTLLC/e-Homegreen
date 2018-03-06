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
    
    var scrollView = FilterPullDown()
    var senderButton:UIButton?
    var sequences:[Sequence] = []
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    var filterParametar:FilterItem!
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "SequenceCell"
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var sequenceCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addObservers()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { sequenceCollectionView.reloadData() })
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
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
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
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
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
    
    @objc func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.sequences)
    }
}


// MARK: - Collection View Delegate Flow Layout
extension SequencesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
}

// MARK: - Collection View Data Source
extension SequencesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sequences.count
    }
    
    @objc func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer) {
        if let tag = gestureRecognizer.view?.tag {
            if gestureRecognizer.state == UIGestureRecognizerState.began {
                let location = gestureRecognizer.location(in: sequenceCollectionView)
                if let index = sequenceCollectionView.indexPathForItem(at: location) {
                    if let cell = sequenceCollectionView.cellForItem(at: index) {
                        showSequenceParametar(CGPoint(x: cell.center.x, y: cell.center.y - sequenceCollectionView.contentOffset.y), sequence: sequences[tag])
                    }
                }
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

}

// MARK: - View setup
extension SequencesViewController {
    fileprivate func addObservers() {
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
}

// MARK: - Logic
extension SequencesViewController {
    
    @objc func setSequence (_ gesture:UIGestureRecognizer) {
        if let originPoint = gesture.view?.bounds.origin {
            if let pointInCollection = gesture.view?.convert(originPoint, to: sequenceCollectionView) {
                if let indexPath = sequenceCollectionView.indexPathForItem(at: pointInCollection) {
                    if let cell = sequenceCollectionView.cellForItem(at: indexPath) as? SequenceCollectionViewCell {
                        if let tag = gesture.view?.tag {
                            sendSequenceCommand(.set, onViewWithTag: tag)
                            cell.commandSentChangeImage()
                        }
                    }
                }
            }
        }
    }
    
    @objc func tapStop (_ gesture:UITapGestureRecognizer) {
        if let originPoint = gesture.view?.bounds.origin {
            if let pointInCollection = gesture.view?.convert(originPoint, to: sequenceCollectionView) {
                if let indexPath = sequenceCollectionView.indexPathForItem(at: pointInCollection) {
                    if let cell = sequenceCollectionView.cellForItem(at: indexPath) as? SequenceCollectionViewCell {
                        if let tag = gesture.view?.tag {
                            
                            sendSequenceCommand(.stop, onViewWithTag: tag)
                            cell.commandSentChangeImage()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func sendSequenceCommand(_ seqCommand: SequenceCommand, onViewWithTag tag: Int) {
        
        let sequence   = sequences[tag]
        let sequenceID = sequence.sequenceId.intValue
        let gateway    = sequence.gateway
        
        var address:[UInt8] = []
        if sequence.isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
        } else if sequence.isLocalcast.boolValue {
            address = [getByte(sequence.gateway.addressOne), getByte(sequence.gateway.addressTwo), 0xFF]
        } else {
            address = [getByte(sequence.gateway.addressOne), getByte(sequence.gateway.addressTwo), getByte(sequence.address)]
        }
        var command: UInt8!

        switch seqCommand {
            case .set: command = sequence.sequenceCycles.uint8Value
            if command >= 0 && command <= 255 { SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: sequenceID, cycle: command), gateway: gateway) }
        case .stop: command = 0xEF    //0xEF = 239, stops it?
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: sequenceID, cycle: command), gateway: gateway)
        }
    }
    
    enum SequenceCommand {
        case set
        case stop
    }
}

// MARK: - SW Reveal View Controller Delegate
extension SequencesViewController: SWRevealViewControllerDelegate{
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left { sequenceCollectionView.isUserInteractionEnabled = true } else { sequenceCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == FrontViewPosition.left { sequenceCollectionView.isUserInteractionEnabled = true } else { sequenceCollectionView.isUserInteractionEnabled = false }
    }
    
}
