//
//  ScanDevicesViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 9/15/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanDevicesViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var rangeFrom: UITextField!
    @IBOutlet weak var rangeTo: UITextField!
    
    @IBOutlet weak var deviceTableView: UITableView!
    
    
    func endEditingNow(){
        rangeFrom.resignFirstResponder()
        rangeTo.resignFirstResponder()        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let item = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("endEditingNow") )
        var toolbarButtons = [item]
        
        keyboardDoneButtonView.setItems(toolbarButtons, animated: false)
        
        rangeFrom.inputAccessoryView = keyboardDoneButtonView
        rangeTo.inputAccessoryView = keyboardDoneButtonView


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func findDevice(sender: AnyObject) {
//        if rangeFrom.text != "" && rangeTo.text != "" {
//            if let numberOne = rangeFrom.text.toInt(), let numberTwo = rangeTo.text.toInt() {
//                if numberTwo >= numberOne {
//                    fromAddress = numberOne
//                    toAddress = numberTwo
//                    searchForDeviceWithId = numberOne
//                    timesRepeatedCounter = 0
//                    loader.showActivityIndicator(self.view)
//                    searchDeviceTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfGatewayDidGetDevice:", userInfo: searchForDeviceWithId, repeats: false)
//                    var address = [UInt8(Int(gateway!.addressOne)), UInt8(Int(gateway!.addressTwo)), UInt8(searchForDeviceWithId!)]
//                    SendingHandler(byteArray: Function.searchForDevices(address), gateway: gateway!)
//                }
//            }
//        }
    }
    
    @IBAction func deleteAll(sender: AnyObject) {
        //        for var item = 0; item < devices.count; item++ {
        //            if devices[item].gateway.objectID == gateway!.objectID {
        //                appDel.managedObjectContext!.deleteObject(devices[item])
        //            }
        //        }
        //        saveChanges()
        //        NSNotificationCenter.defaultCenter().postNotificationName("refreshDeviceListNotification", object: self, userInfo: nil)
    }

    @IBAction func findNames(sender: AnyObject) {
//        var index:Int
//        if devices.count != 0 {
//            index = 0
//            timesRepeatedCounter = 0
//            deviceNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkIfDeviceDidGetName:", userInfo: 0, repeats: false)
//            sendCommandForFindingName(index: 0)
//        }
    }
    
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //        if tableView == deviceTableView {
    //        if let cell = tableView.dequeueReusableCellWithIdentifier("scanCell") as? ScanCell {
    //            cell.backgroundColor = UIColor.clearColor()
    //            cell.lblRow.text = "\(indexPath.row+1)."
    //            cell.lblDesc.text = "\(devices[indexPath.row].name)"
    //            cell.lblAddress.text = "Address: \(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressOne))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].gateway.addressTwo))):\(returnThreeCharactersForByte(Int(devices[indexPath.row].address))), Channel: \(devices[indexPath.row].channel)"
    //            cell.lblType.text = "Type: \(devices[indexPath.row].type)"
    //            cell.isEnabledSwitch.on = devices[indexPath.row].isEnabled.boolValue
    //            cell.isEnabledSwitch.tag = indexPath.row
    //            cell.isEnabledSwitch.addTarget(self, action: "changeValueEnable:", forControlEvents: UIControlEvents.ValueChanged)
    //            cell.isVisibleSwitch.on = devices[indexPath.row].isVisible.boolValue
    //            cell.isVisibleSwitch.tag = indexPath.row
    //            cell.isVisibleSwitch.addTarget(self, action: "changeValueVisible:", forControlEvents: UIControlEvents.ValueChanged)
    //
    //            return cell
    //        }
    //        }
    //        if tableView == sceneTableView {
    //            if let cell = tableView.dequeueReusableCellWithIdentifier("sceneCell") as? SceneCell {
    //                if choosedTab == .Scenes {
    //                    cell.backgroundColor = UIColor.clearColor()
    //                    cell.labelID.text = "\(choosedTabArray[indexPath.row].sceneId)"
    //                    cell.labelName.text = "\(choosedTabArray[indexPath.row].sceneName)"
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageOne) {
    //                        cell.imageOne.image = sceneImage
    //                    }
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sceneImageTwo) {
    //                        cell.imageTwo.image = sceneImage
    //                    }
    //                } else if choosedTab == .Events {
    //                    cell.backgroundColor = UIColor.clearColor()
    //                    cell.labelID.text = "\(choosedTabArray[indexPath.row].eventId)"
    //                    cell.labelName.text = "\(choosedTabArray[indexPath.row].eventName)"
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageOne) {
    //                        cell.imageOne.image = sceneImage
    //                    }
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].eventImageTwo) {
    //                        cell.imageTwo.image = sceneImage
    //                    }
    //                } else if choosedTab == .Sequences {
    //                    cell.backgroundColor = UIColor.clearColor()
    //                    cell.labelID.text = "\(choosedTabArray[indexPath.row].sequenceId)"
    //                    cell.labelName.text = "\(choosedTabArray[indexPath.row].sequenceName)"
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageOne) {
    //                        cell.imageOne.image = sceneImage
    //                    }
    //                    if let sceneImage = UIImage(data: choosedTabArray[indexPath.row].sequenceImageTwo) {
    //                        cell.imageTwo.image = sceneImage
    //                    }
    //                }
    //                return cell
    //            }
    //        }
            let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
            cell.textLabel?.text = "dads"
            return cell
    
        }

        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 5
        }

    


}
