//
//  RemoteViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

private struct LocalConstants {
    static let sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 25, left: 0, bottom: 20, right: 0)
}

class RemoteViewController: PopoverVC {
    
    fileprivate var remotesList: [Remote] = []
    fileprivate var selectedRemote: Remote?
    
    fileprivate var location: [Location] = []
    var pickedLocation: Location?
    
    fileprivate var scrollView = FilterPullDown()
    fileprivate let headerTitleSubtitleView = NavigationTitleView(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    fileprivate var filterParametar: FilterItem = Filter.sharedInstance.returnFilter(forTab: .Remote)
    fileprivate var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    fileprivate let remoteCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIButton!
    @IBAction func addButton(_ sender: UIButton) {
        addTapped()
    }
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBAction func fullScreenButton(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        collectionViewCellSize = calculateCellSize(completion: { remoteCollectionView.reloadData() })
        
        addBackgroundView()
        addTitleView()
        addCollectionView()
        addScrollView()
        
        setupConstraints()
        
        addObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeFullscreenImage(fullscreenButton: fullScreenButton)
        toggleAddButton()
        loadRemotesOnStart(from: pickedLocation)        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
    }
    
    override func nameAndId(_ name: String, id: String) {
        scrollView.setButtonTitle(name, id: id)
    }
    
    // MARK: - Setup views
    private func addBackgroundView() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
    }
    
    private func addTitleView() {
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
        
        headerTitleSubtitleView.setTitleAndSubtitle("Remote", subtitle: "All All All")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        navigationItem.titleView = headerTitleSubtitleView
    }
    
    private func addScrollView() {
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(view)
        
        scrollView.setFilterItem(Menu.remote)
    }
    
    private func addCollectionView() {
        remoteCollectionView.backgroundColor = .clear
        remoteCollectionView.dataSource = self
        remoteCollectionView.delegate   = self
        remoteCollectionView.contentInset = .zero
        remoteCollectionView.register(RemoteCollectionViewCell.self, forCellWithReuseIdentifier: RemoteCollectionViewCell.reuseIdentifier)
        
        view.addSubview(remoteCollectionView)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        remoteCollectionView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func toggleAddButton() {
        addButton.isEnabled = (filterParametar.location != "All") ? true : false
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
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerRemotes), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRemotes), name: Notification.Name(rawValue: NotificationKey.RefreshRemotes), object: nil)
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

    // MARK: - Logic
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
        if remotesList.count != 0 {
            remotesList.sort(by: { (one, two) -> Bool in one.name! < two.name! })
        }
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
        (DatabaseUserController.shared.loggedUserOrAdmin() != nil) ? showAddRemoteVC(filter: filterParametar, location: pickedLocation!) : view.makeToast(message: "No user database selected.")
    }
    
    fileprivate func didSelectRemote(at indexPath: IndexPath) {
        selectedRemote = remotesList[indexPath.row]
        performSegue(withIdentifier: "toSingleRemote", sender: self)
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RemoteCollectionViewCell.reuseIdentifier, for: indexPath) as? RemoteCollectionViewCell {
            cell.setCell(with: remotesList[indexPath.item])
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}

// MARK: - UICollectionView Delegate
extension RemoteViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectRemote(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return LocalConstants.sectionInsets
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
        remoteCollectionView.isUserInteractionEnabled = (position == .left) ? true : false
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        remoteCollectionView.isUserInteractionEnabled = (position == .left) ? true : false
    }
}
