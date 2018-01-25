   //
   //  SidePanelViewController.swift
   //  e-Homegreen
   //
   //  Created by Teodor Stevic on 6/15/15.
   //  Copyright (c) 2015 Teodor Stevic. All rights reserved.
   //
   
   import UIKit
   
   class SidePanelViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    fileprivate var sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var menu:[MenuItem] = []
    
    var user:User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        //get user if exist
        user = DatabaseUserController.shared.getLoggedUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let user = user {
            DatabaseMenuController.shared.changeOrder(menu, user: user)
        }
    }
    
    func reloadMenu(){
        //check if admin, user or super user and create menu
        if let user = user { menu = DatabaseMenuController.shared.getVisibleMenuItemByUser(user)
        } else { menu = DatabaseMenuController.shared.createMenuForAdmin() }
        menuCollectionView.reloadData()
    }
    
    
    //pragma mark - LXReorderableCollectionViewDataSource methods
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, willMoveTo toIndexPath: IndexPath!) {

        let pom = menu[fromIndexPath.item]
        menu.remove(at: fromIndexPath.item)
        menu.insert(pom, at: toIndexPath.item)

    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        if AdminController.shared.isAdminLogged() { return false }
        if indexPath.item == menu.count || indexPath.item == menu.count - 1 { return false }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, canMoveTo toIndexPath: IndexPath!) -> Bool {
        
        if AdminController.shared.isAdminLogged() { return false }
        if toIndexPath.item == menu.count || toIndexPath.item == menu.count - 1 { return false }
        return true
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        let optionMenu = UIAlertController(title: nil, message: "Are you sure to want to log out?", preferredStyle: .actionSheet)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            DatabaseLocationController.shared.stopAllLocationMonitoring()
            DatabaseUserController.shared.logoutUser()
            let _ = DatabaseUserController.shared.setUser(nil)
            AdminController.shared.logoutAdmin()
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let logIn = storyboard.instantiateViewController(withIdentifier: "LoginController") as? LogInViewController {
                self.present(logIn, animated: false, completion: nil)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
   }
   
   extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != menu.count {
            if let item = Menu(rawValue: Int(menu[indexPath.row].id)) {
                self.revealViewController().pushFrontViewController(item.controller, animated: true)
            }
        }
        if let user = user { user.lastScreenId = menu[indexPath.row].id }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < menu.count { return CGSize(width: 88, height: 88) } else { return CGSize(width: 184, height: 70) }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let footerSize = CGSize(width: menuCollectionView.frame.width, height: 50)
        return footerSize
    }
    
   }
   
   extension SidePanelViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < menu.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MenuItemCell", for: indexPath) as? MenuItemCell {
                
                cell.configureForMenu(menu[indexPath.row])
                if cell.menuItemName.text == "Remote" || cell.menuItemName.text == "Media" { cell.isUserInteractionEnabled = false } else { cell.isUserInteractionEnabled = true }
                return cell
            }
            
            return UICollectionViewCell()
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogOutCell", for: indexPath) as? LogOutCell {
                cell.setItem(user)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footerView = menuCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! MenuFooterView
            footerView.configureFooter()
            return footerView
            
        default:
            let footerView = menuCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as! MenuFooterView
            footerView.configureFooter()
            return footerView
        }
    }
    
   }
   
   class MenuItemCell: UICollectionViewCell {
    
    @IBOutlet weak var menuItemImageView: UIImageView!
    @IBOutlet weak var menuItemName: UILabel!
    
    var colorOne = UIColor(red: 52/255, green: 52/255, blue: 49/255, alpha: 1).cgColor
    var colorTwo = UIColor(red: 28/255, green: 28/255, blue: 26/255, alpha: 1).cgColor
    
    func configureForMenu (_ menuItem:MenuItem) {
        layer.cornerRadius = 5
        
        if let item = Menu(rawValue: Int(menuItem.id)){
            menuItemImageView.image = UIImage(named: item.description)
            menuItemName.text = item.description
        }
    }
    
    override var isHighlighted: Bool {
        willSet(newValue) {
            if newValue {
                colorOne = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).cgColor
                colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
            } else {
                colorOne = UIColor(red: 52/255, green: 52/255, blue: 49/255, alpha: 1).cgColor
                colorTwo = UIColor(red: 28/255, green: 28/255, blue: 26/255, alpha: 1).cgColor
            }
        }
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        let colors = [ colorOne, colorTwo]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                                  colors: colors as CFArray,
                                                  locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:bounds.height)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        
    }
   }
   
   class LogOutCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dataBaseLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    let userImage0 = UIImage(named: "User")
    
    func setItem(_ user:User?) {
        layer.cornerRadius = 5
        
        if let user = user {
            
            if let id = user.customImageId {
                if let image = DatabaseImageController.shared.getImageById(id) {
                    
                    if let data =  image.imageData { userImage.image = UIImage(data: data)
                    } else {
                        if let defaultImage = user.defaultImage{ userImage.image = UIImage(named: defaultImage)
                        } else { userImage.image = userImage0 } }
                    
                } else {
                    if let defaultImage = user.defaultImage { userImage.image = UIImage(named: defaultImage)
                    } else { userImage.image = userImage0 } }
                
            } else {
                if let defaultImage = user.defaultImage { userImage.image = UIImage(named: defaultImage)
                } else { userImage.image = userImage0 } }
            
            userLabel.text = user.username
            
        } else {
            
            userLabel.text = (AdminController.shared.getAdmin())?.username
            if let user = DatabaseUserController.shared.getOtherUser() {
                if let username = user.username { dataBaseLabel.text = username + "'s database"
                } else {  dataBaseLabel.text = "null" }
            } else { dataBaseLabel.text = "null" }
        }
        
    }

   }

   class MenuFooterView: UICollectionReusableView {
    
    @IBOutlet weak var footerImageView: UIImageView!
    
    func configureFooter() {
        footerImageView.image = #imageLiteral(resourceName: "main_manu_bottom")
        footerImageView.contentMode = .scaleAspectFit
    }
    
   }
