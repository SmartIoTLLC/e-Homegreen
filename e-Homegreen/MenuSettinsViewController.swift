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
    
    var isPresenting:Bool = true
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        transitioningDelegate = self
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, self.view.frame.size.height, 64)
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        topView.layer.insertSublayer(gradient, atIndex: 0)
        
        self.transitioningDelegate = self
        
        menuItems = MenuViewControllers.sharedInstance.allMenuItems()
        listOfMenuItems = MenuViewControllers.sharedInstance.allMenuItems1()
        
        for item in menuItems{
            for item1 in listOfMenuItems{
                if item.title == item1.title{
                    item.state = true
                }
            }
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
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
        if sender.on == true {
            menuItems[sender.tag].state = true
        }else {
            menuItems[sender.tag].state = false
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
                if indexPath.row == 11{
                    cell.menuSwitch.enabled = false
                }
            }else {
                cell.menuSwitch.on = false
            }
            
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
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
