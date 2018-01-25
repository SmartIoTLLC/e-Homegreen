//
//  RadioViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class RadioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellId = "stationCell"
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var radioStations = [Radio]()
    var currentStation: Radio!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreen(_ sender: UIButton) {
        sender.switchFullscreen()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var radioBar: UIView!
    
    @IBOutlet weak var radioTitle: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        changeFullscreenImage(fullscreenButton: fullscreenButton)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        fetchRadioStations()
        setupRadioPlayerView()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopRadio()
    }

}

// MARK: - Table View Data Source
extension RadioViewController {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return radioStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(at: indexPath, tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
}

// MARK: - Table View Delegate
extension RadioViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectStation(at: indexPath)
    }
}

// MARK: - Logic
extension RadioViewController {
    
    fileprivate func fetchRadioStations() {
        
        do {
            if let file = Bundle.main.url(forResource: "radio_station", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let objects = json as? [[String: Any]] {
                    for object in objects {
                        if let moc = context {
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
            }
        } catch let error as NSError {
            print("Error parsing radio stations: ", error, error.userInfo)
        }
        
    }
    
    @objc fileprivate func playRadio() {
        radioTitle.text = currentStation.stationName
        if let urlString = currentStation.url {
            if let url = URL(string: urlString) {
                AudioPlayer.sharedInstance.playAudioFrom(url: url)
            }
        }
    }
    
    @objc fileprivate func pauseRadio() {
        AudioPlayer.sharedInstance.pauseAudio()
    }
    
    @objc fileprivate func stopRadio() {
        AudioPlayer.sharedInstance.stopAudio()
    }
    
    fileprivate func didSelectStation(at indexPath: IndexPath) {
        currentStation = radioStations[indexPath.row]
        playRadio()
    }
}

// MARK: - Setup views
extension RadioViewController {
    
    fileprivate func getCell(at indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? StationCell {
            
            cell.station = radioStations[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    fileprivate func setupRadioPlayerView() {
        radioBar.backgroundColor = UIColor(cgColor: Colors.DarkGray)
        radioTitle.textColor     = UIColor.white
        radioTitle.font          = .tahoma(size: 15)
        
        pauseButton.setImage(#imageLiteral(resourceName: "audio_pause"), for: UIControlState())
        pauseButton.imageView?.contentMode = .scaleAspectFit
        pauseButton.backgroundColor        = UIColor(cgColor: Colors.DarkGrayColor)
        pauseButton.layer.cornerRadius     = 3
        pauseButton.addTarget(self, action: #selector(pauseRadio), for: .touchUpInside)
        
        stopButton.setImage(#imageLiteral(resourceName: "audio_stop"), for: UIControlState())
        stopButton.backgroundColor        = UIColor.darkGray
        stopButton.layer.cornerRadius     = 3
        stopButton.imageView?.contentMode = .scaleAspectFit
        stopButton.addTarget(self, action: #selector(stopRadio), for: .touchUpInside)
        
        playButton.setImage(#imageLiteral(resourceName: "audio_play"), for: UIControlState())
        playButton.backgroundColor        = UIColor.darkGray
        playButton.layer.cornerRadius     = 3
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.addTarget(self, action: #selector(playRadio), for: .touchUpInside)
    }
    
    fileprivate func updateViews() {
        tableView.delegate   = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: String(describing: StationCell.self), bundle: nil), forCellReuseIdentifier: cellId)
        
        tableView.backgroundColor = .clear
        tableView.separatorInset  = .zero
        
        navigationItem.title = "Radio"
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        
        navigationItem.titleView = titleView
        titleView.setTitle("Radio")
    }
}

// MARK: - SWRevealVC Delegate
extension RadioViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { tableView.isUserInteractionEnabled = true } else { tableView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { tableView.isUserInteractionEnabled = true } else { tableView.isUserInteractionEnabled = false }
    }
    
}
