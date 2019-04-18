//
//  SidePanelViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//
   
import UIKit

private struct LocalConstants {
    static let sectionInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    static let itemCellSize: CGSize = CGSize(width: 88, height: 88)
    static let logoutCellSize: CGSize = CGSize(width: 184, height: 70)
    static let minimumLineSpacing: CGFloat = 8
    static let interitemSpacing: CGFloat = 8
    static let footerSize: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
    
    static let topLogoSize: CGSize = CGSize(width: 200, height: 42)
}

enum SidemenuCellType: Int {
    case featureCell
    case logoutCell
}
   
class SidePanelViewController: UIViewController, LXReorderableCollectionViewDataSource, LXReorderableCollectionViewDelegateFlowLayout {
    
    private let logoImageView: UIImageView = UIImageView()
    private let separatorView: UIView = UIView()

    fileprivate let menuCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    fileprivate var menuItemList: [MenuItem] = []
    fileprivate var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        user = DatabaseUserController.shared.getLoggedUser()
        
        self.revealViewController().setRight(FavoriteDevicesVC(), animated: true)
        
        addLogoImageView()
        addSeparatorView()
        addCollectionView()
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadMenu()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let user = user {
            DatabaseMenuController.shared.changeOrder(menuItemList, user: user)
        }
    }
    
    private func addCollectionView() {
        menuCollectionView.register(SidemenuItemCollectionViewCell.self, forCellWithReuseIdentifier: SidemenuItemCollectionViewCell.reuseIdentifier)
        menuCollectionView.register(SidemenuUserCollectionViewCell.self, forCellWithReuseIdentifier: SidemenuUserCollectionViewCell.reuseIdentifier)
        menuCollectionView.register(SidemenuCollectionViewFooter.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SidemenuCollectionViewFooter.reuseIdentifier)
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        
        view.addSubview(menuCollectionView)
    }
    
    private func addLogoImageView() {
        logoImageView.image = #imageLiteral(resourceName: "main_menu_top")
        logoImageView.contentMode = .scaleAspectFit
        
        view.addSubview(logoImageView)
    }
    
    private func addSeparatorView() {
        separatorView.backgroundColor = UIColor(cgColor: Colors.LightGrayColor)
        
        view.addSubview(separatorView)
    }
    
    private func setupConstraints() {
        logoImageView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            } else {
                make.top.equalToSuperview().offset(16)
            }
            make.centerX.equalTo(menuCollectionView.snp.centerX)
            make.width.equalTo(LocalConstants.topLogoSize.width)
            make.height.equalTo(LocalConstants.topLogoSize.height)
        }
        
        separatorView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        menuCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview()
            make.width.equalTo(200)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
    }
    
    func reloadMenu() {
        //check if admin, user or super user and create menu
        if let user = user {
            menuItemList = DatabaseMenuController.shared.getVisibleMenuItemByUser(user)
        } else {
            menuItemList = DatabaseMenuController.shared.createMenuForAdmin()
        }
        menuCollectionView.reloadData()
    }
    
    
    //pragma mark - LXReorderableCollectionViewDataSource methods
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, willMoveTo toIndexPath: IndexPath!) {

        let pom = menuItemList[fromIndexPath.item]
        menuItemList.remove(at: fromIndexPath.item)
        menuItemList.insert(pom, at: toIndexPath.item)

    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        if AdminController.shared.isAdminLogged() { return false }
        if indexPath.item == menuItemList.count || indexPath.item == menuItemList.count - 1 { return false }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, canMoveTo toIndexPath: IndexPath!) -> Bool {
        
        if AdminController.shared.isAdminLogged() { return false }
        if toIndexPath.item == menuItemList.count || toIndexPath.item == menuItemList.count - 1 { return false }
        return true
    }
    
   }
   
   extension SidePanelViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < menuItemList.count {
            let id = menuItemList[indexPath.row].id
            
            if let user = user {
                user.lastScreenId = id
            }
            
            if let menuItem = Menu(rawValue: id.intValue) {
                self.revealViewController().pushFrontViewController(menuItem.controller, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return LocalConstants.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LocalConstants.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return LocalConstants.interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return (indexPath.row < menuItemList.count) ? LocalConstants.itemCellSize : LocalConstants.logoutCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return LocalConstants.footerSize
    }
    
   }
   
   extension SidePanelViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItemList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < menuItemList.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SidemenuItemCollectionViewCell.reuseIdentifier, for: indexPath) as? SidemenuItemCollectionViewCell {
                cell.setCell(with: menuItemList[indexPath.row])
                return cell
            }
            
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SidemenuUserCollectionViewCell.reuseIdentifier, for: indexPath) as? SidemenuUserCollectionViewCell {
                cell.setCell(with: user)
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionFooter {
            if let footerView = menuCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SidemenuCollectionViewFooter.reuseIdentifier, for: indexPath) as? SidemenuCollectionViewFooter {
                
                return footerView
            }
        }
        
        return UICollectionReusableView()
    }
    
}
