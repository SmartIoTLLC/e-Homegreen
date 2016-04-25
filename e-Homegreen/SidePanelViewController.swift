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
    private var sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var menuItems: [MenuItem] = []
    
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        //get user if exist
        user = DatabaseUserController.shared.getLoggedUser()

        //check if admin, user or super user and create menu for it
        if let user = user{
            if user.isSuperUser == true {
                for item in  Menu.allMenuItem {
                    let menuItem = MenuItem(title: item.description, image:  UIImage(named: item.description), viewController: item.controller, state: true)
                    menuItems.append(menuItem)
                }
            }else{
                for item in  Menu.allMenuItemNotSuperUser {
                    let menuItem = MenuItem(title: item.description, image:  UIImage(named: item.description), viewController: item.controller, state: true)
                    menuItems.append(menuItem)
                }
            }
        }else{
            for item in  Menu.allMenuItem {
                let menuItem = MenuItem(title: item.description, image:  UIImage(named: item.description), viewController: item.controller, state: true)
                menuItems.append(menuItem)
            }
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        menuCollectionView.reloadData()
    }
    
    
    //pragma mark - LXReorderableCollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        let pom = menuItems[fromIndexPath.item]
        menuItems.removeAtIndex(fromIndexPath.item)
        menuItems.insert(pom, atIndex: toIndexPath.item)
        
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
    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        print("did begin drag")
//    }
//    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        print("did end drag")
//    }
//    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        print("will begin drag")
//    }
//    
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
//        print("will end drag")
//    }
    
    // collection view layout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }

    
    @IBAction func logOutAction(sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Are you sure to want to log out?", preferredStyle: .ActionSheet)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            DatabaseLocationController.shared.stopAllLocationMonitoring()
            DatabaseUserController.shared.logoutUser()
            DatabaseUserController.shared.setUser(nil)
            AdminController.shared.logoutAdmin()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let logIn = storyboard.instantiateViewControllerWithIdentifier("LoginController") as! LogInViewController
            self.presentViewController(logIn, animated: false, completion: nil)

        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        
    }
    
    
}

extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row != 14 {
            self.revealViewController().pushFrontViewController(menuItems[indexPath.row].viewController, animated: true)
        }

    }
   
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < 14{
            return CGSize(width: 88, height: 88)
        }else{
            return CGSize(width: 184, height: 70)
        }
    }
}

extension SidePanelViewController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < 14{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MenuItemCell", forIndexPath: indexPath) as! MenuItemCell
            cell.configureForMenu(menuItems[indexPath.row])
            cell.layer.cornerRadius = 5
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("LogOutCell", forIndexPath: indexPath) as! LogOutCell
            cell.setItem(user)
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
    
    func setItem(user:User?){
        if let user = user{
            if let image  = user.profilePicture{
                userImage.image = UIImage(data: image)
            }else{
                userImage.image = UIImage(named: "User")
            }
            userLabel.text = user.username
        }else{
            userLabel.text = (AdminController.shared.getAdmin())?.username
            if let user = DatabaseUserController.shared.getOtherUser(){
                if let username = user.username{
                    dataBaseLabel.text = username + "'s database"
                }else{
                    dataBaseLabel.text = "null"
                }
            }else{
                dataBaseLabel.text = "null"
            }
        }
        
    }
    
    
}
   