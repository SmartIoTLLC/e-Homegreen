//
//  Menu.swift
//  SlideOutNavigation
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 James Frost. All rights reserved.
//

import UIKit

@objc
class Menu {
    let title: String
    let image: UIImage?
    let viewController: UIViewController
    
    init(title: String, image: UIImage?, viewController: UIViewController) {
        self.title = title
        self.image = image
        self.viewController = viewController
    }
    
//    class func allMenuItems() -> Array<Menu> {
//        return [
//            Menu (title: "Devices", image: UIImage(named: "Devices"), viewController: (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("DevicesViewController") as? DevicesViewController)!),
//            Menu (title: "Scenes", image: UIImage(named: "Scenes"), viewController: (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ScenesViewController") as? ScenesViewController)!),
//            Menu (title: "Security", image: UIImage(named: "Security"), viewController: (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SecurityViewController") as? SecurityViewController)!),
//            Menu (title: "Camera", image: UIImage(named: "Camera"), viewController: (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("CameraViewController") as? CameraViewController)!),
//            Menu (title: "Database", image: UIImage(named: "Database"), viewController: (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("DatabaseViewController") as? DatabaseViewController)!),
//            Menu (title: "NFC", image: UIImage(named: "NFC"), viewController: (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("NFCViewController") as? NFCViewController)!),
//            Menu (title: "Settings", image: UIImage(named: "Settings"), viewController: (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController)!)]
//    }
    class func allMenuItems() -> Array<Menu> {
        return [
            Menu (title: "Devices", image: UIImage(named: "Devices"), viewController: MenuViewControllers.sharedInstance.getViewController(0)),
            Menu (title: "Scenes", image: UIImage(named: "Scenes"), viewController: MenuViewControllers.sharedInstance.getViewController(1)),
            Menu (title: "Security", image: UIImage(named: "Security"), viewController: MenuViewControllers.sharedInstance.getViewController(2)),
            Menu (title: "Camera", image: UIImage(named: "Camera"), viewController: MenuViewControllers.sharedInstance.getViewController(3)),
            Menu (title: "Database", image: UIImage(named: "Database"), viewController: MenuViewControllers.sharedInstance.getViewController(4)),
            Menu (title: "NFC", image: UIImage(named: "NFC"), viewController: MenuViewControllers.sharedInstance.getViewController(5)),
            Menu (title: "Settings", image: UIImage(named: "Settings"), viewController: MenuViewControllers.sharedInstance.getViewController(6))]
    }
}
class MenuViewControllers: NSObject {
    class var sharedInstance:MenuViewControllers{
        struct Singleton {
            static let instance = MenuViewControllers()
        }
        return Singleton.instance
    }
    var viewControllers:Array<CommonViewController> = [(UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("DevicesViewController") as? DevicesViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ScenesViewController") as? ScenesViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SecurityViewController") as? SecurityViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("CameraViewController") as? CameraViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("DatabaseViewController") as? DatabaseViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("NFCViewController") as? NFCViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController)!
    ]
    func getViewController (arrayNumber:Int) -> CommonViewController {
        return viewControllers[arrayNumber]
    }
}
