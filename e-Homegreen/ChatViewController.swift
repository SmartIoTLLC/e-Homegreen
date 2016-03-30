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

class ChatViewController: UIViewController, UITextViewDelegate, ChatDeviceDelegate, PullDownViewDelegate, UIPopoverPresentationControllerDelegate, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var chatTextField: UITextField!
    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var chatTextView: UITextView!
    var pullDown = PullDownView()
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var chatList:[ChatItem] = []
    
    var rowHeight:[CGFloat] = []
    
    var layout:String = "Portrait"
    
    var isValeryVoiceOn:Bool = true
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    override func viewWillAppear(animated: Bool) {
        self.revealViewController().delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), forBarMetrics: UIBarMetrics.Default)
        
        //        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        chatTextView.delegate = self
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.cornerRadius = 5
        chatTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        
        calculateHeight()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        // Do any additional setup after loading the view.
        
        pullDown = PullDownView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64))
        //                pullDown.scrollsToTop = false
        self.view.addSubview(pullDown)
        pullDown.setContentOffset(CGPointMake(0, self.view.frame.size.height - 2), animated: false)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        adjustScrollInsetsPullDownViewAndBackgroudImage()
        
    }
    
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            chatTextView.userInteractionEnabled = true
            chatTableView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            self.view.endEditing(true)
            chatTextView.userInteractionEnabled = false
            chatTableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if(position == FrontViewPosition.Left) {
            chatTextView.userInteractionEnabled = true
            chatTableView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            self.view.endEditing(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            chatTextView.userInteractionEnabled = false
            chatTableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggleAnimated(true)
        }
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(sidebarMenuOpen == true){
            return nil
        } else {
            return indexPath
        }
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        pullDown.drawMenu(filterParametar)
        chatTableView.reloadData()
    }
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChatViewController.refreshLocalParametars), name: NotificationKey.RefreshFilter, object: nil)
    }
    
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshFilter, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
        refreshLocalParametars()
        addObservers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
        stopTextToSpeech()
    }
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Chat)
    func pullDownSearchParametars(filterItem: FilterItem) {
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Chat)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        chatTableView.reloadData()
    }
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
    }
    func adjustScrollInsetsPullDownViewAndBackgroudImage() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            print(self.view.frame.size.width)
            print(self.view.frame.size.height)
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
            
        } else {
            var rect = self.pullDown.frame
            pullDown.removeFromSuperview()
            print(self.view.frame.size.width)
            print(self.view.frame.size.height)
            rect.size.width = self.view.frame.size.width
            rect.size.height = self.view.frame.size.height
            pullDown.frame = rect
            pullDown = PullDownView(frame: rect)
            pullDown.customDelegate = self
            self.view.addSubview(pullDown)
            pullDown.setContentOffset(CGPointMake(0, rect.size.height - 2), animated: false)
            //  This is from viewcontroller superclass:
//            backgroundImageView.frame = CGRectMake(0, 0, Common.screenWidth , Common.screenHeight-64)
        }
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            layout = "Landscape"
        }else{
            layout = "Portrait"
        }
        chatTableView.reloadData()
        pullDown.drawMenu(filterParametar)
    }
    @IBOutlet weak var controlValleryVoice: UIButton!
    @IBAction func controlValleryVOice(sender: AnyObject) {
        stopTextToSpeech()
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
    
    let synth = AVSpeechSynthesizer()
    
    func textToSpeech(text:String) {
        let utterance = AVSpeechUtterance(string: text)
        synth.speakUtterance(utterance)
        //        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
    }
    
    func stopTextToSpeech() {
        synth.stopSpeakingAtBoundary(.Word)
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
            stopTextToSpeech()
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
        if let scene = object as? Scene {
            let command = handler.getCommand(message)
            setCommand(command, object:scene)
        }
        if let sequence = object as? Sequence {
            let command = handler.getCommand(message)
            setCommand(command, object:sequence)
        }
        if let event = object as? Event {
            let command = handler.getCommand(message)
            setCommand(command, object:event)
        }
    }
    func setCommand(command:ChatCommand, object:AnyObject) {
        //   Set scene
        if command == .SetScene {
            if let scene = object as? Scene {
                let address = [UInt8(Int(scene.gateway.addressOne)),UInt8(Int(scene.gateway.addressTwo)),UInt8(Int(scene.address))]
                SendingHandler.sendCommand(byteArray: Function.setScene(address, id: Int(scene.sceneId)), gateway: scene.gateway)
                refreshChatListWithAnswer("scene was set", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Run event
        if command == .RunEvent {
            if let event = object as? Event {
                let address = [UInt8(Int(event.gateway.addressOne)),UInt8(Int(event.gateway.addressTwo)),UInt8(Int(event.address))]
                SendingHandler.sendCommand(byteArray: Function.runEvent(address, id: UInt8(Int(event.eventId))), gateway: event.gateway)
                refreshChatListWithAnswer("event was ran", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Cancel event
        if command == .CancelEvent {
            if let event = object as? Event {
                let address = [UInt8(Int(event.gateway.addressOne)),UInt8(Int(event.gateway.addressTwo)),UInt8(Int(event.address))]
                SendingHandler.sendCommand(byteArray: Function.cancelEvent(address, id: UInt8(Int(event.eventId))), gateway: event.gateway)
                refreshChatListWithAnswer("event was canceled", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Start sequence
        if command == .StartSequence {
            if let sequence = object as? Sequence {
                let address = [UInt8(Int(sequence.gateway.addressOne)),UInt8(Int(sequence.gateway.addressTwo)),UInt8(Int(sequence.address))]
                SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequence.sequenceId), cycle: UInt8(Int(sequence.sequenceCycles))), gateway: sequence.gateway)
                refreshChatListWithAnswer("sequence was started", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Stop sequence
        if command == .StopSequence {
            if let sequence = object as? Sequence {
                let address = [UInt8(Int(sequence.gateway.addressOne)),UInt8(Int(sequence.gateway.addressTwo)),UInt8(Int(sequence.address))]
                SendingHandler.sendCommand(byteArray: Function.setSequence(address, id: Int(sequence.sequenceId), cycle: 0xEF), gateway: sequence.gateway)
                refreshChatListWithAnswer("sequence was stopped", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
    }
    
    func commandWasSent(command:ChatCommand, deviceType:String) -> String {
        var array = ["Command was sent...", "Your wish is my command.", "As you wish.", "I'll do it.", "It is done.", "Whatever you want.", "Consider it done."]
        switch command {
        case .TurnOnDevice:
            if deviceType == ControlType.Dimmer || deviceType == ControlType.Relay {
                array.append("Device was turned on.")
            }
            if deviceType == ControlType.Curtain {
                array.append("Curtain was turned on.")
            }
            if deviceType == ControlType.Climate {
                array.append("Climate was turned on.")
                array.append("Hvac was turned on.")
            }
        case.TurnOffDevice:
            if deviceType == ControlType.Dimmer || deviceType == ControlType.Relay {
                array.append("Device was turned off.")
            }
            if deviceType == ControlType.Curtain {
                array.append("Curtain was turned off.")
            }
            if deviceType == ControlType.Climate {
                array.append("Climate was turned off.")
                array.append("Hvac was turned off.")
            }
        case .DimDevice:
            if deviceType == ControlType.Dimmer {
                array.append("Device was dimmed.")
            }
        default: break
        }
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        if randomIndex < array.count {
            return array[randomIndex]
        }
        return "\u{1f601}"
    }
    func sendCommand(command:ChatCommand, forDevice device:Device, withDimming dimValue:Int) {
        if command == .TurnOnDevice {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            if device.controlType == ControlType.Dimmer {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Relay {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Curtain {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Climate {
                SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0xFF), gateway: device.gateway)
            }
//            refreshChatListWithAnswer("The command for turning on for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: isValeryVoiceOn)
            refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
        } else if command == .TurnOffDevice {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            if device.controlType == ControlType.Dimmer {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Relay {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Curtain {
                SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Climate {
                SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0x00), gateway: device.gateway)
            }
//            refreshChatListWithAnswer("The command for turning off for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: isValeryVoiceOn)
            refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
        } else if command == .DimDevice {
            if dimValue != -1 {
                let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
                if device.controlType == ControlType.Dimmer {
                    SendingHandler.sendCommand(byteArray: Function.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: UInt8(dimValue), delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
//                    refreshChatListWithAnswer("The command for dimming to \(dimValue) for device \(device.name) was sent to \(device.gateway.name)", isValeryVoiceOn: isValeryVoiceOn)
                    refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("Device is not of dimmer type.", isValeryVoiceOn: isValeryVoiceOn)
                }
            } else {
                refreshChatListWithAnswer("Couldn't find value to dim device.", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
    }
    
    func findCommand(message:String) {
        let helper = ChatHandler()
        let command = helper.getCommand(message) // treba
        let typeOfControl = helper.getTypeOfControl(command)
        let itemsArray = helper.getItemByName(typeOfControl, message: message) // treba
        if let zone:Zone = helper.getLevel(message) {
            print(zone.name)
        }
        if command != .Failed {
            if typeOfControl == "" {
                
            }
            if command == .TurnOnDevice || command == .TurnOffDevice || command == .DimDevice || command == .SetScene || command == .RunEvent || command == .StartSequence || command == .CancelEvent || command == .StopSequence {
                if itemsArray.count >= 0 {
                    if itemsArray.count == 1 {
                        if let device = itemsArray[0] as? Device {
                            sendCommand(command, forDevice: device, withDimming: helper.getValueForDim(message, withDeviceName: device.name))
                        }
                        if let scene = itemsArray[0] as? Scene {
                            setCommand(command, object:scene)
                        }
                        if let sequence = itemsArray[0] as? Sequence {
                            setCommand(command, object:sequence)
                        }
                        if let event = itemsArray[0] as? Event {
                            setCommand(command, object:event)
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
                        //   Ther are no devices, events, scenes, sequences... with that name
//                        refreshChatListWithAnswer(questionNotUnderstandable(), isValeryVoiceOn: isValeryVoiceOn)
                        refreshChatListWithAnswer(nothingFound(), isValeryVoiceOn: isValeryVoiceOn)
                    }
                }
            } else if command == .TellMeJoke {
                let joke = TellMeAJokeHandler()
                joke.getJokeCompletion({ (result) -> Void in
                    dispatch_async(dispatch_get_main_queue(),{
                        self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn)
                    })
                })
            } else if command == .CurrentTime {
                dispatch_async(dispatch_get_main_queue(),{
                    let date = NSDate()
                    let formatter = NSDateFormatter()
                    formatter.timeZone = NSTimeZone.localTimeZone()
                    formatter.dateFormat = "HH:mm:ss"
                    self.refreshChatListWithAnswer("It is \(formatter.stringFromDate(date))", isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .HowAreYou {
                dispatch_async(dispatch_get_main_queue(),{
                    self.refreshChatListWithAnswer(self.answerOnHowAreYou(), isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .ILoveYou {
                dispatch_async(dispatch_get_main_queue(),{
                    self.refreshChatListWithAnswer(self.answerOnILoveYou(), isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .BestDeveloper {
                dispatch_async(dispatch_get_main_queue(),{
                    self.refreshChatListWithAnswer("One whose work you don't notice!", isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .ListAllCommands {
                var answer = "These are all commands:\n"
                for command in helper.CHAT_COMMANDS.keys {
                    answer = answer + "\(command) for \(helper.CHAT_COMMANDS[command]!.rawValue.lowercaseString)\n"
                }
                dispatch_async(dispatch_get_main_queue(),{
                    self.refreshChatListWithAnswer(answer, isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .SetLocation {
                let location = helper.getLocation(message)
                if location != "" {
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [location, "All", "All", "All", "All", "All", "All"])
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: nil)
                    refreshChatListWithAnswer("Location was set.", isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("There is no known location with that name.", isValeryVoiceOn: isValeryVoiceOn)
                }
            } else if command == .SetLevel {
                if let zone = helper.getZone(message, isLevel: true) {
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [zone.location!.name!, "\(zone.id)", "All", "All", "\(zone.name)", "All", "All"])
                    NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: nil)
                    refreshChatListWithAnswer("Level was set.", isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("You haven't set which level to set.", isValeryVoiceOn: isValeryVoiceOn)
                }
            } else if command == .SetZone {
                if let zone = helper.getZone(message, isLevel: false) {
                    if let level = DatabaseHandler.returnLevelWithId(Int(zone.level!), location: zone.location!) {
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [zone.location!.name!, "\(level.id)", "\(zone.id)", "All","\(level.name)", "\(zone.name)", "All"])
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKey.RefreshFilter, object: nil)
                        refreshChatListWithAnswer("Zone was set.", isValeryVoiceOn: isValeryVoiceOn)
                    } else {
                        refreshChatListWithAnswer("I'm embarrassed... Couldn't find level for zone...", isValeryVoiceOn: isValeryVoiceOn)
                    }
                } else {
                    refreshChatListWithAnswer("You haven't set zone level to set.", isValeryVoiceOn: isValeryVoiceOn)
                }
            } else if command == .ListDeviceInZone {
                let zone = helper.getZone(message)
                if zone == "" {
                    if filterParametar.location != "All" {
                        if filterParametar.zoneId != 0 {
                            // There is
                            let devices = helper.returnAllDevices(filterParametar, onlyZoneName: "")
                            if devices.count != 0 {
                                var answer = "These are all devices in \(filterParametar.zoneName):\n"
                                for device in devices {
                                    answer = answer + "\(device.name)\n"
                                }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                            } else {
                                refreshChatListWithAnswer("There are no devices in zone.", isValeryVoiceOn: isValeryVoiceOn)
                            }
                        } else {
                            // There is no zone but there is location (there could be more locations)
                            refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        }
                    } else {
                        // There is no location
                        refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        // testiraj zone!
                    }
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllDevices(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all devices in \(zone):\n"
                        for device in devices {
                            answer = answer + "\(device.name)\n"
                        }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                    } else {
                        refreshChatListWithAnswer("There are no devices in zone.", isValeryVoiceOn: isValeryVoiceOn)
                    }
                }
            } else if command == .ListSceneInZone {
                let zone = helper.getZone(message)
                if zone == "" {
                    if filterParametar.location != "All" {
                        if filterParametar.zoneId != 0 {
                            // There is
                            let devices = helper.returnAllScenes(filterParametar, onlyZoneName: "")
                            if devices.count != 0 {
                                var answer = "These are all devices in \(filterParametar.zoneName):\n"
                                for device in devices {
                                    answer = answer + "\(device.sceneName)\n"
                                }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                            } else {
                                refreshChatListWithAnswer("There are no scenes in zone.", isValeryVoiceOn: isValeryVoiceOn)
                            }
                        } else {
                            // There is no zone but there is location (there could be more locations)
                            refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        }
                    } else {
                        // There is no location
                        refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        // testiraj zone!
                    }
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllScenes(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all scenes in \(zone):\n"
                        for device in devices {
                            answer = answer + "\(device.sceneName)\n"
                        }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                    } else {
                        refreshChatListWithAnswer("There are no scenes in zone.", isValeryVoiceOn: isValeryVoiceOn)
                    }
                }
            } else if command == .ListEventsInZone {
                let zone = helper.getZone(message)
                if zone == "" {
                    if filterParametar.location != "All" {
                        if filterParametar.zoneId != 0 {
                            // There is
                            let devices = helper.returnAllEvents(filterParametar, onlyZoneName: "")
                            if devices.count != 0 {
                                var answer = "These are all events in \(filterParametar.zoneName):\n"
                                for device in devices {
                                    answer = answer + "\(device.eventName)\n"
                                }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                            } else {
                                refreshChatListWithAnswer("There are no events in zone.", isValeryVoiceOn: isValeryVoiceOn)
                            }
                        } else {
                            // There is no zone but there is location (there could be more locations)
                            refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        }
                    } else {
                        // There is no location
                        refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        // testiraj zone!
                    }
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllEvents(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all events in \(zone):\n"
                        for device in devices {
                            answer = answer + "\(device.eventName)\n"
                        }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                    } else {
                        refreshChatListWithAnswer("There are no events in zone.", isValeryVoiceOn: isValeryVoiceOn)
                    }
                }
            } else if command == .ListSequenceInZone {
                let zone = helper.getZone(message)
                if zone == "" {
                    if filterParametar.location != "All" {
                        if filterParametar.zoneId != 0 {
                            // There is
                            let devices = helper.returnAllSequences(filterParametar, onlyZoneName: "")
                            if devices.count != 0 {
                                var answer = "These are all sequences in \(zone):\n"
                                for (index, device) in devices.enumerate() {
                                    print(index)
                                    answer = answer + "\(device.sequenceName)\n"
                                }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                            } else {
                                refreshChatListWithAnswer("There are no sequences in zone.", isValeryVoiceOn: isValeryVoiceOn)
                            }
                        } else {
                            // There is no zone but there is location (there could be more locations)
                            refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        }
                    } else {
                        // There is no location
                        refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn)
                        // testiraj zone!
                    }
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllSequences(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all sequences in \(zone):\n"
                        for device in devices {
                            answer = answer + "\(device.sequenceName)\n"
                        }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                    } else {
                        refreshChatListWithAnswer("There are no sequences in zone.", isValeryVoiceOn: isValeryVoiceOn)
                    }
                }
            } else if command == .AnswerMe {
                let answ = AnswersHandler()
                answ.getAnswerComplition(chatTextView.text!, completion: { (result) -> Void in
                    if result != ""{
                        dispatch_async(dispatch_get_main_queue(),{
                            self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn)
                        })
                    }else{
                        dispatch_async(dispatch_get_main_queue(),{
                            self.refreshChatListWithAnswer(self.questionNotUnderstandable(), isValeryVoiceOn:self.isValeryVoiceOn)
                        })
                    }
                    
                })
            } else {
                //   Sorry but there are no devices with that name
                //   Maybe new command?
                refreshChatListWithAnswer(questionNotUnderstandable(), isValeryVoiceOn: isValeryVoiceOn)
            }
        } else {
            refreshChatListWithAnswer(questionNotUnderstandable(), isValeryVoiceOn: isValeryVoiceOn)
        }
    }
    
    func questionNotUnderstandable() -> String {
        let array = ["I didn't understand that.", "Please be more specific.", "You were saying...", "Sorry, I didn't get that. ", "I'm not sure I understand.", "I'm afraid I don't know the answer to that.", "I don't know what do you want.", "Command is not clear."]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        if randomIndex < array.count {
            return array[randomIndex]
        }
        return "I'm not sure I understand."
    }
    func answerOnILoveYou() -> String {
        let array = ["\u{1f60d}", "I love you too \u{1f60d}", "\u{1f618}", "I love myself too \u{2764}", "\u{2764}"]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        if randomIndex < array.count {
            return array[randomIndex]
        } else {
            return ""
        }
    }
    func answerOnHowAreYou() -> String {
        let array = ["I'm fine, thank you for asking.", "You are so kind.", "I am happy.", "I have a doubt... I don't know if I am just fine or super fine.", "You are more important!", "I am asking you!", "\u{1f600}", "\u{1f601}", "\u{1f603}", "\u{1f609}", "\u{1f600}", "\u{1f601}", "\u{1f603}", "\u{1f609}"]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        if randomIndex < array.count {
            return array[randomIndex]
        }
        return "\u{1f601}"
    }
    func nothingFound() -> String {
        let array = ["Couldn't find something to control...", "Nothing found...", "Please be more specific.", "I don't undersrtand."]
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        if randomIndex < array.count {
            return array[randomIndex]
        }
        return "\u{1f601}"
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
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.oneTap(_:)))
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.longPress(_:)))
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