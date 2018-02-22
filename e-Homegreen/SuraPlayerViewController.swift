//
//  SuraPlayerViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AVFoundation

class SuraPlayerViewController: UIViewController {

    let cellId = "suraCell"
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var reciter: Reciter!
    var surasList = [Sura]()
    var availableSurasList = [Sura]()
    var currentSura: Sura!
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var radioBar: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var suraTitle: UILabel!
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreenButton(_ sender: UIButton) {
        sender.switchFullscreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        updateViews()
        fetchSuraInfo()
        setupSuraPlayerView()
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
        return getCell(at: indexPath, tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectSura(at: indexPath)
    }
    
}

// MARK: - View setup
extension SuraPlayerViewController {
    
    fileprivate func getCell(at indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SuraCell {
            
            cell.sura = availableSurasList[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    fileprivate func updateViews() {
        tableView.register(UINib(nibName: String(describing: SuraCell.self), bundle: nil), forCellReuseIdentifier: cellId)
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.backgroundColor = .clear
        tableView.separatorInset  = .zero
                
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        navigationItem.titleView  = titleView
        titleView.setTitle(reciter.name!)
    }
    
    fileprivate func setupSuraPlayerView() {
        radioBar.backgroundColor = UIColor(cgColor: Colors.DarkGray)
        suraTitle.textColor      = UIColor.white
        suraTitle.font           = .tahoma(size: 15)
        
        pauseButton.setImage(#imageLiteral(resourceName: "audio_pause"), for: UIControlState())
        pauseButton.imageView?.contentMode = .scaleAspectFit
        pauseButton.backgroundColor        = UIColor(cgColor: Colors.DarkGrayColor)
        pauseButton.layer.cornerRadius     = 3
        pauseButton.addTarget(self, action: #selector(pauseSura), for: .touchUpInside)
        
        stopButton.setImage(#imageLiteral(resourceName: "audio_stop"), for: UIControlState())
        stopButton.backgroundColor        = UIColor.darkGray
        stopButton.layer.cornerRadius     = 3
        stopButton.imageView?.contentMode = .scaleAspectFit
        stopButton.addTarget(self, action: #selector(stopSura), for: .touchUpInside)
        
        playButton.setImage(#imageLiteral(resourceName: "audio_play"), for: UIControlState())
        playButton.backgroundColor        = UIColor.darkGray
        playButton.layer.cornerRadius     = 3
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.addTarget(self, action: #selector(playSura), for: .touchUpInside)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewMediaItem(notification:)), name: .nowPlayingItemChanged, object: nil)
    }
}

// MARK: - Logic

extension SuraPlayerViewController {
    func handleNewMediaItem(notification: Notification) {
        if let title = notification.object as? String {
            suraTitle.text = title
        }
    }
    
    func pauseSura() {
        AudioPlayer.sharedInstance.pauseAudio()
    }
    
    func stopSura() {
        AudioPlayer.sharedInstance.stopAudio()
    }
    
    func playSura() {
        guard currentSura != nil else { return }
        if let index = availableSurasList.index(of: currentSura) {
            AudioPlayer.sharedInstance.loadPlaylist(suras: availableSurasList, currentIndex: index)
        }
        suraTitle.text = currentSura.name
    }
    
    func fetchSuraInfo() {
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
                    if Int16(sura.id!) == suraId {
                        if let sura = surasList.filter( { Int16($0.id!) == suraId } ).first {
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
    
    func formattedSuraID(id: NSNumber) -> String {
        if String(describing: id).count == 1 { return "00" + String(describing: id) }
        if String(describing: id).count == 2 { return "0" + String(describing: id) }
        return String(describing: id)
    }
}
