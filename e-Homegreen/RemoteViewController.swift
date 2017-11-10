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
        showAddRemoteVC(filter: filterParametar)
    }
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBAction func fullScreenButton(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    var remotes: [RemoteDummy] = []
    var remotesList: [Remote] = []
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
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerRemotes), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadRemotes), name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
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
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
        
        remoteCollectionView.delegate = self
        remoteCollectionView.dataSource = self
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Remote", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        scrollView.setFilterItem(Menu.remote)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        changeFullscreenImage(fullscreenButton: fullScreenButton)
        toggleAddButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { remoteCollectionView.reloadData() })
    }
    
    
    override func nameAndId(_ name: String, id: String) {
        scrollView.setButtonTitle(name, id: id)
    }
    
    func toggleAddButton() {
        if filterParametar.location != "All" { addButton.isEnabled = true } else { addButton.isEnabled = false }
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
    
    func loadRemotes() {
        //remotesList = DatabaseRemoteController.sharedInstance.getRemotes(filterParametar)
        remoteCollectionView.reloadData()
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
        updateSubtitle(headerTitleSubtitleView, title: "Remote", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        loadRemotes()
        // TODO:  Refresh remotes
        TimerForFilter.shared.counterRemote = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.remote)
        TimerForFilter.shared.startTimer(type: Menu.remote)
        toggleAddButton()
    }
    
    func saveDefaultFilter() {
        view.makeToast(message: "Default filter parametar saved!")
    }
}

extension RemoteViewController: SWRevealViewControllerDelegate {
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        if position == .left { remoteCollectionView.isUserInteractionEnabled = true } else { remoteCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        if position == .left { remoteCollectionView.isUserInteractionEnabled = true } else { remoteCollectionView.isUserInteractionEnabled = false }
    }
}
