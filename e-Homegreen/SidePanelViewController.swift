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
        for item in menuItems{
            menuList.append(item.title!)
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
    
//    init() {
//        NSNotificationCenter.defaultCenter().addObserverForName(
//            UIApplicationDidReceiveMemoryWarningNotification,
//            object: nil, queue: NSOperationQueue.mainQueue()) { notification in
////                self.images.removeAll(keepCapacity: false)
//        }
//    }
//    
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self,
//            name: UIApplicationDidReceiveMemoryWarningNotification,
//            object: nil)
//    }
//    cell.heartToggleHandler = { isStarred in
//    self.collectionView.reloadItemsAtIndexPaths([ indexPath ])
//    }
//    cell.heartToggleHandler = { [weak self] isStarred in
//    if let strongSelf = self {
//    strongSelf.collectionView.reloadItemsAtIndexPaths([ indexPath ])
//    }
//    }
}

extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        collectionView.cellForItemAtIndexPath(indexPath)?.collapseInReturnToNormalMenu(1)
        let selectedMenuItem = menuItems[indexPath.row]
        NSUserDefaults.standardUserDefaults().setObject(selectedMenuItem.title, forKey: "firstItem")
        NSUserDefaults.standardUserDefaults().synchronize()
        delegate?.menuItemSelected!(selectedMenuItem)
        collectionView.userInteractionEnabled = false
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
        cell.configureForMenu(menuItems[indexPath.row])
        cell.layer.cornerRadius = 5
        return cell
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("accessCell", forIndexPath: indexPath) as! AccessControllCell
//        return cell
    }
}
class MenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemName: UILabel!
//    var gradientLayer: CAGradientLayer?
    
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
//        let path = UIBezierPath(roundedRect: rect,
//            byRoundingCorners: UIRectCorner.AllCorners,
//            cornerRadii: CGSize(width: 5.0, height: 5.0))
//        path.addClip()
//        path.lineWidth = 2
//        UIColor.lightGrayColor().setStroke()
        
        
        
        let context = UIGraphicsGetCurrentContext()
//        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        let colors = [ colorOne, colorTwo]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
            colors,
            colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:bounds.height)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        
        
        
//        path.stroke()
    }
}