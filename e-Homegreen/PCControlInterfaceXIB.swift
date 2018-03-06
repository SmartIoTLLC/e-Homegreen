//
//  PCControlInterfaceXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit
//import wol.h

enum FileType{
    case video
    case app
    
    var description:String{
        switch self {
        case .video: return "Media"
        case .app: return "Application"
        }
    }
}

enum PlayVideoWith: Byte{
    case windowsMediaPlayer = 0x01
    case windowsMediaCenter = 0x02
}

enum CommandsForPCControll: Byte {
    case shutDown = 0x01
    case restart = 0x02
    case sleep = 0x03
    case hibernate = 0x04
    case logOff = 0x05
}

enum PowerOption: Byte{
    case shutDown = 0x01
    case restart = 0x02
    case sleep = 0x03
    case hibernate = 0x04
    case logOff = 0x05
    
    var description:String{
        switch self{
        case .shutDown: return "Shut Down"
        case .restart: return "Restart"
        case .sleep: return "Sleep"
        case .hibernate: return "Hibernate"
        case .logOff: return "LogOff"
        }
    }
    static let allValues = [shutDown, restart, sleep, hibernate, logOff]
}

class PCControlInterfaceXIB: PopoverVC {
    
    var isPresenting: Bool = true
    
    @IBOutlet weak var fullScreenSwitch: UISwitch!
    @IBOutlet weak var powerLabel: UILabel!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var runSwitch: UISwitch!
    @IBOutlet weak var mediaPathLabel: UILabel!
    @IBOutlet weak var appPathLabel: UILabel!
    @IBOutlet weak var voiceCommandButton: UIButton!
    
    var runCommandList = [PopOverItem]()
    var playCommandList = [PopOverItem]()
    var powerCommandList = [PopOverItem]()

    var fullScreenByte:Byte = 0x00
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var commandTextField: UITextField!
    
    @IBOutlet weak var centerX: NSLayoutConstraint!
    
    
    var tagIndex = 0 // cuvam tag od dugmeta koje poziva popover
    var runCommand:String? // run komanda
    var pathForVideo:String? // putanja selektovanog videa
    
    var pc:Device
    var button:UIButton!
    
    init(pc:Device){
        self.pc = pc
        socketIO = InOutSocket(port: 5000)
        super.init(nibName: "PCControlInterfaceXIB", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshLists()
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func setupViews() {
        for option in PowerOption.allValues { powerCommandList.append(PopOverItem(name: option.description, id: "")) }
        if powerCommandList.count != 0 { powerLabel.text = powerCommandList.first?.name }
        
        commandTextField.attributedPlaceholder = NSAttributedString(string:"Enter Command", attributes:[NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        commandTextField.delegate = self
        
        titleLabel.text = pc.name
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PCControlInterfaceXIB.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshLists()
    }
    
    override func nameAndId(_ name: String, id: String) {
        if button.tag == 1 { powerLabel.text = name }
        if button.tag == 2{
            playLabel.text = name
            pathForVideo = id + name
            mediaPathLabel.text = id
        }
        if button.tag == 3{
            runLabel.text = name
            runCommand = id
            appPathLabel.text = id
        }
    }
    
    func refreshLists(){
        runCommandList.removeAll()
        playCommandList.removeAll()
        if let list = pc.pcCommands {
            if let commandArray = Array(list) as? [PCCommand] {
                for item in commandArray {
                    if item.commandType!.intValue == CommandType.application.rawValue { runCommandList.append(PopOverItem(name: item.name!, id: item.comand!)) }
                    if item.commandType!.intValue == CommandType.media.rawValue { playCommandList.append(PopOverItem(name: item.name!, id: item.comand!)) }
                }
            }
        }
        if runCommandList.count != 0 {
            runLabel.text = runCommandList.first?.name
            appPathLabel.text = runCommandList.first?.id
        }
        if playCommandList.count != 0 {
            playLabel.text = playCommandList.first?.name
            mediaPathLabel.text = playCommandList.first?.id
        }
        
    }
    
    @objc func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func powerAction(_ sender: AnyObject) {
        if let text = powerLabel.text {
            switch text {
            case PowerOption.shutDown.description: break
            case PowerOption.restart.description: break
            case PowerOption.sleep.description: break
            case PowerOption.hibernate.description: break
            case PowerOption.logOff.description: break
            default: print("")
            }
        }
    }
    
    @IBAction func playAction(_ sender: AnyObject) {
        
        guard let videoName = playLabel.text , videoName != "-", let path =  pathForVideo  else { return }
        
        if fullScreenSwitch.isOn { fullScreenByte = 0x00 } else { fullScreenByte = 0x01 }
        
        SendingHandler.sendCommand(byteArray: OutgoingHandler.playVideo(pc.moduleAddress, fileName: path, fullScreen: fullScreenByte, by: PlayVideoWith.windowsMediaPlayer.rawValue), gateway: pc.gateway)
    }

    @IBAction func runAction(_ sender: AnyObject) {
        guard let appName = runLabel.text , appName != "-", let command =  runCommand  else { return }
        
        if runSwitch.isOn { fullScreenByte = 0x00 } else { fullScreenByte = 0x01 }
        
        SendingHandler.sendCommand(byteArray: OutgoingHandler.runApp(pc.moduleAddress, cmdLine: command), gateway: pc.gateway)
    }
    
    var socketIO:InOutSocket
    
    @IBAction func sendAction(_ sender: AnyObject) {
        guard let text = commandTextField.text else { return }
        
        SendingHandler.sendCommand(byteArray: OutgoingHandler.sendNotificationToPC(pc.moduleAddress, text: text, notificationType: NotificationType(rawValue: Int((pc.notificationType?.int32Value)!))!, notificationPosition: NotificationPosition(rawValue: Int((pc.notificationPosition?.int32Value)!))!, delayTime: Int((pc.notificationDelay?.int32Value)!), displayTime: Int((pc.notificationDisplayTime?.int32Value)!)), gateway: pc.gateway)
    }
    
    @IBAction func addPathForVideo(_ sender: AnyObject) {        
        if let navVC = UIStoryboard(name: "PCControl", bundle: Bundle.main).instantiateViewController(withIdentifier: "ListViewController") as? UINavigationController {
            if let vc = navVC.topViewController as? ListOfDevice_AppViewController {
                vc.typeOfFile = .video
                vc.device = pc
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func addPathForRunApp(_ sender: AnyObject) {
        if let navVC = UIStoryboard(name: "PCControl", bundle: Bundle.main).instantiateViewController(withIdentifier: "ListViewController") as? UINavigationController {
            if let vc = navVC.topViewController as? ListOfDevice_AppViewController {
                vc.typeOfFile = .app
                vc.device = pc
                self.present(navVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func powerOption(_ sender: UIButton) {
        button = sender
        openPopover(sender, popOverList:powerCommandList)
    }
    
    @IBAction func playOption(_ sender: UIButton) {
        button = sender
        openPopoverWithTwoRows(sender, popOverList: playCommandList)
    }
    
    @IBAction func runOption(_ sender: UIButton) {
        button = sender
        openPopoverWithTwoRows(sender, popOverList:runCommandList)
    }
    
    @IBAction func voiceCommand(_ sender: AnyObject) {
        print("Send voice command!")
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        moveTextfield(textfield: commandTextField, keyboardFrame: keyboardFrame, backView: backView)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
    
}

extension PCControlInterfaceXIB : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension PCControlInterfaceXIB : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view { if touchView.isDescendant(of: backView) { dismissEditing(); return false } }
        return true
    }
    
}

extension PCControlInterfaceXIB : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.5, scaleOneY: 1.5, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)        
    }
}

extension PCControlInterfaceXIB : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
   
}

extension UIViewController {
    func showPCInterface(_ pc:Device) {
        let pci = PCControlInterfaceXIB(pc:pc)
        self.present(pci, animated: true, completion: nil)
    }
}
