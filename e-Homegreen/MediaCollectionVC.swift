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
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
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
        
        setupConstraints()
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
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
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
        
    }
    
    fileprivate func updateViews() {
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: .red)
        
        
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
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
