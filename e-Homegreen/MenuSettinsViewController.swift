//
//  MenuSettinsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/1/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class MenuSettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning  {
    
    @IBOutlet weak var topView: UIView!
    var menuItems: Array<MenuItem>!
    var menuList:[NSString] = []
    var listOfMenuItems: Array<MenuItem>!
    
    var isPresenting:Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        transitioningDelegate = self
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.transitioningDelegate = self
        
//        menuItems = MenuViewControllers.sharedInstance.allMenuItems()
//        listOfMenuItems = MenuViewControllers.sharedInstance.allMenuItems1()
        
        for item in menuItems{
            for item1 in listOfMenuItems{
                if item.title == item1.title{
                    item.state = true
                }
            }
        }
        
        var defaultMenu = menuItems
        for (index, item) in defaultMenu.enumerate() {
            if item.title == "Settings" {
//                defaultMenu.removeAtIndex(index)
            }
        }
        menuItems = defaultMenu
        // Do any additional setup after loading the view.
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            presentedControllerView.center.x += containerView!.bounds.size.width
            containerView!.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x -= containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                presentedControllerView.center.x += containerView!.bounds.size.width
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeValue(sender:UISwitch){
        if sender.tag == 11{
            sender.on = true
        }else{
            if sender.on == true {
                menuItems[sender.tag].state = true
            }else {
                menuItems[sender.tag].state = false
            }
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("menuSettingsCell") as? MenuSettingsCell {
            cell.menuImage.image = menuItems[indexPath.row].image
            cell.menuLabel.text = menuItems[indexPath.row].title
            cell.menuSwitch.tag = indexPath.row
            cell.menuSwitch.addTarget(self, action: "changeValue:", forControlEvents: UIControlEvents.ValueChanged)
            if menuItems[indexPath.row].state == true {
                cell.menuSwitch.on = true
            }else {
                cell.menuSwitch.on = false
            }
            return cell
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = ""
        cell.contentView.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count-1
    }
    
    @IBAction func backButton(sender: AnyObject) {
        for items in menuItems{
            if items.state == true{
                menuList.append(items.title!)
            }
        }
        NSUserDefaults.standardUserDefaults().setObject(menuList, forKey: "menu")
        NSUserDefaults.standardUserDefaults().synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    



}

class MenuSettingsCell:UITableViewCell{
    
    @IBOutlet weak var menuImage: UIImageView!
    @IBOutlet weak var menuSwitch: UISwitch!
    @IBOutlet weak var menuLabel: UILabel!
    
}
