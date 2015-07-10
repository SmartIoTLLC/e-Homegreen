//
//  DatabaseViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/16/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class DatabaseViewController: CommonViewController {

    @IBOutlet weak var databaseTable: UITableView!
    var inSocket:InSocket!
    var outSocket:OutSocket!
    var appDel:AppDelegate!
    var devices:[Device] = []
    var error:NSError? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonConstruct()
        
        inSocket = InSocket()
        outSocket = OutSocket()
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        var fetchRequest = NSFetchRequest(entityName: "Device")
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
        println("")
        for item in devices {
            databaseArray.append("\(item.name)")
        }
        
        // Do any additional setup after loading the view.
    }
    var deviceNumber = 0
    var touched = false
    @IBAction func btnRefresTableView(sender: AnyObject) {
//        outSocket.sendByte(Functions().searchForDevices(0x05))
        var fetchRequest = NSFetchRequest(entityName: "Device")
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Device]
        if let results = fetResults {
            devices = results
        } else {
            println("Nije htela...")
        }
        println("")
        databaseArray = []
        for item in devices {
            databaseArray.append("\(item.name); \(item.address); \(item.channel)")
        }
        databaseTable.reloadData()
    }
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
        outSocket.sendByte(Functions().getSensorState(0x05))
        timerSensorNumber = 0
        for i in 0...11 {
            var number:NSTimeInterval = NSTimeInterval(i*2)
            NSTimer.scheduledTimerWithTimeInterval(number, target: self, selector: "getSensorName", userInfo: nil, repeats: false)
//                outSocket.sendByte(Functions().getSensorName(0x05, channel: UInt8(timerSensorNumber)))
        }
        }
    }
    var timerSensorNumber = 0
    func getSensorName () {
        outSocket.sendByte(Functions().getSensorName(0x05, channel: UInt8(timerSensorNumber)))
        timerSensorNumber = timerSensorNumber + 1
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
        outSocket.sendByte(Functions().searchForDevices(UInt8(deviceNumber)))
        deviceNumber += 1
        if deviceNumber == 19 {
            touched = false
        }
        
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