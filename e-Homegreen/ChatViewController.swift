//
//  ChatViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

struct ChatItem {
    var text:String
    var type:BubbleDataType
}

class ChatViewController: PopoverVC, ChatDeviceDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    var sidebarMenuOpen : Bool!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    
    @IBOutlet weak var chatTextView: UITextView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var scrollView = FilterPullDown()
    
    var chatList:[ChatItem] = []
    
    var rowHeight:[CGFloat] = []
    
    var layout:String = "Portrait"
    
    var isValeryVoiceOn:Bool = true
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Chat)
    
    @IBOutlet weak var controlValleryVoice: UIButton!    
    
    let synth = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        self.navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        chatTextView.delegate = self
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.cornerRadius = 5
        chatTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints()
        scrollView.setItem(self.view)
        
        calculateHeight()
        
        self.navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Chat", subtitle: "All All All")
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)

        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        adjustScrollInsetsPullDownViewAndBackgroudImage()
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.chat)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight || UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                revealViewController().rearViewRevealWidth = 200
            }else{
                revealViewController().rearViewRevealWidth = 200
            }
            
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
        }
        
        changeFullScreeenImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        refreshLocalParametars()
        addObservers()
    }
    
    override func viewWillLayoutSubviews() {
        if scrollView.contentOffset.y != 0 {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
        scrollView.bottom.constant = -(self.view.frame.height - 2)
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            headerTitleSubtitleView.setLandscapeTitle()
        }else{
            headerTitleSubtitleView.setPortraitTitle()
        }
        
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func updateSubtitle(_ location: String, level: String, zone: String){
        headerTitleSubtitleView.setTitleAndSubtitle("Chat", subtitle: location + " " + level + " " + zone)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scrollView.setDefaultFilterItem(Menu.chat)
        }
    }
    
    func updateConstraints() {
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1.0, constant: 0.0))
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
            if scrollView.contentOffset.y != 0 {
                let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
                scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullScreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullScreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        chatTableView.reloadData()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        stopTextToSpeech()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
    }
    
    func adjustScrollInsetsPullDownViewAndBackgroudImage() {

        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft || UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
            layout = "Landscape"
        }else{
            layout = "Portrait"
        }
        chatTableView.reloadData()
    }
    
    @IBAction func controlValleryVOice(_ sender: AnyObject) {
        stopTextToSpeech()
        if isValeryVoiceOn {
            controlValleryVoice.setImage(UIImage(named: "mute"), for: UIControlState())
            isValeryVoiceOn = false
        } else {
            controlValleryVoice.setImage(UIImage(named: "unmute"), for: UIControlState())
            isValeryVoiceOn = true
        }
    }
    
    func textToSpeech(_ text:String) {
        let utterance = AVSpeechUtterance(string: text)
        synth.speak(utterance)
    }
    
    func stopTextToSpeech() {
        synth.stopSpeaking(at: .word)
    }
    
    func searchForTermInString (_ text:String, searchTerm:String) {
        let string:NSString = text.lowercased() as NSString
        let searchTerm = searchTerm.lowercased()
        let trimmedString = string.trimmingCharacters(in: CharacterSet.whitespaces)
        print(string)
        print(trimmedString)
        let range = string.range(of: searchTerm)
        print(string.components(separatedBy: searchTerm).count-1)
        if string.range(of: searchTerm).location != NSNotFound {
            print("exists")
            print(range.location)
            print(range.location+range.length-1)
        }
    }
    
    @IBAction func sendBtnAction(_ sender: AnyObject) {
        if  chatTextView.text != ""{
            stopTextToSpeech()
            chatList.append(ChatItem(text: chatTextView.text!, type: .mine))
            calculateHeight()
            chatTableView.reloadData()
            findCommand((chatTextView.text?.lowercased())!)
            chatTextView.text = ""
            chatTextView.resignFirstResponder()
        }
    }
    
    func refreshChatListWithAnswer (_ text: String, isValeryVoiceOn:Bool) {
        self.chatList.append(ChatItem(text: text, type: .opponent))
        self.calculateHeight()
        self.chatTableView.reloadData()
        if isValeryVoiceOn {
            self.textToSpeech(text)
        }
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPoint(x: 0, y: self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
        }
    }
    
    func choosedDevice(_ object: AnyObject, message:String) {
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
    
    func setCommand(_ command:ChatCommand, object:AnyObject) {
        //   Set scene
        if command == .SetScene {
            if let scene = object as? Scene {
                let address = [UInt8(Int(scene.gateway.addressOne)),UInt8(Int(scene.gateway.addressTwo)),UInt8(Int(scene.address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setScene(address, id: Int(scene.sceneId)), gateway: scene.gateway)
                refreshChatListWithAnswer("scene was set", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Run event
        if command == .RunEvent {
            if let event = object as? Event {
                let address = [UInt8(Int(event.gateway.addressOne)),UInt8(Int(event.gateway.addressTwo)),UInt8(Int(event.address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.runEvent(address, id: UInt8(Int(event.eventId))), gateway: event.gateway)
                refreshChatListWithAnswer("event was ran", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Cancel event
        if command == .CancelEvent {
            if let event = object as? Event {
                let address = [UInt8(Int(event.gateway.addressOne)),UInt8(Int(event.gateway.addressTwo)),UInt8(Int(event.address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.cancelEvent(address, id: UInt8(Int(event.eventId))), gateway: event.gateway)
                refreshChatListWithAnswer("event was canceled", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Start sequence
        if command == .StartSequence {
            if let sequence = object as? Sequence {
                let address = [UInt8(Int(sequence.gateway.addressOne)),UInt8(Int(sequence.gateway.addressTwo)),UInt8(Int(sequence.address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: Int(sequence.sequenceId), cycle: UInt8(Int(sequence.sequenceCycles))), gateway: sequence.gateway)
                refreshChatListWithAnswer("sequence was started", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Stop sequence
        if command == .StopSequence {
            if let sequence = object as? Sequence {
                let address = [UInt8(Int(sequence.gateway.addressOne)),UInt8(Int(sequence.gateway.addressTwo)),UInt8(Int(sequence.address))]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: Int(sequence.sequenceId), cycle: 0xEF), gateway: sequence.gateway)
                refreshChatListWithAnswer("sequence was stopped", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
    }
    
    func commandWasSent(_ command:ChatCommand, deviceType:String) -> String {
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
    
    func sendCommand(_ command:ChatCommand, forDevice device:Device, withDimming dimValue:Int) {
        if command == .TurnOnDevice {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            if device.controlType == ControlType.Dimmer {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Relay {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Curtain {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Climate {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0xFF), gateway: device.gateway)
            }
            refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
        } else if command == .TurnOffDevice {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            if device.controlType == ControlType.Dimmer {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Relay {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Curtain {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
            }
            if device.controlType == ControlType.Climate {
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0x00), gateway: device.gateway)
            }
            refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
        } else if command == .DimDevice {
            if dimValue != -1 {
                let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
                if device.controlType == ControlType.Dimmer {
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: UInt8(Int(device.channel)), value: UInt8(dimValue), delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: UInt8(Int(device.skipState))), gateway: device.gateway)
                    refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("Device is not of dimmer type.", isValeryVoiceOn: isValeryVoiceOn)
                }
            } else {
                refreshChatListWithAnswer("Couldn't find value to dim device.", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
    }
    
    func findCommand(_ message:String) {
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
                    DispatchQueue.main.async(execute: {
                        self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn)
                    })
                })
            } else if command == .CurrentTime {
                DispatchQueue.main.async(execute: {
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone.autoupdatingCurrent
                    formatter.dateFormat = "HH:mm:ss"
                    self.refreshChatListWithAnswer("It is \(formatter.string(from: date))", isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .HowAreYou {
                DispatchQueue.main.async(execute: {
                    self.refreshChatListWithAnswer(self.answerOnHowAreYou(), isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .ILoveYou {
                DispatchQueue.main.async(execute: {
                    self.refreshChatListWithAnswer(self.answerOnILoveYou(), isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .BestDeveloper {
                DispatchQueue.main.async(execute: {
                    self.refreshChatListWithAnswer("One whose work you don't notice!", isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .ListAllCommands {
                var answer = "These are all commands:\n"
                for command in helper.CHAT_COMMANDS.keys {
                    answer = answer + "\(command) for \(helper.CHAT_COMMANDS[command]!.rawValue.lowercased())\n"
                }
                DispatchQueue.main.async(execute: {
                    self.refreshChatListWithAnswer(answer, isValeryVoiceOn:self.isValeryVoiceOn)
                })
            } else if command == .SetLocation {
                let location = helper.getLocation(message)
                if location != "" {
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [location, "All", "All", "All", "All", "All", "All"])
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
                    refreshChatListWithAnswer("Location was set.", isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("There is no known location with that name.", isValeryVoiceOn: isValeryVoiceOn)
                }
            } else if command == .SetLevel {
                if let zone = helper.getZone(message, isLevel: true) {
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [zone.location!.name!, "\(zone.id)", "All", "All", "\(zone.name)", "All", "All"])
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
                    refreshChatListWithAnswer("Level was set.", isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("You haven't set which level to set.", isValeryVoiceOn: isValeryVoiceOn)
                }
            } else if command == .SetZone {
                if let zone = helper.getZone(message, isLevel: false) {
                    if let level = DatabaseHandler.sharedInstance.returnLevelWithId(Int(zone.level!), location: zone.location!) {
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [zone.location!.name!, "\(level.id)", "\(zone.id)", "All","\(level.name)", "\(zone.name)", "All"])
                        NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
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
                                for (index, device) in devices.enumerated() {
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
                        DispatchQueue.main.async(execute: {
                            self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn)
                        })
                    }else{
                        DispatchQueue.main.async(execute: {
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
            let chatBubbleDataMine = ChatBubbleData(text: item.text, image: nil, date: Date(), type: item.type)
            let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
            rowHeight.append(chatBubbleMine.frame.maxY)
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let duration:TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        self.bottomConstraint.constant = keyboardFrame.size.height
        UIView.animate(withDuration: duration,
            delay: 0,
            options: UIViewAnimationOptions.curveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPoint(x: 0, y: self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: true)
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let duration:TimeInterval = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        self.bottomConstraint.constant = 0
        if chatTextView.text.isEmpty{
            viewHeight.constant = 49
        }
        UIView.animate(withDuration: duration,
            delay: 0,
            options: UIViewAnimationOptions.curveLinear,
            animations: { self.view.layoutIfNeeded() },
            completion: nil)
        if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
            self.chatTableView.setContentOffset(CGPoint(x: 0, y: self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: false)
        }
    }
    
}

// Parametar from filter and relaod data
extension ChatViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Chat)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        updateSubtitle(filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.chat)
        chatTableView.reloadData()
    }
    
    func saveDefaultFilter(){
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}

extension ChatViewController: SWRevealViewControllerDelegate{
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            chatTextView.isUserInteractionEnabled = true
            chatTableView.isUserInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            self.view.endEditing(true)
            chatTextView.isUserInteractionEnabled = false
            chatTableView.isUserInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            chatTextView.isUserInteractionEnabled = true
            chatTableView.isUserInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            self.view.endEditing(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.closeSideMenu))
            self.view.addGestureRecognizer(tap)
            chatTextView.isUserInteractionEnabled = false
            chatTableView.isUserInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func closeSideMenu(){
        
        if (sidebarMenuOpen != nil && sidebarMenuOpen == true) {
            self.revealViewController().revealToggle(animated: true)
        }
        
    }
}

extension ChatViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        if newFrame.size.height + 60 < 150{
            textView.frame = newFrame
            viewHeight.constant = textView.frame.size.height + 16
            if self.chatTableView.contentSize.height > self.chatTableView.frame.size.height{
                self.chatTableView.setContentOffset(CGPoint(x: 0, y: self.chatTableView.contentSize.height - self.chatTableView.frame.size.height), animated: false)
            }
        }
        
    }
}

extension ChatViewController: UITableViewDelegate {
    
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        let chatBubbleDataMine = ChatBubbleData(text: chatList[(indexPath as NSIndexPath).row].text, image: nil, date: Date(), type: chatList[(indexPath as NSIndexPath).row].type)
        let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
        chatBubbleMine.tag = (indexPath as NSIndexPath).row
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.oneTap(_:)))
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.longPress(_:)))
        longPress.minimumPressDuration = 1.0
        chatBubbleMine.addGestureRecognizer(tap)
        chatBubbleMine.addGestureRecognizer(longPress)
        cell.backgroundColor = UIColor.clear
        cell.contentView.addSubview(chatBubbleMine)
        return cell
    }
    func oneTap (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            self.chatTextView.text = chatList[tag].text
        }
    }
    func longPress (_ gesture:UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            if gesture.state == UIGestureRecognizerState.began {
                chatList.append(ChatItem(text: chatList[tag].text, type: .mine))
                calculateHeight()
                chatTableView.reloadData()
                findCommand(chatList[tag].text.lowercased())
            }
        }
    }
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight[(indexPath as NSIndexPath).row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
    @objc(tableView:willSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if(sidebarMenuOpen == true){
            return nil
        } else {
            return indexPath
        }
    }
}

class ChatAnswerCell: UITableViewCell {
    @IBOutlet weak var lblAnswerLIne: UILabel!
    
}
class ChatCommandCell: UITableViewCell {
    
}
