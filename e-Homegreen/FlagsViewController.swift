//
//  FlagsViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class FlagsViewController: PopoverVC {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var flagsCollectionView: UICollectionView!
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    fileprivate let reuseIdentifier = "FlagsCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar:FilterItem!
    var flags:[Flag] = []
    var scrollView = FilterPullDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FlagsViewController.setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerFlags), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Flags", subtitle: "All All All")
        scrollView.setFilterItem(Menu.flags)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        flagsCollectionView.isUserInteractionEnabled = true
        
        reloadFlagsList()
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)                
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { flagsCollectionView.reloadData() })
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.flags)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }

    func reloadFlagsList(){
        flags = DatabaseFlagsController.shared.getFlags(filterParametar)
        flagsCollectionView.reloadData()
    }

    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Flags)
        flagsCollectionView.reloadData()
    }
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.flags)
    }

    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
}

extension FlagsViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { flagsCollectionView.isUserInteractionEnabled = true } else { flagsCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { flagsCollectionView.isUserInteractionEnabled = true } else { flagsCollectionView.isUserInteractionEnabled = false }
    }
}

// Parametar from filter and relaod data
extension FlagsViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(headerTitleSubtitleView, title: "Flags", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.flags)
        reloadFlagsList()
        TimerForFilter.shared.counterFlags = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.flags)
        TimerForFilter.shared.startTimer(type: Menu.flags)
    }
    
    func saveDefaultFilter(){
        view.makeToast(message: "Default filter parametar saved!")
    }
}

extension FlagsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let flagId = Int(flags[indexPath.row].flagId)
        var address:[UInt8] = []
        
        if flags[indexPath.row].isBroadcast.boolValue {
            address = [0xFF, 0xFF, 0xFF]
            
        } else if flags[indexPath.row].isLocalcast.boolValue {
            
            address = [ getByte(flags[indexPath.row].gateway.addressOne),
                        getByte(flags[indexPath.row].gateway.addressTwo),
                        getByte(flags[indexPath.row].address),
                        0xFF ]
        } else {
            address = [ getByte(flags[indexPath.row].gateway.addressOne),
                        getByte(flags[indexPath.row].gateway.addressTwo),
                        getByte(flags[indexPath.row].address) ]
        }
        
        if flags[indexPath.row].setState.boolValue {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[indexPath.row].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[indexPath.row].gateway)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionViewCellSize
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension FlagsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flags.count
    }
    
    func openCellParametar (_ gestureRecognizer: UILongPressGestureRecognizer){
        let tag = gestureRecognizer.view!.tag
        if gestureRecognizer.state == UIGestureRecognizerState.began { showFlagParametar(flags[tag]) }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? FlagCollectionViewCell {
            
            cell.setItem(flags[indexPath.row], filterParametar: filterParametar, tag: indexPath.row)
            
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(openCellParametar(_:)))
            longPress.minimumPressDuration = 0.5
            cell.flagTitle.addGestureRecognizer(longPress)
            cell.flagImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setFlag(_:))))
            cell.flagButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonPressed(_:))))
            
            return cell
        }

        return UICollectionViewCell()
    }
    
    func setFlag (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            let flagId = Int(flags[tag].flagId)
            var address:[UInt8] = []
            
            if flags[tag].isBroadcast.boolValue { address = [0xFF, 0xFF, 0xFF]
            } else if flags[tag].isLocalcast.boolValue { address = [getByte(flags[tag].gateway.addressOne), getByte(flags[tag].gateway.addressTwo), 0xFF]
            } else { address = [getByte(flags[tag].gateway.addressOne), getByte(flags[tag].gateway.addressTwo), getByte(flags[tag].address)] }
            
            if flags[tag].setState.boolValue {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[tag].gateway)
            } else {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[tag].gateway)
            }
            
        }
    }
    
    func buttonPressed (_ gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        let flagId = Int(flags[tag].flagId)
        var address:[UInt8] = []
        
        if flags[tag].isBroadcast.boolValue { address = [0xFF, 0xFF, 0xFF]
        } else { address = [getByte(flags[tag].gateway.addressOne), getByte(flags[tag].gateway.addressTwo), getByte(flags[tag].address)] }
        
        if flags[tag].setState.boolValue {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setFlag(address, id: UInt8(flagId), command: 0x01), gateway: flags[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setFlag(address, id: UInt8(flagId), command: 0x00), gateway: flags[tag].gateway)
        }
    }
}

