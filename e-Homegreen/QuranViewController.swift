//
//  QuranViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/15/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

struct QuranReciterKeys {
    static let id: String = "id"
    static let name: String = "name"
    static let server: String = "Server"
    static let rewaya: String = "rewaya"
    static let count: String = "count"
    static let letter: String = "letter"
    static let suras: String = "suras"
}

class QuranViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    private let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    fileprivate var reciters = [Reciter]()
    fileprivate var selectedReciter: Reciter?
    
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    fileprivate let tableView: UITableView = UITableView()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreenButton(_ sender: UIButton) {
        sender.switchFullscreen()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
        addBackgroundImageView()
        addTitleView()
        addTableView()
        
        setupConstraints()
        
        fetchReciters()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    private func addBackgroundImageView() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
    }
    
    private func addTitleView() {
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        navigationItem.titleView  = titleView
        titleView.setTitle("Reciters")
    }
    
    private func addTableView() {
        tableView.register(QuranTableViewCell.self, forCellReuseIdentifier: QuranTableViewCell.reuseIdentifier)
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorInset  = .zero
        
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Navigation
    fileprivate func goToSuraPlayerViewController() {
        if let vc = UIStoryboard(name: "Quran", bundle: nil).instantiateViewController(withIdentifier: "SuraPlayer") as? SuraPlayerViewController {
            vc.reciter = selectedReciter
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

// MARK: - Table View Data Source & Delegate
extension QuranViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: QuranTableViewCell.reuseIdentifier, for: indexPath) as? QuranTableViewCell {
            cell.setCell(with: reciters[indexPath.row])
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
        didSelectReciter(at: indexPath)
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
                                    id      : object[QuranReciterKeys.id] as! String,
                                    name    : object[QuranReciterKeys.name] as! String,
                                    server  : object[QuranReciterKeys.server] as! String,
                                    rewaya  : object[QuranReciterKeys.rewaya] as! String,
                                    count   : object[QuranReciterKeys.count] as! String,
                                    letter  : object[QuranReciterKeys.letter] as! String,
                                    suras   : object[QuranReciterKeys.suras] as! String
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
        goToSuraPlayerViewController()
    }
}

extension QuranViewController: SWRevealViewControllerDelegate {
    
}
