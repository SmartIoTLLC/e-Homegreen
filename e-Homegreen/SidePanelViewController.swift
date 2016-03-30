   //
//  SidePanelViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

//@objc
//protocol SidePanelViewControllerDelegate {
//    optional func menuItemSelected(menuItem: MenuItem)
//}

class SidePanelViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
//    var delegate: SidePanelViewControllerDelegate?
    private var sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var menuItems: [MenuItem] = []
  
//    struct CollectionView {
//        struct CellIdentifiers {
//            static let MenuCell = "MenuItemCell"
//        }
//    }
    var vc = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("vlada") as! UINavigationController
    
    @IBAction func action(sender: AnyObject) {
        self.revealViewController().pushFrontViewController(vc, animated: true)
    }
    var viewControllers:Array<UINavigationController> = [
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Dashboard") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Devices") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Scenes") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Events") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Sequences") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Timers") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Flags") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Chat") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Security") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Surveillance") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Energy") as? UINavigationController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("PC Control") as? UINavigationController )!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Users") as? UINavigationController )!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("Settings") as? UINavigationController)!
    ]
    
    var menuList:[String] = ["Dashboard", "Devices", "Scenes", "Events", "Sequences", "Timers", "Flags", "Chat", "Security", "Surveillance", "Energy", "PC Control", "Users", "Settings"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        for (index, element) in viewControllers.enumerate() {
            let menuItem = MenuItem(title: menuList[index], image: UIImage(named: menuList[index]), viewController: element, state: true)
            menuItems.append(menuItem)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        menuList.removeAll(keepCapacity: false)
//        menuCollectionView.userInteractionEnabled = true
//        menuList = []
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        logoImageView.startShimmering()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
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
        if indexPath.item == 14 || indexPath.item == 13 {
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if toIndexPath.item == 14 || toIndexPath.item == 13 {
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

    
//    override func viewWillDisappear(animated: Bool) {
//        for item in menuItems{
//            menuList.append(item.title!)
//        }
//        NSUserDefaults.standardUserDefaults().setObject(menuList, forKey: "menu")
//        NSUserDefaults.standardUserDefaults().synchronize()
//
//    }
    
    @IBAction func logOutAction(sender: AnyObject) {
        
    }
    
    
    func vlada(gest:UITapGestureRecognizer){
        self.revealViewController().pushFrontViewController(menuItems[0].viewController, animated: true)
    }
    
    
}

extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row != 14 {
            self.revealViewController().pushFrontViewController(menuItems[indexPath.row].viewController, animated: true)
        }
        //        collectionView.cellForItemAtIndexPath(indexPath)?.collapseInReturnToNormalMenu(1)
//        if indexPath.row != menuItems.count{
//            let selectedMenuItem = menuItems[indexPath.row]
//            NSUserDefaults.standardUserDefaults().setObject(selectedMenuItem.title, forKey: "firstItem")
//            NSUserDefaults.standardUserDefaults().synchronize()
//            delegate?.menuItemSelected!(selectedMenuItem)
//            collectionView.userInteractionEnabled = false
//        }
    }
   
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < 14{
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
//        return menuItems.count + 1
        return 15
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < 14{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MenuItemCell", forIndexPath: indexPath) as! MenuItemCell
            cell.configureForMenu(menuItems[indexPath.row])
            cell.layer.cornerRadius = 5
//            cell.menuItemImageView.userInteractionEnabled = true
//            cell.menuItemImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "vlada:"))
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
   