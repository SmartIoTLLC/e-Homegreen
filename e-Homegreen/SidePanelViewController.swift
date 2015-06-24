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

class SidePanelViewController: UIViewController {
  
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
//  @IBOutlet weak var tableView: UITableView!
    var delegate: SidePanelViewControllerDelegate?
    private var sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var menuItems: Array<Menu>!
  
//  struct TableView {
//    struct CellIdentifiers {
//      static let MenuCell = "MenuItemCell"
//    }
//  }
    struct CollectionView {
        struct CellIdentifiers {
        static let MenuCell = "MenuItemCell"
        }
    }
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    tableView.reloadData()
    view.backgroundColor = UIColor.blackColor()
//    tableView.backgroundColor = UIColor.blackColor()
//    tableView.separatorColor = UIColor.blackColor()
  }
  
}

// MARK: Table View Data Source

//extension SidePanelViewController: UITableViewDataSource {
//  
//  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//    return 1
//  }
//  
//  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return menuItems.count
//  }
//  
//  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.MenuCell, forIndexPath: indexPath) as! MenuItemCell
//    cell.configureForMenu(menuItems[indexPath.row])
//    cell.backgroundColor = UIColor.blackColor()
//    return cell
//  }
//  
//}

// Mark: Table View Delegate

//extension SidePanelViewController: UITableViewDelegate {
//
//  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//    // You have to dissable user to click it twice fast, app breaks
//    
//    let selectedMenuItem = menuItems[indexPath.row]
//    delegate?.menuItemSelected(selectedMenuItem)
//  }
//  
//}
extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(myView)
        //        collectionView.cellForItemAtIndexPath(indexPath)?.addSubview(mySecondView)
//        println(" ")
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Menu.allMenuItems().count
//        return 12
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionView.CellIdentifiers.MenuCell, forIndexPath: indexPath) as! MenuItemCell
        //2
        //        let flickrPhoto = photoForIndexPath(indexPath)
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, 120, 120)
//        gradient.colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        gradient.colors = [UIColor.grayColor().colorWithAlphaComponent(0.95).CGColor, UIColor.grayColor().colorWithAlphaComponent(0.1).CGColor]
        cell.layer.insertSublayer(gradient, atIndex: 0)
        //        cell.backgroundColor = UIColor.lightGrayColor()
        //3
        cell.configureForMenu(Menu.allMenuItems()[indexPath.row])
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}
//class MenuItemCell: UITableViewCell {
//  
//  @IBOutlet weak var menuItemImageView: UIImageView!
//  @IBOutlet weak var menuItemName: UILabel!
//  
//  func configureForMenu(menuItem: Menu) {
//    menuItemImageView.image = menuItem.image
//    menuItemName.text = menuItem.title
//  }
//  
//}
class MenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemName: UILabel!
    
    func configureForMenu (menuItem:Menu) {
        menuItemImageView.image = menuItem.image
        menuItemName.text = menuItem.title
    }
    
}