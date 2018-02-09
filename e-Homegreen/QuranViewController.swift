//
//  QuranViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class QuranViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    let cellId   = "reciterCell"
    var reciters = [Reciter]()
    var selectedReciter: Reciter?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreenButton(_ sender: UIButton) {
        sender.switchFullscreen()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViews()
        fetchReciters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSuraPlayer" {
            if let destVC: SuraPlayerViewController = segue.destination as? SuraPlayerViewController {
                destVC.reciter = selectedReciter                
            }
        }
    }

}

// MARK: - Table View Data Source & Delegate
extension QuranViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(at: indexPath, tableView)
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
        didSelectReciter(at: indexPath)
    }
    
}

// MARK: - View setup
extension QuranViewController {
    
    fileprivate func getCell(at indexPath: IndexPath, _ tableView: UITableView) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? ReciterCell {
            
            cell.reciter = reciters[indexPath.row]
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    fileprivate func updateViews() {
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: String(describing: ReciterCell.self), bundle: nil), forCellReuseIdentifier: cellId)
        
        tableView.backgroundColor = .clear
        tableView.separatorInset  = .zero
                
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        navigationItem.titleView  = titleView
        titleView.setTitle("Reciters")
    }
}

// MARK: - Logic
extension QuranViewController {
    fileprivate func fetchReciters() {
        do {
            if let file = Bundle.main.url(forResource: "reciters", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let reciters = json as? [String:[[String:Any]]] {
                    if let objects = reciters["reciters"] {
                        for object in objects {
                            
                            if let moc = context {
                                let reciter = Reciter(
                                    context : moc,
                                    id      : object["id"] as! String,
                                    name    : object["name"] as! String,
                                    server  : object["Server"] as! String,
                                    rewaya  : object["rewaya"] as! String,
                                    count   : object["count"] as! String,
                                    letter  : object["letter"] as! String,
                                    suras   : object["suras"] as! String
                                )
                                self.reciters.append(reciter)
                            }
                            
                        }
                        tableView.reloadData()
                    }
                }
            }
        } catch let error as NSError {
            print("Error parsing radio stations: ", error, error.userInfo)
        }
        
    }
    
    fileprivate func didSelectReciter(at indexPath: IndexPath) {
        selectedReciter = reciters[indexPath.row]
        self.performSegue(withIdentifier: "toSuraPlayer", sender: self)
    }
}

extension QuranViewController: SWRevealViewControllerDelegate {
    
}
