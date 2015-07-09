//
//  DatabaseViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class DatabaseViewController: CommonViewController {

    @IBOutlet weak var databaseTable: UITableView!
    var inSocket:InSocket!
    var outSocket:OutSocket!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonConstruct()
        
        inSocket = InSocket()
        outSocket = OutSocket()
        
        for item in Model.sharedInstance.deviceArray {
            databaseArray.append("\(item.name); \(item.address); \(item.channel); \(item.type)")
        }
        
        // Do any additional setup after loading the view.
    }
    var deviceNumber = 0
    var touched = false
    @IBAction func findDevices(sender: AnyObject) {
        if !touched {
            deviceNumber = 0
            for var i:Int = 0; i < 20; i++ {
                var number:NSTimeInterval = NSTimeInterval(i*2)
                deviceNumber = 0
                NSTimer.scheduledTimerWithTimeInterval(number, target: self, selector: "searchIds", userInfo: nil, repeats: false)
            }
            touched = true
        } else {
            databaseArray = []
            for item in Model.sharedInstance.deviceArray {
                databaseArray.append("\(item.name); \(item.address); \(item.channel); \(item.type)")
            }
            databaseTable.reloadData()
        }
    }
    var databaseArray:[String] = []
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func searchIds() {
//        var info:[UInt8] = [0]
//        var byte:[UInt8] = [UInt8](count: info.count+9, repeatedValue: 0)
//        byte[0] = 0xAA
//        byte[1] = UInt8(info.count)
//        byte[2] = 1//adress
//        byte[3] = 0//adress
//        byte[4] = UInt8(deviceNumber)//adress
//        //        byte[2] = 0xFF
//        //        byte[3] = 0xFF
//        //        byte[4] = 0xFF
//        byte[5] = 1//CID1
//        byte[6] = 1//CID2
//        byte[7] = 0
//        byte[8] = chkByte(byte)
//        byte[9] = 16
//        
//        deviceNumber += 1
//        if deviceNumber == 19 {
//                touched = false
//        }
        outSocket.sendByte(Functions().searchForDevices(UInt8(deviceNumber)))
        
    }
    
    func chkByte (array:[UInt8]) -> UInt8 {
        var chk:Int = 0
        for var i = 1; i <= array.count-3; i++ {
            var number = "\(array[i])"
            
            chk = chk + number.toInt()!
        }
        chk = chk%256
        return UInt8(chk)
    }
    
}
extension DatabaseViewController: UITableViewDataSource {
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 44
//    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return databaseArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("databaseCell") as? DatabaseTableViewCell {
            cell.foundItem.text = databaseArray[indexPath.row]
            return cell
            
        }
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        cell.textLabel?.text = "dads"
        return cell
    }
}
extension DatabaseViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
class DatabaseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var foundItem: UILabel!
//    @IBOutlet weak var tableCellTitle: UILabel!
}