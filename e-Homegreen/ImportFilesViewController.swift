//
//  ImportFilesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/23/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

protocol ImportFilesDelegate{
    func backURL(_ strText: String)
}

class ImportFilesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var listOfJson:[String] = []
    var delegate : ImportFilesDelegate?
    var indexSelect:Int = -1
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableOfFiles: UITableView!
    @IBAction func btnImport(_ sender: AnyObject) {
        importTapped()
    }
    @IBAction func btnCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    init () {
        super.init(nibName: "ImportFilesViewController", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
}

// MARK: - TableView Data Source & Delegate
extension ImportFilesViewController {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = listOfJson[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfJson.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexSelect = indexPath.row
    }
}

// MARK: - Logic & View setup
extension ImportFilesViewController {
    fileprivate func importTapped() {
        if indexSelect != -1 {
            delegate?.backURL(listOfJson[indexSelect])
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func enumerateDirectory() -> [String] {
        if let dirs = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true) as [String]? {
            
            do { return try FileManager.default.contentsOfDirectory(atPath: dirs[0])
            } catch {}
            
            return []
        }
    }
    
    func setupViews() {
        self.tableOfFiles.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let isFileInDir = enumerateDirectory()
        for item in isFileInDir {
            if "json" == URL(string: item.replacingOccurrences(of: " ", with: ""))?.pathExtension { listOfJson.append(item) }
        }
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        backView.layer.cornerRadius = 10
    }
}

extension ImportFilesViewController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.05, scaleOneY: 1.05, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)        
    }
}



extension ImportFilesViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}

extension UIViewController {
    func showImportFiles() -> ImportFilesViewController {
        let ad = ImportFilesViewController()
        self.present(ad, animated: true, completion: nil)
        return ad
    }
}
