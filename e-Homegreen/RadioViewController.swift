//
//  RadioViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class RadioViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellId = "stationCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    var radioStations = [Radio]()
    var currentStation: Radio!
    var radioIsPlaying: Bool = false
    
    var player: AVPlayer?
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreen(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var radioBar: UIView!
    
    @IBOutlet weak var radioTitle: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            //self.revealViewController().panGestureRecognizer().delegate = self
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            
            revealViewController().rearViewRevealWidth = 200
        }
        
        changeFullScreeenImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: String(describing: StationCell.self), bundle: nil), forCellReuseIdentifier: cellId)
        
        updateViews()
        fetchRadioStations()
        setupRadioPlayerView()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        radioIsPlaying = false
        player?.pause()
    }
    
    func updateViews() {
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets.zero
        navigationItem.title = "Radio"
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullscreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullscreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return radioStations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? StationCell {
            
            cell.station = radioStations[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        radioIsPlaying = false
        currentStation = radioStations[indexPath.row]
        playRadio()
    }
    
    func setupRadioPlayerView() {
        radioBar.backgroundColor = UIColor(cgColor: Colors.DarkGray)
        radioTitle.textColor = UIColor.white
        radioTitle.font = UIFont(name: "Tahoma", size: 17)
        
        pauseButton.setImage(#imageLiteral(resourceName: "audio_pause"), for: UIControlState())
        pauseButton.imageView?.contentMode = .scaleAspectFit
        pauseButton.backgroundColor = UIColor(cgColor: Colors.DarkGrayColor)
        pauseButton.layer.cornerRadius = 3
        pauseButton.addTarget(self, action: #selector(pauseRadio), for: .touchUpInside)

        stopButton.setImage(#imageLiteral(resourceName: "audio_stop"), for: UIControlState())
        stopButton.backgroundColor = UIColor.darkGray
        stopButton.layer.cornerRadius = 3
        stopButton.imageView?.contentMode = .scaleAspectFit
        stopButton.addTarget(self, action: #selector(stopRadio), for: .touchUpInside)

        playButton.setImage(#imageLiteral(resourceName: "audio_play"), for: UIControlState())
        playButton.backgroundColor = UIColor.darkGray
        playButton.layer.cornerRadius = 3
        playButton.imageView?.contentMode = .scaleAspectFit
        playButton.addTarget(self, action: #selector(playRadio), for: .touchUpInside)
        
        radioBar.addSubview(radioTitle)
        radioBar.addSubview(pauseButton)
        radioBar.addSubview(stopButton)
        radioBar.addSubview(playButton)
    }

    func fetchRadioStations() {
        
        do {
            if let file = Bundle.main.url(forResource: "radio_station", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let objects = json as? [[String: Any]] {
                    for object in objects {
                        let station = Radio(context: context!, stationName: object["stationName"] as! String, area: object["area"] as! String, city: object["city"] as! String, genre: object["genre"] as! String, url: object["url"] as! String, isWorking: object["isWorking"] as! Bool, radioDescription: object["description"] as! String)
                        radioStations.append(station)
                    }
                    self.tableView.reloadData()
                }
            }
        } catch let error as NSError {
            print("Error parsing radio stations: ", error, error.userInfo)
        }
        
    }
    
    func playRadio() {
        radioTitle.text = currentStation.stationName
        
        if !radioIsPlaying {
            if let urlString = currentStation.url {
                if let url = URL(string: urlString) {
                    self.player = AVPlayer(url: url)
                    self.player?.volume = 1.0
                    self.player?.play()
                    self.radioIsPlaying = true
                }
            }
        } else {
            player?.play()
        }
    }
    
    func pauseRadio() {
        player?.pause()
    }
    
    func stopRadio() {
        player?.pause()
        radioIsPlaying = false
    }

}

extension RadioViewController: SWRevealViewControllerDelegate{
    
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            tableView.isUserInteractionEnabled = true
        } else {
            tableView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            tableView.isUserInteractionEnabled = true
        } else {
            tableView.isUserInteractionEnabled = false
        }
    }
    
}
