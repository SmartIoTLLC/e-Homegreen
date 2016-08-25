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
    var menu:[MenuItem] = []
    
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()
        
        //get user if exist
        user = DatabaseUserController.shared.getLoggedUser()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadMenu()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if let user = user{
            DatabaseMenuController.shared.changeOrder(menu, user: user)
        }
    }
    
    func reloadMenu(){
        //check if admin, user or super user and create menu
        if let user = user{
            menu = DatabaseMenuController.shared.getVisibleMenuItemByUser(user)
        }else{
            menu = DatabaseMenuController.shared.createMenuForAdmin()
        }
        menuCollectionView.reloadData()
        
    }
    
    
    //pragma mark - LXReorderableCollectionViewDataSource methods
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {

        let pom = menu[fromIndexPath.item]
        menu.removeAtIndex(fromIndexPath.item)
        menu.insert(pom, atIndex: toIndexPath.item)

    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        if AdminController.shared.isAdminLogged(){
            return false
        }
        if indexPath.item == menu.count || indexPath.item == menu.count - 1 {
            return false
        }
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        if AdminController.shared.isAdminLogged(){
            return false
        }
        if toIndexPath.item == menu.count || toIndexPath.item == menu.count - 1 {
            return false
        }
        return true
    }
    
    @IBAction func logOutAction(sender: UIButton) {
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
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
        
    }
    
    
   }
   
   extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != menu.count {
            if let item = Menu(rawValue: Int(menu[indexPath.row].id)){
                self.revealViewController().pushFrontViewController(item.controller, animated: true)
            }
        }
        if let user = user{
            user.lastScreenId = Int(menu[indexPath.row].id)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row < menu.count{
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
        return menu.count + 1
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < menu.count{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MenuItemCell", forIndexPath: indexPath) as! MenuItemCell
            
            cell.configureForMenu(menu[indexPath.row])
            
            
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
        if let item = Menu(rawValue: Int(menuItem.id)){
            menuItemImageView.image = UIImage(named: item.description)
            menuItemName.text = item.description
        }
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
            
            if let id = user.customImageId{
                if let image = DatabaseImageController.shared.getImageById(id){
                    if let data =  image.imageData {
                        userImage.image = UIImage(data: data)
                    }else{
                        if let defaultImage = user.defaultImage{
                            userImage.image = UIImage(named: defaultImage)
                        }else{
                            userImage.image = UIImage(named: "User")
                        }
                    }
                }else{
                    if let defaultImage = user.defaultImage{
                        userImage.image = UIImage(named: defaultImage)
                    }else{
                        userImage.image = UIImage(named: "User")
                    }
                }
            }else{
                if let defaultImage = user.defaultImage{
                    userImage.image = UIImage(named: defaultImage)
                }else{
                    userImage.image = UIImage(named: "User")
                }
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
      