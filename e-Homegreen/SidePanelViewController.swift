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
  @IBOutlet weak var tableView: UITableView!
  var delegate: SidePanelViewControllerDelegate?

  var menuItems: Array<Menu>!
  
  struct TableView {
    struct CellIdentifiers {
      static let AnimalCell = "MenuItemCell"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.reloadData()
    view.backgroundColor = UIColor.blackColor()
    tableView.backgroundColor = UIColor.blackColor()
    tableView.separatorColor = UIColor.blackColor()
  }
  
}

// MARK: Table View Data Source

extension SidePanelViewController: UITableViewDataSource {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return menuItems.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(TableView.CellIdentifiers.AnimalCell, forIndexPath: indexPath) as! MenuItemCell
    cell.configureForMenu(menuItems[indexPath.row])
    cell.backgroundColor = UIColor.blackColor()
    return cell
  }
  
}

// Mark: Table View Delegate

extension SidePanelViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // You have to dissable user to click it twice fast, app breaks
    
    let selectedMenuItem = menuItems[indexPath.row]
    delegate?.menuItemSelected(selectedMenuItem)
  }
  
}

class MenuItemCell: UITableViewCell {
  
  @IBOutlet weak var menuItemImageView: UIImageView!
  @IBOutlet weak var menuItemName: UILabel!
  
  func configureForMenu(menuItem: Menu) {
    menuItemImageView.image = menuItem.image
    menuItemName.text = menuItem.title
  }
  
}