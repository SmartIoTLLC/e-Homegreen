//
//  RemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class RemoteViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButton(_ sender: UIButton) {
        showAddRemoteVC()
    }
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBAction func fullScreenButton(_ sender: UIButton) {
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
    
    var remotes: [RemoteDummy] = []
    var selectedRemote: RemoteDummy?
    var location: [Location] = []
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 25, left: 0, bottom: 20, right: 0)
    fileprivate let cellId = "RemoteCell"
    
    @IBOutlet weak var remoteCollectionView: UICollectionView!
    
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar: FilterItem = Filter.sharedInstance.returnFilter(forTab: .Remote)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let remote = RemoteDummy(buggerOff: "Dummy")
        remote.columns = 3
        remote.rows = 5
        remote.buttonSize = CGSize(width: 50, height: 50)
        remote.buttonColor = .red
        remote.buttonShape = "Circle"
        remote.buttonMargins = UIEdgeInsets(top: 25, left: 16, bottom: 20, right: 16)
        remotes.append(remote)        

        remoteCollectionView.reloadData()
        
        UIView.hr_setToastThemeColor(color: .red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
        
        remoteCollectionView.delegate = self
        remoteCollectionView.dataSource = self
        
        scrollView.delegate = self
        view.addSubview(scrollView)
        updateScrollViewConstraints()
        scrollView.setItem(self.view)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Remote", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        scrollView.setFilterItem(Menu.remote)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerRemotes), object: nil)
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
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        } else {
            headerTitleSubtitleView.setPortraitTitle()
        }
        
        var size: CGSize = CGSize()
        CellSize.calculateCellSize(&size, screenWidth: self.view.frame.size.width)
        collectionViewCellSize = size
        remoteCollectionView.reloadData()
    }
    
    func updateSubtitle() {
        headerTitleSubtitleView.setTitleAndSubtitle("Remote", subtitle: filterParametar.location + " " + filterParametar.levelName + " " + filterParametar.zoneName)
    }
    
    func setDefaultFilterFromTimer() {
        scrollView.setDefaultFilterItem(Menu.remote)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            scrollView.setDefaultFilterItem(Menu.remote)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    func updateScrollViewConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 1.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 1.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 1.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 1.0))
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSingleRemote" {
            if let vc: RemoteDetailsViewController = segue.destination as? RemoteDetailsViewController {
                vc.remote = selectedRemote
            }
        }
    }

}

extension RemoteViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = remoteCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? RemoteCell {
            
            cell.setCell(remote: remotes[indexPath.item])
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    
}

extension RemoteViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRemote = remotes[indexPath.row]
        performSegue(withIdentifier: "toSingleRemote", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension RemoteViewController: FilterPullDownDelegate {
    func filterParametars(_ filterItem: FilterItem) {
        filterParametar = filterItem
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.remote)
        updateSubtitle()
        // TODO:  Refresh remotes
        TimerForFilter.shared.counterRemote = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.remote)
        TimerForFilter.shared.startTimer(type: Menu.remote)
    }
    
    func saveDefaultFilter() {
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension RemoteViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            remoteCollectionView.isUserInteractionEnabled = true
        } else {
            remoteCollectionView.isUserInteractionEnabled = false
        }
    }
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            remoteCollectionView.isUserInteractionEnabled = true
        } else {
            remoteCollectionView.isUserInteractionEnabled = false
        }
    }
}
