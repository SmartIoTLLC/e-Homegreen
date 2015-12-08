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

class ChatViewController: CommonViewController, UITextViewDelegate, ChatDeviceDelegate, PullDownViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var chatTextField: UITextField!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var chatTextView: UITextView!
    var pullDown = PullDownView()
    
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
    
    var isValeryVoiceOn:Bool = true
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        chatTextView.delegate = self
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.cornerRadius = 5
        chatTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        calculateHeight()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        locationSearchText = LocalSearchParametar.getLocalParametar("Chat")
        
    }
    func refreshLocalParametars() {
        locationSearchText = LocalSearchParametar.getLocalParametar("Chat")
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshLocalParametars", name: NotificationKey.RefreshFilter, object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshLocalParametars()
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }
    var locationSearch:String = "All"
    var zoneSearch:String = "All"
    var levelSearch:String = "All"
    var categorySearch:String = "All"
    var locationSearchText = ["", "", "", ""]
    func pullDownSearchParametars(gateway: String, level: String, zone: String, category: String) {
        (locationSearch, levelSearch, zoneSearch, categorySearch) = (gateway, level, zone, category)
        chatTableView.reloadData()
        LocalSearchParametar.setLocalParametar("Scenes", parametar: [locationSearch, levelSearch, zoneSearch, categorySearch])
    }
    override func viewWillLayoutSubviews() {
        //        popoverVC.dismissViewControllerAnimated(true, completion: nil)
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            
        } else {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
        }
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            layout = "Landscape"
        }else{
            layout = "Portrait"
        }
        chatTableView.reloadData()
        pullDown.drawMenu(locationSearchText[0], level: locationSearchText[1], zone: locationSearchText[2], category: locationSearchText[3])
    }
    @IBOutlet weak var controlValleryVoice: UIButton!
    @IBAction func controlValleryVOice(sender: AnyObject) {
        if isValeryVoiceOn {
            controlValleryVoice.setImage(UIImage(named: "mute"), forState: .Normal)
            isValeryVoiceOn = false
        } else {
            controlValleryVoice.setImage(UIImage(named: "unmute"), forState: .Normal)
            isValeryVoiceOn = true
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if newFrame.size.height + 60 < 150{
            textView.frame = newFrame
            viewHeight.constant = textView.frame.size.height + 16
            if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
                self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: false)
            }
        }
        
        
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
    
    @IBAction func sendBtnAction(sender: AnyObject) {
        if  chatTextView.text != ""{
            chatList.append(ChatItem(text: chatTextView.text!, type: .Mine))
            calculateHeight()
            chatTableView.reloadData()
            findCommand((chatTextView.text?.lowercaseString)!)
            chatTextView.text = ""
            chatTextView.resignFirstResponder()
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
    
    func choosedDevice(object: AnyObject, message:String) {
        let handler = ChatHandler()
        if let device = object as? Device {
            let command = handler.getCommand(message)
            let dimValue = handler.getValueForDim(message, withDeviceName: device.name)
            sendCommand(command, forDevice: device, withDimming: dimValue)
        }
    }
    func setCommand(command:Int, object:AnyObject) {
        //   Set scene
        if command == 9 {
            if let scene = object as? Scene {
                let address = [UInt8(Int(scene.gateway.addressOne)),UInt8(Int(scene.gateway.addressTwo)),UInt8(Int(scene.address))]
                SendingHandler.sendCommand(byteArray: Function.setScene(address, id: Int(scene.sceneId)), gateway: scene.gateway)
            }
        }
        //   Run event
        if command == 10 {
            if let event = object as? Event {
                let address = [UInt8(Int(event.gateway.addressOne)),UInt8(Int(event.gateway.addressTwo)),UInt8(Int(event.address))]
                SendingHandler.sendCommand(byteArray: Function.runEvent(address, id: UInt8(Int(event.eventId))), gateway: event.gateway)
            }
        }
        //   Cancel event
        if command == 13 {
            if let event = object as? Event {
                let address = [UInt8(Int(event.gateway.addressOne)),UInt8(Int(event.gateway.addressTwo)),UInt8(Int(event.address))]
                SendingHandler.sendCommand(byteArray: Function.cancelEvent(address, id: UInt8(Int(event.eventId))), gateway: event.gateway)
            }
        }
        //   Start sequence
        if command == 11 {
            if let sequence = object as? Sequence {
                let address = [UInt8(Int(sequence.gateway.addressOne)),UInt8(Int(sequence.gateway.addressTwo)),UInt8(Int(sequence.address))]
                SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequence.sequenceId), cycle: UInt8(Int(sequence.sequenceCycles))), gateway: sequence.gateway)
            }
        }
        //   Stop sequence
        if command == 14 {
            if let sequence = object as? Sequence {
                let address = [UInt8(Int(sequence.gateway.addressOne)),UInt8(Int(sequence.gateway.addressTwo)),UInt8(Int(sequence.address))]
                SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequence.sequenceId), cycle: 0xEF), gateway: sequence.gateway)
            }
        }
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
            refreshChatListWithAnswer("The command for turning on for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: isValeryVoiceOn)
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
            refreshChatListWithAnswer("The command for turning off for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: isValeryVoiceOn)
        } else if command == 2 {
            if dimValue != -1 {
                let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
                if device.type == "Dimmer" {
                    SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: UInt8(dimValue), delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
                    refreshChatListWithAnswer("The command for dimming to \(dimValue) for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("Device is not of type dimmer.", isValeryVoiceOn: isValeryVoiceOn)
                }
            }
        }
    }
    func findCommand(message:String) {
        let helper = ChatHandler()
        let command = helper.getCommand(message) // treba
        let typeOfControl = helper.getTypeOfControl(command)
        let itemsArray = helper.getItemByName(typeOfControl, message: message) // treba
        if command != -1 {
            if typeOfControl == "" {
                
            }
            if itemsArray.count >= 0 {
                if itemsArray.count == 1 {
                    if let device = itemsArray[0] as? Device {
                        sendCommand(command, forDevice: device, withDimming: helper.getValueForDim(message, withDeviceName: device.name))
                    }
                    if let scene = itemsArray[0] as? Scene {
                        
                    }
                    if let sequence = itemsArray[0] as? Sequence {
                        
                    }
                    if let event = itemsArray[0] as? Event {
                        
                    }
                } else if itemsArray.count > 1{
                    //   There are more devices than just a one
                    if let devices = itemsArray as? [Device] {
                        showSuggestion(devices, message: message).delegate = self
                    }
                    if let scenes = itemsArray as? [Scene] {
                        showSuggestion(scenes, message: message).delegate = self
                    }
                    if let sequences = itemsArray as? [Sequence] {
                        showSuggestion(sequences, message: message).delegate = self
                    }
                    if let events = itemsArray as? [Event] {
                        showSuggestion(events, message: message).delegate = self
                    }
                } else {
                    //   Ther are no devices with that name
                    if command == 8 {
                        let joke = TellMeAJokeHandler()
                        joke.getJokeCompletion({ (result) -> Void in
                            dispatch_async(dispatch_get_main_queue(),{
                                self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn)
                            })
                        })
                    } else if command == 16 {
                        let answ = AnswersHandler()
                        answ.getAnswerComplition(chatTextView.text!, completion: { (result) -> Void in
                            if result != ""{
                                dispatch_async(dispatch_get_main_queue(),{
                                    self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn)
                                })
                            }else{
                                dispatch_async(dispatch_get_main_queue(),{
                                    self.refreshChatListWithAnswer("Wrong question!!!", isValeryVoiceOn:self.isValeryVoiceOn)
                                })
                            }
                            
                        })
                    } else {
                        refreshChatListWithAnswer("Please specify what do you want me to do.", isValeryVoiceOn: isValeryVoiceOn)
                    }
                }
            } else {
                //   Sorry but there are no devices with that name
                //   Maybe new command?
                refreshChatListWithAnswer("Please specify what do you want me to do.", isValeryVoiceOn: isValeryVoiceOn)
            }
        } else {
            refreshChatListWithAnswer("Please specify what do you want me to do.", isValeryVoiceOn: isValeryVoiceOn)
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
        if chatTextView.text.isEmpty{
            viewHeight.constant = 49
        }
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPointMake(0, self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: false)
        }
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
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        let chatBubbleDataMine = ChatBubbleData(text: chatList[indexPath.row].text, image: nil, date: NSDate(), type: chatList[indexPath.row].type)
        let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
        chatBubbleMine.tag = indexPath.row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "oneTap:")
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "longPress:")
        longPress.minimumPressDuration = 1.0
        chatBubbleMine.addGestureRecognizer(tap)
        chatBubbleMine.addGestureRecognizer(longPress)
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.addSubview(chatBubbleMine)
        return cell
    }
    func oneTap (gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            self.chatTextView.text = chatList[tag].text
        }
    }
    func longPress (gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            if gesture.state == UIGestureRecognizerState.Began {
                chatList.append(ChatItem(text: chatList[tag].text, type: .Mine))
                calculateHeight()
                chatTableView.reloadData()
                findCommand(chatList[tag].text.lowercaseString)
            }
        }
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