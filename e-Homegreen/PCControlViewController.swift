//
//  PCControlViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AudioToolbox

class PCControlViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    var scrollView = FilterPullDown()
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    fileprivate var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    
    @IBOutlet weak var pccontrolCollectionView: UICollectionView!
    var pcs:[Device] = []
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .PCControl)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerPCControl), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePCList), name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
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
        headerTitleSubtitleView.setTitleAndSubtitle("PC Control", subtitle: "All All All")
        
        pccontrolCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .PCControl)
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PCControlViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.pcControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        updatePCList()
        changeFullscreenImage(fullscreenButton: fullScreenButton)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        refreshVisiblePCsInScrollView()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)        
        collectionViewCellSize = calculateCellSize(completion: { pccontrolCollectionView.reloadData() })
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    @objc func setDefaultFilterFromTimer() {
        scrollView.setDefaultFilterItem(Menu.pcControl)
    }
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.pcControl)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    func refreshVisiblePCsInScrollView() {
        
        let indexPaths = pccontrolCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths { reloadPCFromPLC(indexPathRow: indexPath.row) }
    }
    
    func reloadPCFromPLC(indexPathRow: Int) {
        for pc in pcs {
            if pc.gateway == pcs[indexPathRow].gateway && pc.address == pcs[indexPathRow].address { pc.stateUpdatedAt = Date() }
        }
        
        let address = [getByte(pcs[indexPathRow].gateway.addressOne), getByte(pcs[indexPathRow].gateway.addressTwo), getByte(pcs[indexPathRow].address)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getPCState(address), gateway: pcs[indexPathRow].gateway)
    }
    
    @objc func updatePCList(){
        pcs = DatabaseDeviceController.shared.getPCs(filterParametar)
        pccontrolCollectionView.reloadData()
    }
    
    @objc func changeSliderValueOnOneTap(_ gesture: UIGestureRecognizer) {
        
        let s = gesture.view as! UISlider
        if s.isHighlighted { return }
        
        let pt: CGPoint = gesture.location(in: s)
        let percentage: CGFloat = pt.x / s.bounds.size.width
        let delta: CGFloat = percentage * (CGFloat(s.maximumValue) - CGFloat(s.minimumValue))
        let value: CGFloat = CGFloat(s.minimumValue) + delta
        s.setValue(Float(value), animated: true)
        let tag = s.tag
        let address = [getByte(pcs[tag].gateway.addressOne), getByte(pcs[tag].gateway.addressTwo), getByte(pcs[tag].address)]
        if value == 0x00 {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setPCVolume(address, volume: 0x00, mute: 0x01), gateway: pcs[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setPCVolume(address, volume: Byte(value*100)), gateway: pcs[tag].gateway)
            pcs[tag].currentValue = NSNumber(value: Int(value*100))
        }
        
    }
    
    @IBAction func changeSliderValue(_ sender: AnyObject) {
        guard let slider = sender as? UISlider else { return }
        guard let tag = sender.tag else { return }
        
        let address = [getByte(pcs[tag].gateway.addressOne), getByte(pcs[tag].gateway.addressTwo), getByte(pcs[tag].address)]
        let value = Byte(Int(slider.value * 100))
        if value == 0x00 {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setPCVolume(address, volume: 0x00, mute: 0x01), gateway: pcs[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setPCVolume(address, volume: value*100), gateway: pcs[tag].gateway)
            pcs[tag].currentValue = NSNumber(value: Int(value*100))
        }
    }

}

// Parametar from filter and relaod data
extension PCControlViewController: FilterPullDownDelegate {
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .PCControl)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .PCControl)
        updateSubtitle(headerTitleSubtitleView, title: "PC Control", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)        
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.pcControl)
        updatePCList()
        TimerForFilter.shared.counterPCControl = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.pcControl)
        TimerForFilter.shared.startTimer(type: Menu.pcControl)
    }
    
    func saveDefaultFilter() {
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension PCControlViewController: SWRevealViewControllerDelegate {
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { pccontrolCollectionView.isUserInteractionEnabled = true } else { pccontrolCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        if position == FrontViewPosition.left { pccontrolCollectionView.isUserInteractionEnabled = true } else { pccontrolCollectionView.isUserInteractionEnabled = false }
    }
    
    @objc func openNotificationSettings(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            if let index = gestureRecognizer.view?.tag {
                print("DUGO DRZANJE LABELE TAG: \(index)")
                self.showPCNotifications(self.pcs[index])
            }
        }
    }
}

extension PCControlViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pccontrolCell", for: indexPath) as? PCControlCell {
            
            cell.setItem(pcs[indexPath.row], tag: indexPath.row, filterParametar: filterParametar)
            
            cell.pccontrolSlider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changeSliderValueOnOneTap(_:))))

            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(openNotificationSettings(_:)))
            longGesture.minimumPressDuration = 0.5
            cell.pccontrolTitleLabel.addGestureRecognizer(longGesture)
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pcs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionViewCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DispatchQueue.main.async(execute: { self.showPCInterface(self.pcs[indexPath.row]) })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension PCControlViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view! is UISlider { return false }
        return true
    }
    
}
