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
        
        var grayBottomLine = UIView(frame:CGRectMake(0, frame.size.height-2, frame.size.width, 2))
        grayBottomLine.backgroundColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1.0)
        self.addSubview(grayBottomLine)
        
        //        var levelLabel:UILabel = UILabel(frame: CGRectMake(10, 30, 100, 40))
        //        levelLabel.text = "LVL"
        //        levelLabel.textColor = UIColor.whiteColor()
        //        self.addSubview(levelLabel)
        //
        //        var zoneLabel:UILabel = UILabel(frame: CGRectMake(10, 80, 100, 40))
        //        zoneLabel.text = "Zone"
        //        zoneLabel.textColor = UIColor.whiteColor()
        //        self.addSubview(zoneLabel)
        //
        //        var categoryLabel:UILabel = UILabel(frame: CGRectMake(10, 130, 100, 40))
        //        categoryLabel.text = "Category"
        //        categoryLabel.textColor = UIColor.whiteColor()
        //        self.addSubview(categoryLabel)
        
        //        var levelButton:UIButton = UIButton(frame: CGRectMake(110, 30, 150, 40))
        //        levelButton.backgroundColor = UIColor.grayColor()
        //        levelButton.titleLabel?.tintColor = UIColor.whiteColor()
        //        levelButton.setTitle("All", forState: UIControlState.Normal)
        //        levelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        //        levelButton.layer.cornerRadius = 5
        //        levelButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        //        levelButton.layer.borderWidth = 0.5
        //        levelButton.addTarget(self, action: "menuLevel:", forControlEvents: UIControlEvents.TouchUpInside)
        //        levelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        //        self.addSubview(levelButton)
        //
        //        var zoneButton:UIButton = UIButton(frame: CGRectMake(110, 80, 150, 40))
        //        zoneButton.backgroundColor = UIColor.grayColor()
        //        zoneButton.titleLabel?.tintColor = UIColor.whiteColor()
        //        zoneButton.setTitle("All", forState: UIControlState.Normal)
        //        zoneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        //        zoneButton.layer.cornerRadius = 5
        //        zoneButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        //        zoneButton.layer.borderWidth = 0.5
        //        zoneButton.addTarget(self, action: "menuZone:", forControlEvents: UIControlEvents.TouchUpInside)
        //        zoneButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        //        self.addSubview(zoneButton)
        //
        //        var categoryButton:UIButton = UIButton(frame: CGRectMake(110, 130, 150, 40))
        //        categoryButton.backgroundColor = UIColor.grayColor()
        //        categoryButton.titleLabel?.tintColor = UIColor.whiteColor()
        //        categoryButton.setTitle("All", forState: UIControlState.Normal)
        //        categoryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        //        categoryButton.layer.cornerRadius = 5
        //        categoryButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        //        categoryButton.layer.borderWidth = 0.5
        //        categoryButton.addTarget(self, action: "menuCategory:", forControlEvents: UIControlEvents.TouchUpInside)
        //        categoryButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        //        self.addSubview(categoryButton)
        //
        //        table.delegate = self
        //        table.dataSource = self
        //        table.frame = CGRectMake(0, 0, 150, 150)
        //        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        //        table.hidden = true
        //        self.addSubview(table)
        
        
    }
    
    //    func menuLevel(sender : UIButton){
    //        senderButton = sender
    //        table.frame = CGRectMake(110, 70, 150, 160)
    //        table.hidden = false
    //        tableList.removeAll(keepCapacity: false)
    //        tableList = levelList
    //        table.reloadData()
    //    }
    //
    //    func menuZone(sender : UIButton){
    //        senderButton = sender
    //        table.frame = CGRectMake(110, 120, 150, 160)
    //        table.hidden = false
    //        tableList.removeAll(keepCapacity: false)
    //        tableList = zoneList
    //        table.reloadData()
    //
    //    }
    //
    //    func menuCategory(sender : UIButton){
    //        senderButton = sender
    //        table.frame = CGRectMake(110, 170, 150, 160)
    //        table.hidden = false
    //        tableList.removeAll(keepCapacity: false)
    //        tableList = categoryList
    //        table.reloadData()
    //    }
    
    
    
    
    
    //    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
    ////        if let tableString = tableList[indexPath.row] as String {
    //            cell.textLabel?.text = tableList[indexPath.row]
    ////        }
    //        return cell
    //    }
    //
    //    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //
    //        return tableList.count
    //    }
    //
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        senderButton!.setTitle(tableList[indexPath.row], forState: UIControlState.Normal)
    //        table.hidden = true
    //    }
    
    
    
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
