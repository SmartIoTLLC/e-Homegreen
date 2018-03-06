//
//  MediaCollectionVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 1/8/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import AudioToolbox

class MediaCollectionVC: PopoverVC {
    
    let titleView = NavigationTitleView(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var filterParametar: FilterItem!
    var scrollView = FilterPullDown()
    
    //var mediaCollectionView = UICollectionView()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    
    @IBAction func fullscreenButton(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)
    }
    @IBAction func refreshButton(_ sender: UIButton) {
        sender.rotate(1)
        // TODO: logic
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        updateViews()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setContentOffset(for: scrollView)
        setTitleView(view: titleView)
    }
    
    override func nameAndId(_ name: String, id: String) {
        scrollView.setButtonTitle(name, id: id)
    }
}

extension MediaCollectionVC: FilterPullDownDelegate {
    
    func filterParametars(_ filterItem: FilterItem) {
        filterParametar = filterItem
        // TODO: logic
    }
    
    func saveDefaultFilter() {
        view.makeToast(message: "Default filter parametar saved!")
    }
}

// MARK: - View setup
extension MediaCollectionVC {
    fileprivate func setupScrollView() {
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(view)
        scrollView.setFilterItem(Menu.security)
    }
    
    fileprivate func updateViews() {
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: .red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        navigationItem.titleView = titleView
        titleView.setTitleAndSubtitle("Media", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        titleView.addGestureRecognizer(longPress)
    }
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            scrollView.setDefaultFilterItem(Menu.media)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

extension MediaCollectionVC: SWRevealViewControllerDelegate {
    
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
//        if position == .left { mediaCollectionView.isUserInteractionEnabled = true } else { mediaCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
  //      if position == .left { mediaCollectionView.isUserInteractionEnabled = true } else { mediaCollectionView.isUserInteractionEnabled = false }
    }
}
