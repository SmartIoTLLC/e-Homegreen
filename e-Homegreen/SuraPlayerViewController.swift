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
    
    var reciter: Reciter!
    var surasList = [Sura]()
    var availableSurasList = [Sura]()
    var currentSura: Sura!
    
    var player: AVPlayer?
    var suraIsPlaying: Bool = false
    
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

        updateViews()
        fetchSuraInfo()
        setupSuraPlayerView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSura()
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? SuraCell {
            
            cell.sura = availableSurasList[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        suraIsPlaying = false
        currentSura   = availableSurasList[indexPath.row]
        playSura()
    }
}

// MARK: - View setup
extension SuraPlayerViewController {
    fileprivate func updateViews() {
        tableView.register(UINib(nibName: String(describing: SuraCell.self), bundle: nil), forCellReuseIdentifier: cellId)
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.backgroundColor = .clear
        tableView.separatorInset  = .zero
        
        navigationItem.title      = "Suras"
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
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
}

// MARK: - Logic
extension SuraPlayerViewController {
    func pauseSura() {
        player?.pause()
    }
    
    func stopSura() {
        player?.pause()
        suraIsPlaying = false
    }
    
    func playSura() {
        suraTitle.text = currentSura.name
        
        if !suraIsPlaying {
            if let server = reciter.server {
                if let id = currentSura.id {
                    let urlString = server + "/" + formattedSuraID(id: id) + ".mp3"
                    print("URL: ", urlString)
                    if let url = URL(string: urlString) {
                        player = AVPlayer(url: url)
                        player?.volume = 1.0
                        player?.play()
                        suraIsPlaying  = true
                    }
                }
            }
            
        } else {
            player?.play()
        }
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
                                name    : sura["name"] as! String
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
                for sura in surasList {
                    if Int16(sura.id!) == suraId {
                        if let sura = surasList.filter( { Int16($0.id!) == suraId } ).first {
                            availableSurasList.append(sura)
                        }
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    func formattedSuraID(id: NSNumber) -> String {
        if String(describing: id).count == 1 { return "00" + String(describing: id) }
        if String(describing: id).count == 2 { return "0" + String(describing: id) }
        return String(describing: id)
    }
}
