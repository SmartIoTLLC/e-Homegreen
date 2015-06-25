//
//  PullDownView.swift
//  NewProject
//
//  Created by Vladimir on 6/16/15.
//  Copyright (c) 2015 nswebdevolopment. All rights reserved.
//

import UIKit

class PullDownView: UIScrollView {
    
    //    var table:UITableView = UITableView()
    //
    //    var levelList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    //    var zoneList:[String] = ["Zone 1", "Zone 2", "Zone 3", "All"]
    //    var categoryList:[String] = ["Category 1", "Category 2", "Category 3", "All"]
    //    var tableList:[String] = ["Level 1", "Level 2", "Level 3", "All"]
    
    //    var senderButton:UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        
        
        self.pagingEnabled = true
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        self.backgroundColor = UIColor.clearColor()
        var pixelOutside:CGFloat = 2
        self.contentSize = CGSizeMake(320, frame.size.height * 2 - pixelOutside)
        
        var redArea:UIView = UIView(frame: CGRectMake(0, 0, frame.size.width, frame.size.height))
        redArea.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        self.addSubview(redArea)
        
        //  RGB za pulldown ruckicu je R: 128/255 G: 128/255 B: 128/255
        
        var pullView:UIImageView = UIImageView(frame: CGRectMake(frame.size.width/2 - 30, frame.size.height, 60, 30))
        pullView.image = UIImage(named: "pulldown")
        //        pullView.backgroundColor = UIColor.whiteColor()
        self.addSubview(pullView)
        
        pullView.userInteractionEnabled = true
        var tapRec = UITapGestureRecognizer()
        tapRec.addTarget(self, action: "tap")
        pullView.addGestureRecognizer(tapRec)
        
        var grayBottomLine = UIView(frame:CGRectMake(0, frame.size.height-2, frame.size.width, 2))
        grayBottomLine.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        self.addSubview(grayBottomLine)
        

        
        
    }
    
    func tap(){
       self.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    
    
    
    

    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        
        if point.y < self.frame.size.height + 40 && point.y > self.frame.size.height{
            if point.x < frame.size.width/2 - 30 || point.x > frame.size.width/2 + 30 {
                return nil
            }
            
        }
        
        if point.y > self.frame.size.height + 30 {
            //            if point.x < 100 || point.x > 150 {
            return nil
            //            }
            
        }
        
        
        return super.hitTest(point, withEvent: event)
    }
    
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
