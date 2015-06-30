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
  func menuItemSelected(menuItem: Menu)
}

class SidePanelViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    var delegate: SidePanelViewControllerDelegate?
    private var sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var menuItems: Array<Menu>!
    var menuList:[NSString] = []
  
    struct CollectionView {
        struct CellIdentifiers {
        static let MenuCell = "MenuItemCell"
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
    }

    
    //pragma mark - LXReorderableCollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        var pom = menuItems[fromIndexPath.item]
        menuItems.removeAtIndex(fromIndexPath.item)
        menuItems.insert(pom, atIndex: toIndexPath.item)
        
    }
    
    func collectionView(collectionView: UICollectionView!, canMoveItemAtIndexPath indexPath: NSIndexPath!) -> Bool {
//        var pom = menuItems[fromIndexPath.item]
        if indexPath.item == 11{
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if toIndexPath.item == 11 {
            return false
        }
        return true
    }
    
    //pragma mark - LXReorderableCollectionViewDelegateFlowLayout methods
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        println("did begin drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        println("did end drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        println("will begin drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        println("will end drag")
    }

    
    override func viewWillDisappear(animated: Bool) {
        for items in menuItems{
            menuList.append(items.title)
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
        let selectedMenuItem = menuItems[indexPath.row]
        delegate?.menuItemSelected(selectedMenuItem)
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 120, height: 120)
    }
}

extension SidePanelViewController: UICollectionViewDataSource {

//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return 1
//    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Menu.allMenuItems().count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionView.CellIdentifiers.MenuCell, forIndexPath: indexPath) as! MenuItemCell
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, 120, 120)
        gradient.colors = [UIColor.grayColor().colorWithAlphaComponent(0.95).CGColor, UIColor.grayColor().colorWithAlphaComponent(0.1).CGColor]
        cell.layer.insertSublayer(gradient, atIndex: 0)
        cell.configureForMenu(menuItems[indexPath.row])
//        cell.configureForMenu(Menu.allMenuItems()[indexPath.row])
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}
class MenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemName: UILabel!
    
    func configureForMenu (menuItem:Menu) {
        menuItemImageView.image = menuItem.image
        menuItemName.text = menuItem.title
    }
    
}