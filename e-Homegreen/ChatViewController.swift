//
//  ChatViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
//import CoreData
import AVFoundation

struct ChatItem {
    var text:String
    var type:BubbleDataType
}

class ChatViewController: CommonViewController, UITextFieldDelegate, ChatDeviceDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var chatTextField: UITextField!
    
    //    var appDel:AppDelegate!
    //    var devices:[Device] = []
    //    var scenes:[Scene] = []
    //    var securities:[Security] = []
    //    var timers:[Timer] = []
    //    var sequences:[Sequence] = []
    //    var flags:[Flag] = []
    //    var error:NSError? = nil
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var chatList:[ChatItem] = []
    
    var rowHeight:[CGFloat] = []
    
    var layout:String = "Portrait"
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        chatTextField.delegate = self
        
        calculateHeight()
        
        chatTableView.estimatedRowHeight = 50
        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
    }
    
    func textToSpeech(text:String) {
        let utterance = AVSpeechUtterance(string: text)
        let synth = AVSpeechSynthesizer()
        synth.speakUtterance(utterance)
        //        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
    }
    
    func searchForTermInString (text:String, searchTerm:String) {
        let string:NSString = text.lowercaseString
        let searchTerm = searchTerm.lowercaseString
        let trimmedString = string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        print(string)
        print(trimmedString)
        let range = string.rangeOfString(searchTerm)
        print(string.componentsSeparatedByString(searchTerm).count-1)
        if string.rangeOfString(searchTerm).location != NSNotFound {
            print("exists")
            print(range.location)
            print(range.location+range.length-1)
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            layout = "Landscape"
        }else{
            layout = "Portrait"
        }
        chatTableView.reloadData()
    }
    
    @IBAction func sendBtnAction(sender: AnyObject) {
        if  chatTextField.text != ""{
            chatList.append(ChatItem(text: chatTextField.text!, type: .Mine))
            calculateHeight()
            chatTableView.reloadData()
            chatTextField.resignFirstResponder()
            
            findCommand((chatTextField.text?.lowercaseString)!)
//            if let _ = findCommand((chatTextField.text?.lowercaseString)!) {
//                showSuggestion().delegate = self
//            }else{
//                if chatTextField.text?.lowercaseString == "tell me a joke"{
//                    let joke = TellMeAJokeHandler()
//                    joke.getJokeCompletion({ (result) -> Void in
//                        dispatch_async(dispatch_get_main_queue(),{
//                            self.refreshChatListWithAnswer(result, isValeryVoiceOn:true)
//                        })
//                    })
//                }else{
//                    let answ = AnswersHandler()
//                    answ.getAnswerComplition(chatTextField.text!, completion: { (result) -> Void in
//                        if result != ""{
//                            dispatch_async(dispatch_get_main_queue(),{
//                                self.refreshChatListWithAnswer(result, isValeryVoiceOn:true)
//                            })
//                        }else{
//                            dispatch_async(dispatch_get_main_queue(),{
//                            self.refreshChatListWithAnswer("Wrong question!!!", isValeryVoiceOn:true)
//                            })
//                        }
//                        
//                    })
//                }
//            }
            chatTextField.text = ""
        }
    }
    
    func refreshChatListWithAnswer (text: String, isValeryVoiceOn:Bool) {
        self.chatList.append(ChatItem(text: text, type: .Opponent))
        self.calculateHeight()
        self.chatTableView.reloadData()
        if isValeryVoiceOn {
            self.textToSpeech(text)
        }
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
        }
    }
    
    func choosedDevice(device: String) {
        
    }
    
    func sendCommand(command:Int, forDevice device:Device, withDimming dimValue:Int) {
        if command == 0 {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            if device.type == "Dimmer" {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.type == "curtainsRelay" || device.type == "appliance" {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.type == "curtainsRS485" {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.type == "hvac" {
                SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0xFF), gateway: device.gateway)
            }
            refreshChatListWithAnswer("The command for turning on for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: true)
        } else if command == 1 {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            if device.type == "Dimmer" {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.type == "curtainsRelay" || device.type == "appliance" {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.type == "curtainsRS485" {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.type == "hvac" {
                SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0x00), gateway: device.gateway)
            }
            refreshChatListWithAnswer("The command for turning off for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: true)
        } else if command == 2 {
            if dimValue != -1 {
                let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
                if device.type == "Dimmer" {
                    SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: UInt8(dimValue), delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
                    refreshChatListWithAnswer("The command for dimming to \(dimValue) for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: true)
                }
            }
        }
    }
    
    func findCommand(message:String) {
        let helper = ChatHandler()
        let command = helper.getCommand(message)
        let typeOfControl = helper.getTypeOfControl(command)
        let itemsArray = helper.getItemByName(typeOfControl, message: message)
        
        if itemsArray.count >= 0 {
            if itemsArray.count == 1 {
                if let device = itemsArray[0] as? Device {
                    sendCommand(command, forDevice: device, withDimming: helper.getValueForDim(message))
                }
                if let scene = itemsArray[0] as? Scene {
                    
                }
                if let sequence = itemsArray[0] as? Sequence {
                    
                }
                if let event = itemsArray[0] as? Event {
                    
                }
            } else {
                //   There are more devices than just a one
            }
        } else {
            //   Sorry but there are no devices with that name
            //   Maybe new command?
            
        }
    }
    
    func calculateHeight(){
        rowHeight = []
        for item in chatList{
            let chatBubbleDataMine = ChatBubbleData(text: item.text, image: nil, date: NSDate(), type: item.type)
            let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
            rowHeight.append(CGRectGetMaxY(chatBubbleMine.frame))
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let duration:NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        self.bottomConstraint.constant = keyboardFrame.size.height
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        var info = notification.userInfo!
        let duration:NSTimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        
        self.bottomConstraint.constant = 0
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension ChatViewController: UITableViewDelegate {
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //        if let cell = tableView.dequeueReusableCellWithIdentifier("chatCommandCell") as? ChatCommandCell {
        //
        //            var chatBubbleDataMine = ChatBubbleData(text: chatList[indexPath.row].text, image: nil, date: NSDate(), type: chatList[indexPath.row].type)
        //            var chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5)
        //
        //            cell.backgroundColor = UIColor.clearColor()
        //
        //            cell.contentView.addSubview(chatBubbleMine)
        //            return cell
        //        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        
        let chatBubbleDataMine = ChatBubbleData(text: chatList[indexPath.row].text, image: nil, date: NSDate(), type: chatList[indexPath.row].type)
        let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
        
        cell.backgroundColor = UIColor.clearColor()
        
        cell.contentView.addSubview(chatBubbleMine)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return rowHeight[indexPath.row]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
}

class ChatAnswerCell: UITableViewCell {
    @IBOutlet weak var lblAnswerLIne: UILabel!
    
}
class ChatCommandCell: UITableViewCell {
    
}