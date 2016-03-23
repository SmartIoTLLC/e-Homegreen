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
    optional func menuItemSelected(menuItem: MenuItem)
}

class SidePanelViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    var delegate: SidePanelViewControllerDelegate?
    private var sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var menuItems: [MenuItem]!
    var menuList:[NSString] = []
  
    struct CollectionView {
        struct CellIdentifiers {
            static let MenuCell = "MenuItemCell"
        }
    }
    
    deinit {
        print("deinit - class SidePanelViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //(red: 47/255, green: 47/255, blue: 47/255, alpha: 1)
        view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        menuList.removeAll(keepCapacity: false)
        menuCollectionView.userInteractionEnabled = true
//        menuList = []
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        logoImageView.startShimmering()
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
        if indexPath.item == (menuItems.count - 1) || indexPath.item == menuItems.count {
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if toIndexPath.item == (menuItems.count - 1) || toIndexPath.item == menuItems.count {
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
        for item in menuItems{
            menuList.append(item.title!)
        }
        NSUserDefaults.standardUserDefaults().setObject(menuList, forKey: "menu")
        NSUserDefaults.standardUserDefaults().synchronize()

    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        
    }
    
    
}

extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        collectionView.cellForItemAtIndexPath(indexPath)?.collapseInReturnToNormalMenu(1)
        if indexPath.row != menuItems.count{
            let selectedMenuItem = menuItems[indexPath.row]
            NSUserDefaults.standardUserDefaults().setObject(selectedMenuItem.title, forKey: "firstItem")
            NSUserDefaults.standardUserDefaults().synchronize()
            delegate?.menuItemSelected!(selectedMenuItem)
            collectionView.userInteractionEnabled = false
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < menuItems.count{
            return CGSize(width: 88, height: 88)
        }else{
            return CGSize(width: 190, height: 70)
        }
    }
}

extension SidePanelViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < menuItems.count{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionView.CellIdentifiers.MenuCell, forIndexPath: indexPath) as! MenuItemCell
            cell.configureForMenu(menuItems[indexPath.row])
            cell.layer.cornerRadius = 5
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LogOutCell", forIndexPath: indexPath) as! LogOutCell
            return cell
        }

    }
}
   
class MenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemName: UILabel!
    
    var colorOne = UIColor(red: 52/255, green: 52/255, blue: 49/255, alpha: 1).CGColor
    var colorTwo = UIColor(red: 28/255, green: 28/255, blue: 26/255, alpha: 1).CGColor
    func configureForMenu (menuItem:MenuItem) {
        menuItemImageView.image = menuItem.image
        menuItemName.text = menuItem.title
    }
    
    
    override var highlighted: Bool {
        willSet(newValue) {
            if newValue {
                colorOne = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor
                colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor
            } else {
                colorOne = UIColor(red: 52/255, green: 52/255, blue: 49/255, alpha: 1).CGColor
                colorTwo = UIColor(red: 28/255, green: 28/255, blue: 26/255, alpha: 1).CGColor
            }
        }
        didSet {
            print("highlighted = \(highlighted)")
            setNeedsDisplay()
        }
    }
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        let colors = [ colorOne, colorTwo]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:bounds.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))

    }
}
   
class LogOutCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dataBaseLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    
}
   