//
//  SuraPlayerViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//
import UIKit
import AVFoundation

private struct LocalConstants {
    static let radioMenuSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 120)
}

class SuraPlayerViewController: UIViewController {
    
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    private let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var reciter: Reciter!
    fileprivate var surasList = [Sura]()
    fileprivate var availableSurasList = [Sura]()
    fileprivate var currentSura: Sura!
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    fileprivate let audioPlayerView: AudioPlayerBar = AudioPlayerBar()
    fileprivate let tableView: UITableView = UITableView()
    
    private var fullscreenButton: UIButton {
        return self.makeFullscreenButton()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFullscreenBarButton()
        addBackgroundImageView()
        addTitleView()
        addTableView()
        setupSuraPlayerView()
        
        setupConstraints()
        
        addObservers()
        fetchSuraInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    // MARK: - Setup views
    private func addFullscreenBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: fullscreenButton)
    }
    
    private func addBackgroundImageView() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
    }
    
    private func addTitleView() {
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
        navigationItem.titleView  = titleView
        titleView.setTitle(reciter.name!)
    }
    
    private func addTableView() {
        tableView.register(QuranTableViewCell.self, forCellReuseIdentifier: QuranTableViewCell.reuseIdentifier)
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.backgroundColor = .clear
        tableView.separatorInset  = .zero
        
        view.addSubview(tableView)
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
    
    fileprivate func setupSuraPlayerView() {
        audioPlayerView.setPauseAction {
            self.pauseSura()
        }
        audioPlayerView.setPlayAction {
            self.playSura()
        }
        audioPlayerView.setStopAction {
            self.stopSura()
        }
        
        audioPlayerView.setTitle(with: "Suras")
        
        view.addSubview(audioPlayerView)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMediaItem(notification:)), name: .nowPlayingItemChanged, object: nil)
    }
    
    // MARK: - Logic
    @objc func handleNewMediaItem(notification: Notification) {
        if let title = notification.object as? String {
            audioPlayerView.setTitle(with: title)
            
            if let currentSura = surasList.first(where: { (sura) -> Bool in
                sura.name == title
            }) {
                self.currentSura = currentSura
            }
        }
    }
    
    @objc func pauseSura() {
        AudioPlayer.sharedInstance.pauseAudio()
    }
    
    @objc func stopSura() {
        AudioPlayer.sharedInstance.stopAudio()
    }
    
    @objc func playSura() {
        guard currentSura != nil else { return }
        if let index = availableSurasList.index(of: currentSura) {
            AudioPlayer.sharedInstance.loadPlaylist(suras: availableSurasList, currentIndex: index)
        }
        audioPlayerView.setTitle(with: currentSura.name)
    }
    
    fileprivate func fetchSuraInfo() {
        do {
            if let file = Bundle.main.url(forResource: "sura_english", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let suras = json as? [[String:Any]] {
                    for sura in suras {
                        if let moc = managedContext {
                            let object = Sura(
                                context : moc,
                                id      : sura["id"] as! Int16,
                                name    : sura["name"] as! String,
                                reciter : reciter
                            )
                            surasList.append(object)
                        }
                    }
                    getAvailableSuras()
                }
            }
        } catch let error as NSError {
            print("Error loading suras json file: ", error, error.userInfo)
        }
    }
    
    func getAvailableSuras() {
        if let ids = reciter?.getRecitersSurasAsInt() {
            for suraId in ids {
                surasList.forEach({ (sura) in
                    if sura.id!.int16Value == suraId {
                        if let sura = surasList.filter( { $0.id!.int16Value == suraId } ).first {
                            availableSurasList.append(sura)
                        }
                    }
                })
            }
            tableView.reloadData()
        }
    }
    
    fileprivate func didSelectSura(at indexPath: IndexPath) {
        currentSura   = availableSurasList[indexPath.row]
        playSura()
    }
}

// MARK: - Table View Data Source & Delegate
extension SuraPlayerViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableSurasList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: QuranTableViewCell.reuseIdentifier, for: indexPath) as? QuranTableViewCell {
            cell.setCell(with: availableSurasList[indexPath.row])
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectSura(at: indexPath)
    }
    
}
