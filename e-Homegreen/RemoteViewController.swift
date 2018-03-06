//
//  RemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

struct RemoteMeasures {
    let allowedWidth  : CGFloat
    let allowedHeight : CGFloat
}

class RemoteViewController: PopoverVC {
    
    var remotesList: [Remote] = []
    var selectedRemote: Remote?
    
    var user: User?
    
    var location: [Location] = []
    var pickedLocation: Location?
    
    var scrollView = FilterPullDown()
    let headerTitleSubtitleView = NavigationTitleView(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    var filterParametar: FilterItem = Filter.sharedInstance.returnFilter(forTab: .Remote)
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    fileprivate var sectionInsets = UIEdgeInsets(top: 25, left: 0, bottom: 20, right: 0)
    fileprivate let cellId = "RemoteCell"
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addButton(_ sender: UIButton) {
        addTapped()
    }
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBAction func fullScreenButton(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    @IBOutlet weak var remoteCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        addObservers()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
        collectionViewCellSize = calculateCellSize(completion: { remoteCollectionView.reloadData() })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        changeFullscreenImage(fullscreenButton: fullScreenButton)
        toggleAddButton()
        loadRemotesOnStart(from: pickedLocation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func nameAndId(_ name: String, id: String) {
        scrollView.setButtonTitle(name, id: id)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toSingleRemote" {
            if let vc: RemoteDetailsViewController = segue.destination as? RemoteDetailsViewController {
                vc.remote = selectedRemote
                vc.filterParameter = filterParametar
            }
        }
    }

}

// MARK: - UICollectionView DataSource
extension RemoteViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remotesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getCell(at: indexPath, collectionView)
    }
    
}

// MARK: - UICollectionView Delegate
extension RemoteViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectRemote(at: indexPath)
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

// MARK: - Logic
extension RemoteViewController {
    fileprivate func prepareLocation() {
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            
            let locations = DatabaseLocationController.shared.getLocation(user)
            locations.forEach({ (loc) in
                if loc.name == filterParametar.location { self.pickedLocation = loc }
            })
            
        } else { view.makeToast(message: "No user database selected."); return }
        
    }
    
    fileprivate func loadRemotes(from location: Location) {
        remotesList = DatabaseRemoteController.sharedInstance.getRemotes(from: location)
        if remotesList.count != 0 { remotesList.sort(by: { (one, two) -> Bool in one.name! < two.name! }) }
        remoteCollectionView.reloadData()
    }
    
    fileprivate func loadRemotesOnStart(from location: Location?) {
        if filterParametar.location != "All" {
            if let location = location {
                loadRemotes(from: location)
            }
        }
    }
    
    @objc fileprivate func refreshRemotes() {
        remotesList = DatabaseRemoteController.sharedInstance.getRemotes(from: pickedLocation!)
        remoteCollectionView.reloadData()
    }
    
    fileprivate func addTapped() {
        if let _ = DatabaseUserController.shared.loggedUserOrAdmin() {
            showAddRemoteVC(filter: filterParametar, location: pickedLocation!)
        } else { view.makeToast(message: "No user database selected.") }
    }
    
    fileprivate func didSelectRemote(at indexPath: IndexPath) {
        selectedRemote = remotesList[indexPath.row]
        performSegue(withIdentifier: "toSingleRemote", sender: self)
    }
}

// MARK: - View setup
extension RemoteViewController {
    
    fileprivate func getCell(at indexPath: IndexPath, _ collectionView: UICollectionView) -> UICollectionViewCell {
        if let cell = remoteCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? RemoteCell {
            
            cell.setCell(remote: remotesList[indexPath.item])
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerRemotes), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRemotes), name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: .red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
        
        remoteCollectionView.delegate = self
        remoteCollectionView.dataSource = self
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(view)
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Remote", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        scrollView.setFilterItem(Menu.remote)
    }
    
    func toggleAddButton() {
        if filterParametar.location != "All" { addButton.isEnabled = true } else { addButton.isEnabled = false }
    }
    
    @objc func setDefaultFilterFromTimer() {
        scrollView.setDefaultFilterItem(Menu.remote)
    }
    
    @objc func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            scrollView.setDefaultFilterItem(Menu.remote)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}

// MARK: - Navigation
extension RemoteViewController {
    
    
}

// MARK: - FilterPullDown Delegate
extension RemoteViewController: FilterPullDownDelegate {
    func filterParametars(_ filterItem: FilterItem) {
        filterParametar = filterItem
        updateSubtitle(headerTitleSubtitleView, title: "Remote", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.remote)
        prepareLocation()
        if pickedLocation != nil { loadRemotes(from: pickedLocation!) }
    
        TimerForFilter.shared.counterRemote = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.remote)
        TimerForFilter.shared.startTimer(type: Menu.remote)
        toggleAddButton()
    }
    
    func saveDefaultFilter() {
        view.makeToast(message: "Default filter parametar saved!")
    }
}

// MARK: - SWRevealViewController Delegate
extension RemoteViewController: SWRevealViewControllerDelegate {
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        if position == .left { remoteCollectionView.isUserInteractionEnabled = true } else { remoteCollectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        if position == .left { remoteCollectionView.isUserInteractionEnabled = true } else { remoteCollectionView.isUserInteractionEnabled = false }
    }
}
