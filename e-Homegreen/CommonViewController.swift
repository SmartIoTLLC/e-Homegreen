//
//  CommonViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/17/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

@objc
protocol CommonViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}

class CommonViewController: UIViewController {
    var delegate:CommonViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    var backgroundImageView = UIImageView()
    
    func commonConstruct() {
        backgroundImageView.image = UIImage(named: "Background")
        backgroundImageView.frame = CGRectMake(0, 0, Common().screenWidth , Common().screenHeight-64)
        self.view.insertSubview(backgroundImageView, atIndex: 0)
        
//        view.addSubview(backgroundImageView)
//        let firstConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.LeadingMargin, multiplier: 1, constant: 40)
//        backgroundImageView.addConstraint(firstConstraint)
//        let secondConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.LeftMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.LeftMargin, multiplier: 1, constant: 0)
//        backgroundImageView.addConstraint(secondConstraint)
//        let thirdConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.RightMargin, multiplier: 1, constant: 0)
//        backgroundImageView.addConstraint(thirdConstraint)
//        let fourthConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.BottomMargin, multiplier: 1, constant: 0)
//        backgroundImageView.addConstraint(fourthConstraint)
        
    }
    func myFunction () {
        delegate?.toggleLeftPanel?()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
