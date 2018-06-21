//
//  MediaCollectionViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/14/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

class MediaCollectionViewController: PopoverVC {
    
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    private let titleView: NavigationTitleView = NavigationTitleView(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    private var fullscreenButton: UIButton {
        return self.makeFullscreenButton()
    }
    private var refreshButton: UIButton {
        let button: UIButton = self.makeRefreshButton()
        button.addTap {
            button.rotate(1)
            // TODO: refresh logic
        }
        return button
    }
    
    fileprivate let scrollView: FilterPullDown = FilterPullDown()
    
    fileprivate var filterParameter: FilterItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func addTitleView() {
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        navigationItem.titleView = titleView
        titleView.setTitleAndSubtitle("Media", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        titleView.addGestureRecognizer(longPress)
    }
    
    private func addBackgroundImageView() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
    }
    
    private func addScrollView() {
        scrollView.filterDelegate = self
        
        view.addSubview(scrollView)
        
        updateConstraints(item: scrollView)
        scrollView.setItem(view)
        scrollView.setFilterItem(Menu.media)
    }
    
    private func addCollectionView() {
        
    }
    
    private func setupConstraints() {
        
    }
    
    // MARK: - Logic
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            scrollView.setDefaultFilterItem(Menu.media)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

extension MediaCollectionViewController: FilterPullDownDelegate {
    func filterParametars(_ filterItem: FilterItem) {
        filterParameter = filterItem
        // TODO: logic
    }
    
    func saveDefaultFilter() {
        view.makeToast(message: "Default filter parametar saved!")
    }
}
