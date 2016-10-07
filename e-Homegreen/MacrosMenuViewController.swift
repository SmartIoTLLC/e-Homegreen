//
//  MacrosMenuViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 10/7/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class MacrosMenuViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var macrosCollectionView: UICollectionView!
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0)
    fileprivate let reuseIdentifier = "MacroCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar:FilterItem!
    var macros:[Macro] = []
    var scrollView = FilterPullDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Macros", subtitle: "All All All")
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MacrosMenuViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)

        scrollView.setFilterItem(Menu.macros)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            
            revealViewController().rearViewRevealWidth = 200
            
        }
        
        reloadMacrosList()
        changeFullScreeenImage()
        
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
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
        macrosCollectionView.reloadData()
        
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            scrollView.setDefaultFilterItem(Menu.macros)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    
    func reloadMacrosList(){
        macros = DatabaseMacrosController.shared.getMacrosByUser(filterParametar)
        macrosCollectionView.reloadData()
    }
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Macros", subtitle: location + " " + level + " " + zone)
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
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

extension MacrosMenuViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            macrosCollectionView.isUserInteractionEnabled = true
        } else {
            macrosCollectionView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            macrosCollectionView.isUserInteractionEnabled = true
        } else {
            macrosCollectionView.isUserInteractionEnabled = false
        }
    }
}

// Parametar from filter and relaod data
extension MacrosMenuViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        filterParametar = filterItem
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.macros)
        reloadMacrosList()
//        TimerForFilter.shared.counterFlags = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.flags)
//        TimerForFilter.shared.startTimer(type: Menu.flags)
        
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension MacrosMenuViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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

extension MacrosMenuViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return macros.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MacrosCollectionViewCell
        
        cell.setItem(macros[indexPath.row], filterParametar: filterParametar)
        
        return cell
    }
}
