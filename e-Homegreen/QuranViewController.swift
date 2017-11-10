//
//  QuranViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class QuranViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreenButton(_ sender: UIButton) {
        sender.switchFullscreen()
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    let cellId = "reciterCell"
    var reciters = [Reciter]()
    var selectedReciter: Reciter?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: ReciterCell.self), bundle: nil), forCellReuseIdentifier: cellId)
        
        updateViews()
        fetchReciters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    func updateViews() {
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets.zero
        navigationItem.title = "Reciters"
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ReciterCell {
            
            cell.reciter = reciters[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reciters.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReciter = reciters[indexPath.row]
        self.performSegue(withIdentifier: "toSuraPlayer", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuraPlayer" {
            if let destVC: SuraPlayerViewController = segue.destination as? SuraPlayerViewController {
                destVC.reciter = selectedReciter
            }
        }
    }
    
    func fetchReciters() {
        do {
            if let file = Bundle.main.url(forResource: "reciters", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let reciters = json as? [String:[[String:Any]]] {
                    if let objects = reciters["reciters"] {
                        for object in objects {
                            print(object)
                            let reciter = Reciter(context: context!, id: object["id"] as! String, name: object["name"] as! String, server: object["Server"] as! String, rewaya: object["rewaya"] as! String, count: object["count"] as! String, letter: object["letter"] as! String, suras: object["suras"] as! String)
                            self.reciters.append(reciter)
                        }
                        tableView.reloadData()
                    }
                }
            }
        } catch let error as NSError {
            print("Error parsing radio stations: ", error, error.userInfo)
        }
        
    }

}

extension QuranViewController: SWRevealViewControllerDelegate {
    
}
