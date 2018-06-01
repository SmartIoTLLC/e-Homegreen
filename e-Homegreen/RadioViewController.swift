//
//  RadioViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import SnapKit

private struct LocalConstants {
    static let radioMenuSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
    static let cellHeight: CGFloat = 132
}

class RadioViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    
    private let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    fileprivate let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    fileprivate var radioStations = [Radio]()
    fileprivate var currentStation: Radio!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreen(_ sender: UIButton) {
        sender.switchFullscreen()
    }
    
    fileprivate let tableView: UITableView = UITableView()
    fileprivate let audioPlayerView: AudioPlayerBar = AudioPlayerBar()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        addObservers()
        
        addBackgroundView()
        addTitleView()
        addTableView()
        addRadioView()
        
        setupConstraints()
        
        fetchRadioStations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    // MARK: - Setup views
    private func addBackgroundView() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
    }
    
    private func addTableView() {
        tableView.delegate   = self
        tableView.dataSource = self
        
        tableView.register(RadioStationTableViewCell.self, forCellReuseIdentifier: RadioStationTableViewCell.reuseIdentifier)
        
        tableView.backgroundColor = .clear
        tableView.separatorInset  = .zero
        tableView.separatorColor  = UIColor.white.withAlphaComponent(0.4)
        
        view.addSubview(tableView)
    }
    
    private func addRadioView() {
        audioPlayerView.setPauseAction {
            self.pauseRadio()
        }
        audioPlayerView.setPlayAction {
            self.playRadio()
        }
        audioPlayerView.setStopAction {
            self.stopRadio()
        }
        
        audioPlayerView.setTitle(with: "Radio stations")
        
        view.addSubview(audioPlayerView)
    }
    
    private func addTitleView() {
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)

        navigationItem.titleView = titleView
        titleView.setTitle("Radio")
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMediaItem(notification:)), name: .nowPlayingItemChanged, object: nil)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        audioPlayerView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.radioMenuSize.height)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(audioPlayerView.snp.top)
        }
    }
    
    // MARK: - Logic
    @objc func handleNewMediaItem(notification: Notification) {
        if let title = notification.object as? String {
            audioPlayerView.setTitle(with: title)
            
            if let currentStation = radioStations.first(where: { (radio) -> Bool in
                radio.stationName == title
            }) {
                self.currentStation = currentStation
            }
        }
    }
    
    private func fetchRadioStations() {
        
        do {
            if let file = Bundle.main.url(forResource: "radio_station", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let objects = json as? [[String: Any]] {
                    for object in objects {
                        if let moc = managedContext {
                            let station = Radio(
                                context: moc,
                                stationName: object["stationName"] as! String,
                                area: object["area"] as! String,
                                city: object["city"] as! String,
                                genre: object["genre"] as! String,
                                url: object["url"] as! String,
                                isWorking: object["isWorking"] as! Bool,
                                radioDescription: object["description"] as! String
                            )
                            radioStations.append(station)
                        }
                    }
                    tableView.reloadData()
                }
            } else { view.makeToast(message: "Failed loading radio stations.") }
        } catch let error as NSError {
            view.makeToast(message: "Failed loading radio stations.")
            print("Error parsing radio stations: ", error, error.userInfo)
        }
        
    }
    
    @objc fileprivate func playRadio() {
        guard currentStation != nil else { return }
        if let index = radioStations.index(of: currentStation) {
            AudioPlayer.sharedInstance.loadPlaylist(stations: radioStations, currentIndex: index)
        }
        audioPlayerView.setTitle(with: currentStation.stationName)
    }
    
    private func pauseRadio() {
        AudioPlayer.sharedInstance.pauseAudio()
    }
    
    private func stopRadio() {
        AudioPlayer.sharedInstance.stopAudio()
    }
    
    fileprivate func didSelectStation(at indexPath: IndexPath) {
        currentStation = radioStations[indexPath.row]
        playRadio()
    }
}

// MARK: - TableView Data Source & Delegate
extension RadioViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return radioStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: RadioStationTableViewCell.reuseIdentifier, for: indexPath) as? RadioStationTableViewCell {
            cell.setCell(with: radioStations[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LocalConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectStation(at: indexPath)
    }
}

// MARK: - SWRevealVC Delegate
extension RadioViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition) {
        tableView.isUserInteractionEnabled = (position == .left) ? true : false
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition) {
        tableView.isUserInteractionEnabled = (position == .left) ? true : false
    }
    
}
