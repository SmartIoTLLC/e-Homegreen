//
//  MacrosViewController.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/20/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

class MacrosViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addNewButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var macroList = [Macro]()
    var filterScrollView = FilterPullDown()

    
//    @IBOutlet weak var fullScreenBtn: UIButton!
//    @IBAction func fullScreenBtn(_ sender: UIButton) {
//      //  sender.switchFullscreen()
//
//    }
   
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    let cellId = "MacrosCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let macroList = DatabaseMacrosController.sharedInstance.fetchAllMacrosFromCD() {
            self.macroList = macroList
        }
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        
       // changeFullscreenImage(fullscreenButton: fullScreenBtn)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setScrollViewBottomOffset(scrollView: &filterScrollView)
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: filterScrollView)
    }
    
    override func nameAndId(_ name: String, id: String) {
        filterScrollView.setButtonTitle(name, id: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addNewMacroVC = segue.destination as? AddNewMacroViewController {
            addNewMacroVC.macroDelegate = self as SuccessfullyAddedMacroDelegate
        }
    }
    
    func reloadCollectionView() {
        if let macroList = DatabaseMacrosController.sharedInstance.fetchAllMacrosFromCD() {
            self.macroList = macroList
            collectionView.reloadData()
        }
    }
    
    @IBAction func addNewButton_Action(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addNewMacroPopUp", sender: nil)
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
        
        //Scroll  VIew
        filterScrollView.delegate = self
        view.addSubview(filterScrollView)
        updateConstraints(item: filterScrollView)
        filterScrollView.setItem(self.view)
        
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
            cell.layer.backgroundColor = UIColor.blue.withAlphaComponent(0.400000005960464).cgColor
            //cell.isOpaque = false
            //cell.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_macro"))
            
            if macroList.count != 0 {
                cell.nameLabel.text = macroList[indexPath.row].name
                cell.logoImageView.image = UIImage(named: macroList[indexPath.row].negative_image!)
                cell.startButton.setTitle("Start", for: UIControlState())
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (macroList.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
}
extension MacrosViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { collectionView.isUserInteractionEnabled = true } else { collectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { collectionView.isUserInteractionEnabled = true } else { collectionView.isUserInteractionEnabled = false }
    }
}
extension MacrosViewController: SuccessfullyAddedMacroDelegate {
    func refreshMacroVC() {
        reloadCollectionView()
    }
}
extension MacrosViewController: FilterPullDownDelegate {
    
    func filterParametars(_ filterItem: FilterItem) {
        //DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.macros) // Saves filter to database for later
    
    }
    
    func saveDefaultFilter() {
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}


























