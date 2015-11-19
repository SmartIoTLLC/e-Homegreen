//
//  SidePanelViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@objc
protocol SidePanelViewControllerDelegate {
  func menuItemSelected(menuItem: MenuItem)
}

class SidePanelViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    var delegate: SidePanelViewControllerDelegate?
    private var sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var menuItems: Array<MenuItem>!
    var menuList:[NSString] = []
  
    struct CollectionView {
        struct CellIdentifiers {
        static let MenuCell = "MenuItemCell"
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        //(red: 47/255, green: 47/255, blue: 47/255, alpha: 1)
        view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        menuList.removeAll(keepCapacity: false)
    }

    
    //pragma mark - LXReorderableCollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        let pom = menuItems[fromIndexPath.item]
        menuItems.removeAtIndex(fromIndexPath.item)
        menuItems.insert(pom, atIndex: toIndexPath.item)
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
//        var pom = menuItems[fromIndexPath.item]
        if indexPath.item == (menuItems.count - 1) {
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if toIndexPath.item == (menuItems.count - 1) {
            return false
        }
        return true
    }
    
    //pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        print("did begin drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        print("did end drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        print("will begin drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        print("will end drag")
    }

    
    override func viewWillDisappear(animated: Bool) {
        for items in menuItems{
            menuList.append(items.title!)
        }
        NSUserDefaults.standardUserDefaults().setObject(menuList, forKey: "menu")
        NSUserDefaults.standardUserDefaults().synchronize()
//        let menuData = NSKeyedArchiver.archivedDataWithRootObject(menuList)
//        NSUserDefaults.standardUserDefaults().setObject(menuList, forKey: "menu")
    }
    
//    override func viewWillAppear(animated: Bool) {
//        let menuData = NSUserDefaults.standardUserDefaults().objectForKey("menu") as? NSData
//        if let menuData = menuData {
//            let menuArray = NSKeyedUnarchiver.unarchiveObjectWithData(menuData) as? [Menu]
//            
//            if let placesArray = menuArray {
//                menuCollectionView.reloadData()
//            }
//            
//        }
//    }
    
  
}

extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.cellForItemAtIndexPath(indexPath)?.collapseInReturnToNormalMenu(1)
        let selectedMenuItem = menuItems[indexPath.row]
        NSUserDefaults.standardUserDefaults().setObject(selectedMenuItem.title, forKey: "firstItem")
        NSUserDefaults.standardUserDefaults().synchronize()
        delegate?.menuItemSelected(selectedMenuItem)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 88, height: 88)
    }
}

extension SidePanelViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionView.CellIdentifiers.MenuCell, forIndexPath: indexPath) as! MenuItemCell
        if cell.gradientLayer == nil {
            let gradient:CAGradientLayer = CAGradientLayer()
            gradient.frame = cell.bounds
            gradient.colors = [UIColor(red: 52/255, green: 52/255, blue: 49/255, alpha: 1).CGColor, UIColor(red: 28/255, green: 28/255, blue: 26/255, alpha: 1).CGColor]
            gradient.locations = [0.0, 1.0]
            cell.gradientLayer = gradient
            cell.layer.insertSublayer(gradient, atIndex: 0)
        }
        cell.configureForMenu(menuItems[indexPath.row])
        cell.layer.cornerRadius = 5
        return cell
    }
}
class MenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemName: UILabel!
    var gradientLayer: CAGradientLayer?
    
    func configureForMenu (menuItem:MenuItem) {
        menuItemImageView.image = menuItem.image
        menuItemName.text = menuItem.title
    }
    
}