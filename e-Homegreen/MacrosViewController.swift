//
//  MacrosViewController.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/20/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

class MacrosViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIBarButtonItem!
    @IBOutlet weak var addNewButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    let cellId = "MacrosCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetch all macros from core data
        //call a func collectionViewCell(type: macro.type, name: macro.name, image: macro.image)
        
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
    }
    
    @IBAction func addNewButton_Action(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addNewMacroPopUp", sender: nil)
    }
    
    @IBAction func fullScreenButton_Action(_ sender: UIBarButtonItem) {
        
    }
    
}

extension MacrosViewController {
    
    fileprivate func updateViews() {
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        //Background image
        backgroundImage.image = #imageLiteral(resourceName: "Background")
        
        //Collection View
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MacrosCell.self, forCellWithReuseIdentifier: cellId)
        
        
        //Navigation controller
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        titleView.setTitle("Macros")
        navigationItem.titleView = titleView
    }
    
    
}

extension MacrosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? MacrosCell {
            
            cell.cellHeight = 150
            cell.cellWidth = 180
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 0.5
            cell.layer.cornerRadius = 12
            cell.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_macro"))
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
    
}




extension MacrosViewController: SWRevealViewControllerDelegate {
    
}


























