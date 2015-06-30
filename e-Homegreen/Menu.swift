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
    
    class func allMenuItems() -> Array<Menu> {
        var returnValue: [NSString]? = NSUserDefaults.standardUserDefaults().objectForKey("menu") as? [NSString]
        
        
        if let unwrappedTitlesForTip = returnValue {
            return [
                Menu (title: unwrappedTitlesForTip[0] as String, image: UIImage(named: unwrappedTitlesForTip[0] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[0] as String)),
                Menu (title: unwrappedTitlesForTip[1] as String, image: UIImage(named: unwrappedTitlesForTip[1] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[1] as String)),
                Menu (title: unwrappedTitlesForTip[2] as String, image: UIImage(named: unwrappedTitlesForTip[2] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[2] as String)),
                Menu (title: unwrappedTitlesForTip[3] as String, image: UIImage(named: unwrappedTitlesForTip[3] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[3] as String)),
                Menu (title: unwrappedTitlesForTip[4] as String, image: UIImage(named: unwrappedTitlesForTip[4] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[4] as String)),
                Menu (title: unwrappedTitlesForTip[5] as String, image: UIImage(named: unwrappedTitlesForTip[5] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[5] as String)),
                Menu (title: unwrappedTitlesForTip[6] as String, image: UIImage(named: unwrappedTitlesForTip[6] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[6] as String)),
                Menu (title: unwrappedTitlesForTip[7] as String, image: UIImage(named: unwrappedTitlesForTip[7] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[7] as String)),
                Menu (title: unwrappedTitlesForTip[8] as String, image: UIImage(named: unwrappedTitlesForTip[8] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[8] as String)),
                Menu (title: unwrappedTitlesForTip[9] as String, image: UIImage(named: unwrappedTitlesForTip[9] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[9] as String)),
                Menu (title: unwrappedTitlesForTip[10] as String, image: UIImage(named: unwrappedTitlesForTip[10] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[10] as String)),
                Menu (title: unwrappedTitlesForTip[11] as String, image: UIImage(named: unwrappedTitlesForTip[11] as String), viewController: MenuViewControllers.sharedInstance.getViewController(unwrappedTitlesForTip[11] as String))]
        }
        return [
            Menu (title: "Dashboard", image: UIImage(named: "Dashboard"), viewController: MenuViewControllers.sharedInstance.getViewController("Dashboard")),
            Menu (title: "Devices", image: UIImage(named: "Devices"), viewController: MenuViewControllers.sharedInstance.getViewController("Devices")),
            Menu (title: "Scenes", image: UIImage(named: "Scenes"), viewController: MenuViewControllers.sharedInstance.getViewController("Scenes")),
            Menu (title: "Events", image: UIImage(named: "Events"), viewController: MenuViewControllers.sharedInstance.getViewController("Events")),
            Menu (title: "Sequences", image: UIImage(named: "Sequences"), viewController: MenuViewControllers.sharedInstance.getViewController("Sequences")),
            Menu (title: "Timers", image: UIImage(named: "Timers"), viewController: MenuViewControllers.sharedInstance.getViewController("Timers")),
            Menu (title: "Flags", image: UIImage(named: "Flags"), viewController: MenuViewControllers.sharedInstance.getViewController("Flags")),
            Menu (title: "Chat", image: UIImage(named: "Chat"), viewController: MenuViewControllers.sharedInstance.getViewController("Chat")),
            Menu (title: "Security", image: UIImage(named: "Security"), viewController: MenuViewControllers.sharedInstance.getViewController("Security")),
            Menu (title: "Surveillance", image: UIImage(named: "Surveillance"), viewController: MenuViewControllers.sharedInstance.getViewController("Surveillance")),
            Menu (title: "Energy", image: UIImage(named: "Energy"), viewController: MenuViewControllers.sharedInstance.getViewController("Energy")),
            Menu (title: "Settings", image: UIImage(named: "Settings"), viewController: MenuViewControllers.sharedInstance.getViewController("Settings"))]
        
    }
}
class MenuViewControllers: NSObject {
    class var sharedInstance:MenuViewControllers{
        struct Singleton {
            static let instance = MenuViewControllers()
        }
        return Singleton.instance
    }
    var viewControllers:Array<CommonViewController> = [
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("DashboardViewController") as? DashboardViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("DevicesViewController") as? DevicesViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ScenesViewController") as? ScenesViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("EventsViewController") as? EventsViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SequencesViewController") as? SequencesViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("TimersViewController") as? TimersViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("FlagsViewController") as? FlagsViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SecurityViewController") as? SecurityViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SurveillenceViewController") as? SurveillenceViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("EnergyViewController") as? EnergyViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SettingsViewController") as? SettingsViewController)!
    ]
//    func getViewController (arrayNumber:Int) -> CommonViewController {
//        return viewControllers[arrayNumber]
//    }
    func getViewController (arrayNumber:String) -> CommonViewController {
        var backNumber:Int
        switch arrayNumber{
            case "Dashboard": backNumber = 0
            case "Devices": backNumber = 1
            case "Scenes": backNumber = 2
            case "Events": backNumber = 3
            case "Sequences": backNumber = 4
            case "Timers": backNumber = 5
            case "Flags": backNumber = 6
            case "Chat": backNumber = 7
            case "Security": backNumber = 8
            case "Surveillance": backNumber = 9
            case "Energy": backNumber = 10
            case "Settings": backNumber = 11
            default: backNumber = 0
        }
        return viewControllers[backNumber]
    }
}
