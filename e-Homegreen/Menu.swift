//
//  Menu.swift
//  SlideOutNavigation
//
//  Created by Teodor Stevic on 6/15/15.
//  Copyright (c) 2015 James Frost. All rights reserved.
//

import UIKit

class MenuItem:NSObject{
    let title: String?
    let image: UIImage?
    let viewController: UIViewController?
    var state:Bool?
    
    init(title: String, image: UIImage?, viewController: UIViewController, state:Bool) {
        self.title = title
        self.image = image
        self.viewController = viewController
        self.state = state
    }
}

class MenuViewControllers: NSObject {
    class var sharedInstance:MenuViewControllers{
        struct Singleton {
            static let instance = MenuViewControllers()
        }
        return Singleton.instance
    }
    var menu: Array<MenuItem> = []
    
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
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("ProjectManagerViewController") as? ProjectManagerViewController)!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("PCControlViewController") as? PCControlViewController )!,
        (UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("UsersViewController") as? UsersViewController )!
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
            case "PC Control": backNumber = 12
            case "Users": backNumber = 13
            default: backNumber = 0
        }
        return viewControllers[backNumber]
    }
    func allMenuItems() -> Array<MenuItem> {
        return [
            MenuItem (title: "Dashboard", image: UIImage(named: "menu_dashboard"), viewController: MenuViewControllers.sharedInstance.getViewController("Dashboard"), state: false),
            MenuItem (title: "Devices", image: UIImage(named: "menu_devices"), viewController: MenuViewControllers.sharedInstance.getViewController("Devices"), state: false),
            MenuItem (title: "Scenes", image: UIImage(named: "menu_scenes"), viewController: MenuViewControllers.sharedInstance.getViewController("Scenes"), state: false),
            MenuItem (title: "Events", image: UIImage(named: "menu_events"), viewController: MenuViewControllers.sharedInstance.getViewController("Events"), state: false),
            MenuItem (title: "Sequences", image: UIImage(named: "menu_sequences"), viewController: MenuViewControllers.sharedInstance.getViewController("Sequences"), state: false),
            MenuItem (title: "Timers", image: UIImage(named: "menu_timers"), viewController: MenuViewControllers.sharedInstance.getViewController("Timers"), state: false),
            MenuItem (title: "Flags", image: UIImage(named: "menu_flags"), viewController: MenuViewControllers.sharedInstance.getViewController("Flags"), state: false),
            MenuItem (title: "Chat", image: UIImage(named: "menu_chat"), viewController: MenuViewControllers.sharedInstance.getViewController("Chat"), state: false),
            MenuItem (title: "Security", image: UIImage(named: "menu_security"), viewController: MenuViewControllers.sharedInstance.getViewController("Security"), state: false),
            MenuItem (title: "Surveillance", image: UIImage(named: "menu_surveillance"), viewController: MenuViewControllers.sharedInstance.getViewController("Surveillance"), state: false),
            MenuItem (title: "Energy", image: UIImage(named: "menu_energy"), viewController: MenuViewControllers.sharedInstance.getViewController("Energy"), state: false),
            MenuItem (title: "PC Control", image: UIImage(named: "PC Control"), viewController: MenuViewControllers.sharedInstance.getViewController("PC Control"), state: false),
            MenuItem (title: "Users", image: UIImage(named: "Users"), viewController: MenuViewControllers.sharedInstance.getViewController("Users"), state: false),
            MenuItem (title: "Settings", image: UIImage(named: "menu_settings"), viewController: MenuViewControllers.sharedInstance.getViewController("Settings"), state: false)]
    }
    
    func allMenuItems1() -> Array<MenuItem> {
        if !NSUserDefaults.standardUserDefaults().boolForKey("OvoObrisiKadaBudesVideoOvoJeSamoZaKalifuPrepravka") {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "OvoObrisiKadaBudesVideoOvoJeSamoZaKalifuPrepravka")
        } else {
            let returnValue: [NSString]? = NSUserDefaults.standardUserDefaults().objectForKey("menu") as? [NSString]
            
            
            if let unwrappedTitlesForTip = returnValue {
                menu.removeAll(keepCapacity: false)
                
                for item in unwrappedTitlesForTip{
                    
                    let men:MenuItem = MenuItem (title: item as String, image: UIImage(named: item as String), viewController: MenuViewControllers.sharedInstance.getViewController(item as String), state: true)
                    menu.append(men)
                }
                return menu
            }
        }
//        let returnValue: [NSString]? = NSUserDefaults.standardUserDefaults().objectForKey("menu") as? [NSString]
//        
//        
//        if let unwrappedTitlesForTip = returnValue {
//            menu.removeAll(keepCapacity: false)
//            
//            for item in unwrappedTitlesForTip{
//                
//                let men:MenuItem = MenuItem (title: item as String, image: UIImage(named: item as String), viewController: MenuViewControllers.sharedInstance.getViewController(item as String), state: true)
//                menu.append(men)
//            }
//            return menu
//        }
        
        menu = [
            MenuItem (title: "Dashboard", image: UIImage(named: "Dashboard"), viewController: MenuViewControllers.sharedInstance.getViewController("Dashboard"), state: true),
            MenuItem (title: "Devices", image: UIImage(named: "Devices"), viewController: MenuViewControllers.sharedInstance.getViewController("Devices"), state: true),
            MenuItem (title: "Scenes", image: UIImage(named: "Scenes"), viewController: MenuViewControllers.sharedInstance.getViewController("Scenes"), state: true),
            MenuItem (title: "Events", image: UIImage(named: "Events"), viewController: MenuViewControllers.sharedInstance.getViewController("Events"), state: true),
            MenuItem (title: "Sequences", image: UIImage(named: "Sequences"), viewController: MenuViewControllers.sharedInstance.getViewController("Sequences"), state: true),
            MenuItem (title: "Timers", image: UIImage(named: "Timers"), viewController: MenuViewControllers.sharedInstance.getViewController("Timers"), state: true),
            MenuItem (title: "Flags", image: UIImage(named: "Flags"), viewController: MenuViewControllers.sharedInstance.getViewController("Flags"), state: true),
            MenuItem (title: "Chat", image: UIImage(named: "Chat"), viewController: MenuViewControllers.sharedInstance.getViewController("Chat"), state: true),
            MenuItem (title: "Security", image: UIImage(named: "Security"), viewController: MenuViewControllers.sharedInstance.getViewController("Security"), state: true),
            MenuItem (title: "Surveillance", image: UIImage(named: "Surveillance"), viewController: MenuViewControllers.sharedInstance.getViewController("Surveillance"), state: true),
            MenuItem (title: "Energy", image: UIImage(named: "Energy"), viewController: MenuViewControllers.sharedInstance.getViewController("Energy"), state: true),
            MenuItem (title: "PC Control", image: UIImage(named: "PC Control"), viewController: MenuViewControllers.sharedInstance.getViewController("PC Control"), state: true),
            MenuItem (title: "Users", image: UIImage(named: "Users"), viewController: MenuViewControllers.sharedInstance.getViewController("Settings"), state: true),
            MenuItem (title: "Settings", image: UIImage(named: "Settings"), viewController: MenuViewControllers.sharedInstance.getViewController("Settings"), state: true)
            ]
        
        return menu
        
    }
    
    

    
}
