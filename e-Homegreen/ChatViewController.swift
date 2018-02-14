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
    
    let headerTitleSubtitleView = NavigationTitleView(frame:  CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var scrollView = FilterPullDown()
    
    var chatList:[ChatItem] = []
    
    var rowHeight:[CGFloat] = []
    
    var layout:String = "Portrait"
    
    var isValeryVoiceOn:Bool = true
    
    let reuseIdentifierCommand  = "chatCommandCell"
    let reuseIdentifierAnswer  = "chatAnswerCell"
    
    var filterParametar:FilterItem = Filter.sharedInstance.returnFilter(forTab: .Chat)
    let synth = AVSpeechSynthesizer()

    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var controlValleryVoice: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
        changeFullscreenImage(fullscreenButton: fullScreenButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: false)
        refreshLocalParametars()
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
        stopTextToSpeech()
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: scrollView)
        setTitleView(view: headerTitleSubtitleView)        
    }
    
    override func nameAndId(_ name : String, id:String){
        scrollView.setButtonTitle(name, id: id)
    }
    
    func defaultFilter(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            scrollView.setDefaultFilterItem(Menu.chat)
        }
    }
    
    @IBAction func fullScreen(_ sender: UIButton) {
        sender.switchFullscreen(viewThatNeedsOffset: scrollView)        
    }
    
    func refreshLocalParametars() {
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        chatTableView.reloadData()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustScrollInsetsPullDownViewAndBackgroudImage()
    }
    
    func adjustScrollInsetsPullDownViewAndBackgroudImage() {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight { layout = "Landscape" } else { layout = "Portrait" }
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
        if string.range(of: searchTerm).location != NSNotFound { print("exists"); print(range.location); print(range.location+range.length-1) }
    }
    
    @IBAction func sendBtnAction(_ sender: AnyObject) {
        if  chatTextView.text != "" {
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
        chatList.append(ChatItem(text: text, type: .opponent))
        calculateHeight()
        chatTableView.reloadData()
        if isValeryVoiceOn { self.textToSpeech(text) }
        if chatTableView.contentSize.height > chatTableView.frame.size.height {
            chatTableView.setContentOffset(CGPoint(x: 0, y: chatTableView.contentSize.height - chatTableView.frame.size.height), animated: true)
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
                let address = [getByte(scene.gateway.addressOne), getByte(scene.gateway.addressTwo), getByte(scene.address)]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setScene(address, id: Int(scene.sceneId)), gateway: scene.gateway)
                refreshChatListWithAnswer("scene was set", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Run event
        if command == .RunEvent {
            if let event = object as? Event {
                let address = [getByte(event.gateway.addressOne), getByte(event.gateway.addressTwo), getByte(event.address)]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.runEvent(address, id: getByte(event.eventId)), gateway: event.gateway)
                refreshChatListWithAnswer("event was ran", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Cancel event
        if command == .CancelEvent {
            if let event = object as? Event {
                let address = [getByte(event.gateway.addressOne), getByte(event.gateway.addressTwo), getByte(event.address)]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.cancelEvent(address, id: getByte(event.eventId)), gateway: event.gateway)
                refreshChatListWithAnswer("event was canceled", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Start sequence
        if command == .StartSequence {
            if let sequence = object as? Sequence {
                let address = [getByte(sequence.gateway.addressOne), getByte(sequence.gateway.addressTwo), getByte(sequence.address)]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: Int(sequence.sequenceId), cycle: getByte(sequence.sequenceCycles)), gateway: sequence.gateway)
                refreshChatListWithAnswer("sequence was started", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
        //   Stop sequence
        if command == .StopSequence {
            if let sequence = object as? Sequence {
                let address = [getByte(sequence.gateway.addressOne), getByte(sequence.gateway.addressTwo), getByte(sequence.address)]
                SendingHandler.sendCommand(byteArray: OutgoingHandler.setSequence(address, id: Int(sequence.sequenceId), cycle: 0xEF), gateway: sequence.gateway)
                refreshChatListWithAnswer("sequence was stopped", isValeryVoiceOn: isValeryVoiceOn)
            }
        }
    }
    
    func commandWasSent(_ command:ChatCommand, deviceType:String) -> String {
        var array = ["Command was sent...", "Your wish is my command.", "As you wish.", "I'll do it.", "It is done.", "Whatever you want.", "Consider it done."]
        switch command {
            case .TurnOnDevice:
                if deviceType == ControlType.Dimmer || deviceType == ControlType.Relay { array.append("Device was turned on.") }
                if deviceType == ControlType.Curtain { array.append("Curtain was turned on.") }
                if deviceType == ControlType.Climate { array.append("Climate was turned on."); array.append("Hvac was turned on.") }
            
            case.TurnOffDevice:
                if deviceType == ControlType.Dimmer || deviceType == ControlType.Relay { array.append("Device was turned off.") }
                if deviceType == ControlType.Curtain { array.append("Curtain was turned off.") }
                if deviceType == ControlType.Climate { array.append("Climate was turned off."); array.append("Hvac was turned off.") }
            
            case .DimDevice:
                if deviceType == ControlType.Dimmer { array.append("Device was dimmed.") }
            
            default: break
        }
        
        return getRandomAnswer(from: array)
    }
    
    func sendCommand(_ command:ChatCommand, forDevice device:Device, withDimming dimValue:Int) {
        let address = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        let controlType = device.controlType
        
        if command == .TurnOnDevice {
            switch controlType {
                case ControlType.Dimmer  : SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: getByte(device.channel), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: getByte(device.skipState)), gateway: device.gateway)
                case ControlType.Relay   : SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: getByte(device.channel), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: getByte(device.skipState)), gateway: device.gateway)
                case ControlType.Curtain : SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: getByte(device.channel), value: 0xFF, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: getByte(device.skipState)), gateway: device.gateway)
                case ControlType.Climate : SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: getByte(device.channel), status: 0xFF), gateway: device.gateway)
                default: break
            }
            
            refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
        } else if command == .TurnOffDevice {
            switch controlType {
                case ControlType.Dimmer  : SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: getByte(device.channel), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: getByte(device.skipState)), gateway: device.gateway)
                case ControlType.Relay   : SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: getByte(device.channel), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: getByte(device.skipState)), gateway: device.gateway)
                case ControlType.Curtain : SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: getByte(device.channel), value: 0x00, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: getByte(device.skipState)), gateway: device.gateway)
                case ControlType.Climate : SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: getByte(device.channel), status: 0x00), gateway: device.gateway)
                default: break
            }

            refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
        } else if command == .DimDevice {
            switch dimValue {
                case -1 : refreshChatListWithAnswer("Couldn't find value to dim device.", isValeryVoiceOn: isValeryVoiceOn)
                default :
                    switch controlType {
                        case ControlType.Dimmer :
                            SendingHandler.sendCommand(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: getByte(device.channel), value: getIByte(dimValue), delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: getByte(device.skipState)), gateway: device.gateway)
                            refreshChatListWithAnswer(commandWasSent(command, deviceType: device.controlType), isValeryVoiceOn: isValeryVoiceOn)
                        default: refreshChatListWithAnswer("Device is not of dimmer type.", isValeryVoiceOn: isValeryVoiceOn)
                    }
            }
        }
    }
    
    func findCommand(_ message:String) {
        let helper = ChatHandler()
        let command = helper.getCommand(message) // treba
        let typeOfControl = helper.getTypeOfControl(command)
        let itemsArray = helper.getItemByName(typeOfControl, message: message) // treba
        if let zone:Zone = helper.getLevel(message) { print(String(describing: zone.name)) }
        if command != .Failed {

            if command == .TurnOnDevice || command == .TurnOffDevice || command == .DimDevice || command == .SetScene || command == .RunEvent || command == .StartSequence || command == .CancelEvent || command == .StopSequence {
                if itemsArray.count >= 0 {
                    if itemsArray.count == 1 {
                        
                        if let device = itemsArray[0] as? Device { sendCommand(command, forDevice: device, withDimming: helper.getValueForDim(message, withDeviceName: device.name)) }
                        if let scene = itemsArray[0] as? Scene { setCommand(command, object:scene) }
                        if let sequence = itemsArray[0] as? Sequence { setCommand(command, object:sequence) }
                        if let event = itemsArray[0] as? Event { setCommand(command, object:event) }
                        
                    } else if itemsArray.count > 1 {
                        //   There are more devices than just a one
                        if let devices = itemsArray as? [Device] { showSuggestion(devices, message: message).delegate = self }
                        if let scenes = itemsArray as? [Scene] { showSuggestion(scenes, message: message).delegate = self }
                        if let sequences = itemsArray as? [Sequence] { showSuggestion(sequences, message: message).delegate = self }
                        if let events = itemsArray as? [Event] { showSuggestion(events, message: message).delegate = self }
                        
                    } else {
                        //   Ther are no devices, events, scenes, sequences... with that name
                        refreshChatListWithAnswer(nothingFound(), isValeryVoiceOn: isValeryVoiceOn)
                    }
                }
            } else if command == .TellMeJoke {
                let joke = TellMeAJokeHandler()
                joke.getJokeCompletion({ (result) -> Void in
                    DispatchQueue.main.async(execute: { self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn) })
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
                DispatchQueue.main.async(execute: { self.refreshChatListWithAnswer(self.answerOnHowAreYou(), isValeryVoiceOn:self.isValeryVoiceOn) })
                
            } else if command == .ILoveYou {
                DispatchQueue.main.async(execute: { self.refreshChatListWithAnswer(self.answerOnILoveYou(), isValeryVoiceOn:self.isValeryVoiceOn) })
                
            } else if command == .BestDeveloper {
                DispatchQueue.main.async(execute: { self.refreshChatListWithAnswer("One whose work you don't notice!", isValeryVoiceOn:self.isValeryVoiceOn) })
                
            } else if command == .ListAllCommands {
                var answer = "These are all commands:\n"
                for command in helper.CHAT_COMMANDS.keys { answer = answer + "\(command) for \(helper.CHAT_COMMANDS[command]!.rawValue.lowercased())\n" }
                DispatchQueue.main.async(execute: { self.refreshChatListWithAnswer(answer, isValeryVoiceOn:self.isValeryVoiceOn) })
                
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
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [zone.location!.name!, "\(zone.id!)", "All", "All", "\(zone.name!)", "All", "All"])
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
                    refreshChatListWithAnswer("Level was set.", isValeryVoiceOn: isValeryVoiceOn)
                } else {
                    refreshChatListWithAnswer("You haven't set which level to set.", isValeryVoiceOn: isValeryVoiceOn)
                }
                
            } else if command == .SetZone {
                if let zone = helper.getZone(message, isLevel: false) {
                    if let level = DatabaseHandler.sharedInstance.returnLevelWithId(Int(zone.level!), location: zone.location!) {
                    LocalSearchParametar.setLocalParametar("Chat", parametar: [zone.location!.name!, "\(level.id!)", "\(zone.id!)", "All","\(level.name!)", "\(zone.name!)", "All"])
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
                                for device in devices { answer = answer + "\(device.name)\n" }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                                
                            } else { refreshChatListWithAnswer("There are no devices in zone.", isValeryVoiceOn: isValeryVoiceOn)  }
                        } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no zone but there is location (there could be more locations)
                    } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no location // testiraj zone!
                    
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllDevices(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all devices in \(zone):\n"
                        for device in devices { answer = answer + "\(device.name)\n" }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                        
                    } else { refreshChatListWithAnswer("There are no devices in zone.", isValeryVoiceOn: isValeryVoiceOn) }
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
                                for device in devices { answer = answer + "\(device.sceneName)\n" }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                                
                            } else { refreshChatListWithAnswer("There are no scenes in zone.", isValeryVoiceOn: isValeryVoiceOn) }
                        } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no zone but there is location (there could be more locations)
                    } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no location // testiraj zone!
                    
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllScenes(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all scenes in \(zone):\n"
                        for device in devices { answer = answer + "\(device.sceneName)\n" }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                        
                    } else { refreshChatListWithAnswer("There are no scenes in zone.", isValeryVoiceOn: isValeryVoiceOn) }
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
                                for device in devices { answer = answer + "\(device.eventName)\n" }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                                
                            } else { refreshChatListWithAnswer("There are no events in zone.", isValeryVoiceOn: isValeryVoiceOn) }
                        } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no zone but there is location (there could be more locations)
                    } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no location // testiraj zone!
                    
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllEvents(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all events in \(zone):\n"
                        for device in devices { answer = answer + "\(device.eventName)\n" }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                        
                    } else { refreshChatListWithAnswer("There are no events in zone.", isValeryVoiceOn: isValeryVoiceOn) }
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
                                for (index, device) in devices.enumerated() { answer = answer + "\(device.sequenceName)\n"; print(index) }
                                refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                                
                            } else { refreshChatListWithAnswer("There are no sequences in zone.", isValeryVoiceOn: isValeryVoiceOn) }
                        } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no zone but there is location (there could be more locations)
                    } else { refreshChatListWithAnswer("Please specify zone.", isValeryVoiceOn: isValeryVoiceOn) } // There is no location // testiraj zone!
                    
                } else {
                    // izlistaj sve uredjaje u toj zoni! (mozda proveri i da li ima lokacija!)
                    let devices = helper.returnAllSequences(filterParametar, onlyZoneName: zone)
                    if devices.count != 0 {
                        var answer = "These are all sequences in \(zone):\n"
                        for device in devices { answer = answer + "\(device.sequenceName)\n" }
                        refreshChatListWithAnswer(answer, isValeryVoiceOn: isValeryVoiceOn)
                        
                    } else { refreshChatListWithAnswer("There are no sequences in zone.", isValeryVoiceOn: isValeryVoiceOn) }
                }
                
            } else if command == .AnswerMe {
                let answ = AnswersHandler()
                answ.getAnswerComplition(chatTextView.text!, completion: { (result) -> Void in
                    if result != "" { DispatchQueue.main.async(execute: { self.refreshChatListWithAnswer(result, isValeryVoiceOn:self.isValeryVoiceOn) }) }
                    else { DispatchQueue.main.async(execute: { self.refreshChatListWithAnswer(self.questionNotUnderstandable(), isValeryVoiceOn:self.isValeryVoiceOn) }) }
                })
                
            } else { refreshChatListWithAnswer(questionNotUnderstandable(), isValeryVoiceOn: isValeryVoiceOn) } //   Sorry but there are no devices with that name //   Maybe new command?
        } else { refreshChatListWithAnswer(questionNotUnderstandable(), isValeryVoiceOn: isValeryVoiceOn) }
    }
    
    fileprivate func getRandomAnswer(from array: [String]) -> String {
        let randomIndex = Int(arc4random_uniform(UInt32(array.count)))
        if randomIndex < array.count { return array[randomIndex] }
        return "I'm not sure I understand."
    }
    
    func questionNotUnderstandable() -> String {
        let array = ["I didn't understand that.", "Please be more specific.", "You were saying...", "Sorry, I didn't get that. ", "I'm not sure I understand.", "I'm afraid I don't know the answer to that.", "I don't know what do you want.", "Command is not clear."]
        return getRandomAnswer(from: array)
    }
    
    func answerOnILoveYou() -> String {
        let array = ["\u{1f60d}", "I love you too \u{1f60d}", "\u{1f618}", "I love myself too \u{2764}", "\u{2764}"]
        return getRandomAnswer(from: array)
    }
    
    func answerOnHowAreYou() -> String {
        let array = ["I'm fine, thank you for asking.", "You are so kind.", "I am happy.", "I have a doubt... I don't know if I am just fine or super fine.", "You are more important!", "I am asking you!", "\u{1f600}", "\u{1f601}", "\u{1f603}", "\u{1f609}", "\u{1f600}", "\u{1f601}", "\u{1f603}", "\u{1f609}"]
        return getRandomAnswer(from: array)
    }
    
    func nothingFound() -> String {
        let array = ["Couldn't find something to control...", "Nothing found...", "Please be more specific.", "I don't undersrtand."]
        return getRandomAnswer(from: array)
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
        let info = notification.userInfo!
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
    
    override func keyboardWillHide(_ notification: Notification) {
        let info = notification.userInfo!
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
    
    func setDefaultFilterFromTimer(){
        scrollView.setDefaultFilterItem(Menu.chat)
    }
}

// Parametar from filter and relaod data
extension ChatViewController: FilterPullDownDelegate{
    func filterParametars(_ filterItem: FilterItem){
        Filter.sharedInstance.saveFilter(item: filterItem, forTab: .Chat)
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        updateSubtitle(headerTitleSubtitleView, title: "Chat", location: filterItem.location, level: filterItem.levelName, zone: filterItem.zoneName)
        DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.chat)
        chatTableView.reloadData()
        TimerForFilter.shared.counterChat = DatabaseFilterController.shared.getDeafultFilterTimeDuration(menu: Menu.chat)
        TimerForFilter.shared.startTimer(type: Menu.chat)
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
        } else {
            dismissEditing()
            chatTextView.isUserInteractionEnabled = false
            chatTableView.isUserInteractionEnabled = false
        }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if(position == FrontViewPosition.left) {
            chatTextView.isUserInteractionEnabled = true
            chatTableView.isUserInteractionEnabled = true
        } else {
            dismissEditing()
            chatTextView.isUserInteractionEnabled = false
            chatTableView.isUserInteractionEnabled = false
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
        let chatBubbleDataMine = ChatBubbleData(text: chatList[indexPath.row].text, image: nil, date: Date(), type: chatList[indexPath.row].type)
        let chatBubbleMine = ChatBubble(data: chatBubbleDataMine, startY: 5, orientation: layout)
        chatBubbleMine.tag = indexPath.row
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
        return rowHeight[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatList.count
    }
    
}

// MARK: - View setup
extension ChatViewController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.refreshLocalParametars), name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshFilter), object: nil)
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name:.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name:.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setDefaultFilterFromTimer), name: NSNotification.Name(rawValue: NotificationKey.FilterTimers.timerChat), object: nil)
    }
    
    func setupViews() {
        if #available(iOS 11, *) { headerTitleSubtitleView.layoutIfNeeded() }
        
        UIView.hr_setToastThemeColor(color: UIColor.red)
        
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        
        chatTextView.delegate = self
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.cornerRadius = 5
        chatTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        scrollView.filterDelegate = self
        view.addSubview(scrollView)
        updateConstraints(item: scrollView)
        scrollView.setItem(self.view)
        
        calculateHeight()
        
        navigationItem.titleView = headerTitleSubtitleView
        headerTitleSubtitleView.setTitleAndSubtitle("Chat", subtitle: "All All All")
        
        filterParametar = Filter.sharedInstance.returnFilter(forTab: .Chat)
        adjustScrollInsetsPullDownViewAndBackgroudImage()
        
        let longPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ChatViewController.defaultFilter(_:)))
        longPress.minimumPressDuration = 0.5
        headerTitleSubtitleView.addGestureRecognizer(longPress)
        
        scrollView.setFilterItem(Menu.chat)
    }
}

class ChatAnswerCell: UITableViewCell {
    @IBOutlet weak var lblAnswerLIne: UILabel!
    
}
class ChatCommandCell: UITableViewCell {
    
}
