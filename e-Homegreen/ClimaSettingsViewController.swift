//
//  ClimaSettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData
func == (lhs: HvacCommand, rhs: HvacCommand) -> Bool {
    return lhs.coolTemperature == rhs.coolTemperature && lhs.heatTemperature == rhs.heatTemperature && lhs.fan == rhs.fan && lhs.mode == rhs.mode
}
func != (lhs: HvacCommand, rhs: HvacCommand) -> Bool {
    return lhs.coolTemperature != rhs.coolTemperature || lhs.heatTemperature != rhs.heatTemperature || lhs.fan != rhs.fan || lhs.mode != rhs.mode
}
struct HvacCommand {
    var mode:Mode = .NoMode
    var fan:Fan = .NoFan
    var coolTemperature = 0
    var heatTemperature = 0
}
enum Mode {
    case Cool
    case Heat
    case Fan
    case AUTO
    case NoMode
}
enum Fan {
    case Low
    case Med
    case High
    case AUTO
    case NoFan
}
class ClimaSettingsViewController: CommonXIBTransitionVC {
    
    var indexPathRow: Int = -1
    var devices:[Device] = []
    
    @IBOutlet weak var modeLbl: UILabel!
    @IBOutlet weak var modeStackView: UIStackView!
    
    //Mode button
    @IBOutlet weak var btnCool: HVACButton!
    @IBOutlet weak var btnHeat: HVACButton!
    @IBOutlet weak var btnFan: HVACButton!
    @IBOutlet weak var btnAuto: HVACButton!
    
    @IBOutlet weak var fanLbl: UILabel!
    @IBOutlet weak var fanStackView: UIStackView!
    
    //Fan button
    @IBOutlet weak var btnLow: HVACButton!
    @IBOutlet weak var btnMed: HVACButton!
    @IBOutlet weak var btnHigh: HVACButton!
    @IBOutlet weak var btnAutoFan: HVACButton!
    
    @IBOutlet weak var coolView: UIView!
    @IBOutlet weak var heatView: UIView!
    
    
    @IBOutlet weak var thresholdSTackView: UIStackView!
    @IBOutlet weak var threshholdLbl: UILabel!
    
    @IBOutlet weak var lblCool: UILabel!
    @IBOutlet weak var lblHeat: UILabel!
    var coolTemperature = 28
    var heatTemperature = 18
    
    @IBOutlet weak var lblClimateName: UILabel!
    @IBOutlet weak var settingsView: UIView!
    
    @IBOutlet weak var currentLbl: UILabel!
    @IBOutlet weak var currentStackView: UIStackView!
    
    @IBOutlet weak var humidityLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    
    var appDel:AppDelegate!
    var hvacCommand:HvacCommand = HvacCommand()
    var hvacCommandBefore:HvacCommand = HvacCommand()
    
    var timerForTemperatureSetPoint:NSTimer = NSTimer()
    var temperatureNumber = 0
    var heatNumber = 0
    var coolNumber = 0
    
    var device:Device!
    
    init(device: Device){
        super.init(nibName: "ClimaSettingsViewController", bundle: nil)
        self.device = device
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hvacCommand.coolTemperature = Int(device.coolTemperature)
        hvacCommand.heatTemperature = Int(device.heatTemperature)
        
        lblCool.text = "\(device.coolTemperature)"
        lblHeat.text = "\(device.heatTemperature)"
        coolNumber = Int(device.coolTemperature)
        heatNumber = Int(device.heatTemperature)
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)        
        
        getACState()
        
        if device.coolModeVisible == false {
        
            btnCool.hidden = true
            
            coolView.hidden = true
            
            if device.heatModeVisible == false {
                
                btnHeat.hidden = true
                
                thresholdSTackView.hidden = true
                threshholdLbl.hidden = true
            }
        }
        
        if device.heatModeVisible == false {
            btnHeat.hidden = true
            heatView.hidden = true
        }
        if device.fanModeVisible == false {
            btnFan.hidden = true
        }
        if device.autoModeVisible == false {
            btnAuto.hidden = true
        }
        
        if device.coolModeVisible == false && device.heatModeVisible == false && device.fanModeVisible == false && device.autoModeVisible == false {
            modeLbl.hidden = true
            modeStackView.hidden = true
        }

        if device.lowSpeedVisible == false {
            btnLow.hidden = true
        }
        if device.medSpeedVisible == false {
            btnMed.hidden = true
        }
        if device.highSpeedVisible == false {
            btnHigh.hidden = true
        }
        if device.autoSpeedVisible == false {
            btnAutoFan.hidden = true
        }
        
        if device.lowSpeedVisible == false && device.medSpeedVisible == false && device.highSpeedVisible == false && device.autoSpeedVisible == false {
            fanLbl.hidden = true
            fanStackView.hidden = true
        }
        
        if device.temperatureVisible == false {
            tempLbl.hidden = true
        }
        if device.humidityVisible == false {
            humidityLbl.hidden = true
        }
        
        if device.temperatureVisible == false && device.humidityVisible == false {
            currentLbl.hidden = true
            currentStackView.hidden = true
        }

        
        print("Stanje klime - temperatura + humidity: \(device.temperatureVisible) \(device.humidityVisible)")
        
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(settingsView){
            return false
        }
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(NotificationKey.RefreshClimate)
    }
    
    @IBAction func btnSet(sender: AnyObject) {
        print(hvacCommand)
        if hvacCommand != hvacCommandBefore {
            NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "setACSetPoint", userInfo: nil, repeats: false)
            NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: "setACSpeed", userInfo: nil, repeats: false)
            NSTimer.scheduledTimerWithTimeInterval(0.9, target: self, selector: "setACmode", userInfo: nil, repeats: false)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func setACSetPoint () {
        let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
        SendingHandler.sendCommand(byteArray: Function.setACSetPoint(address, channel: UInt8(Int(device.channel)), coolingSetPoint: UInt8(hvacCommand.coolTemperature), heatingSetPoint: UInt8(hvacCommand.heatTemperature)), gateway: device.gateway)
    }
    
    func setACSpeed () {
        let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
        switch hvacCommand.fan {
        case .Low:
            SendingHandler.sendCommand(byteArray: Function.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x01), gateway: device.gateway)
        case .Med:
            SendingHandler.sendCommand(byteArray: Function.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x02), gateway: device.gateway)
        case .High:
            SendingHandler.sendCommand(byteArray: Function.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x03), gateway: device.gateway)
        case .AUTO:
            SendingHandler.sendCommand(byteArray: Function.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x00), gateway: device.gateway)
        default :break
        }
    }
    
    func setACmode () {
        let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
        switch hvacCommand.mode {
        case .Cool:
            SendingHandler.sendCommand(byteArray: Function.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x01), gateway: device.gateway)
        case .Heat:
            SendingHandler.sendCommand(byteArray: Function.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x02), gateway: device.gateway)
        case .Fan:
            SendingHandler.sendCommand(byteArray: Function.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x03), gateway: device.gateway)
        case .AUTO:
            SendingHandler.sendCommand(byteArray: Function.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x00), gateway: device.gateway)
        default :break
        }
    }
    
    func updateDevice () {
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let fetResults = appDel.managedObjectContext!.objectWithID(devices[indexPathRow].objectID) as? Device
        if let results = fetResults {
            device = results
        } else {
        }
    }
    
    func getACState () {
        updateDevice()
        let speedState = device.speed
        switch speedState {
        case "Low":
            hvacCommand.fan = .Low
            pressedLow()
        case "Med" :
            hvacCommand.fan = .Med
            pressedMed()
        case "High":
            hvacCommand.fan = .High
            pressedHigh()
        default:
            hvacCommand.fan = .AUTO
            pressedAutoSecond()
        }
        let modeState = device.mode
        switch modeState {
        case "Cool":
            hvacCommand.mode = .Cool
            pressedCool()
        case "Heat":
            hvacCommand.mode = .Heat
            pressedHeat()
        case "Fan":
            hvacCommand.mode = .Fan
            pressedFan()
        default:
            hvacCommand.mode = .AUTO
            pressedAuto()
        }
        
        lblCool.text = "\(device.coolTemperature)"
        lblHeat.text = "\(device.heatTemperature)"
        
        humidityLbl.text = "Humidity\n \(device.humidity) %"
        tempLbl.text = "Temperature\n \(device.roomTemperature) °C"
        
        lblClimateName.text = "\(device.name)"
        hvacCommandBefore = hvacCommand
    }

    func pressedCool() {
        btnCool.setSelectedColor()
        btnHeat.setGradientColor()
        btnFan.setGradientColor()
        btnAuto.setGradientColor()
    }
    func pressedHeat() {
        btnCool.setGradientColor()
        btnHeat.setSelectedColor()
        btnFan.setGradientColor()
        btnAuto.setGradientColor()
    }
    func pressedFan () {
        btnCool.setGradientColor()
        btnHeat.setGradientColor()
        btnFan.setSelectedColor()
        btnAuto.setGradientColor()
    }
    func pressedAuto() {
        btnCool.setGradientColor()
        btnHeat.setGradientColor()
        btnFan.setGradientColor()
        btnAuto.setSelectedColor()
    }
    @IBAction func btnCoolPressed(sender: UIButton) {
        hvacCommand.mode = .Cool
        pressedCool()
    }
    @IBAction func btnHeatPressed(sender: UIButton) {
        hvacCommand.mode = .Heat
        pressedHeat()
    }
    @IBAction func fan(sender: UIButton) {
        hvacCommand.mode = .Fan
        pressedFan()
    }
    @IBAction func auto(sender: UIButton) {
        hvacCommand.mode = .AUTO
        pressedAuto()
        
    }
    func pressedLow () {
        btnLow.setSelectedColor()
        btnMed.setGradientColor()
        btnHigh.setGradientColor()
        btnAutoFan.setGradientColor()
    }
    func pressedMed () {
        btnLow.setGradientColor()
        btnMed.setSelectedColor()
        btnHigh.setGradientColor()
        btnAutoFan.setGradientColor()

    }
    func pressedHigh () {
        btnLow.setGradientColor()
        btnMed.setGradientColor()
        btnHigh.setSelectedColor()
        btnAutoFan.setGradientColor()
    }
    func pressedAutoSecond () {
        btnLow.setGradientColor()
        btnMed.setGradientColor()
        btnHigh.setGradientColor()
        btnAutoFan.setSelectedColor()
    }
    
    @IBAction func low(sender: AnyObject) {
        hvacCommand.fan = .Low
        pressedLow()
    }
    
    @IBAction func med(sender: AnyObject) {
        hvacCommand.fan = .Med
        pressedMed()
    }
    
    @IBAction func high(sender: AnyObject) {
        hvacCommand.fan = .High
        pressedHigh()
    }
    
    @IBAction func fanAuto(sender: AnyObject) {
        hvacCommand.fan = .AUTO
        pressedAutoSecond()
    }
    
    @IBAction func onOff(sender: AnyObject) {
        if device.currentValue == 0x00 {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0xFF), gateway: device.gateway)
        }
        if device.currentValue == 0xFF {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: Function.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0x00), gateway: device.gateway)
        }
    }
    
    @IBAction func lowCool(sender: AnyObject) {
        if coolNumber >= 1 {
            coolNumber -= 1
            lblCool.text = "\(coolNumber)"
            hvacCommand.coolTemperature = coolNumber
        }
    }
    
    @IBAction func highCool(sender: AnyObject) {
        if coolNumber <= 36 {
            coolNumber += 1
            lblCool.text = "\(coolNumber)"
            hvacCommand.coolTemperature = coolNumber
        }
    }
    
    func coolTemeperatureUpdate (timer:NSTimer) {
        if let number = timer.userInfo as? Int {
            temperatureNumber = 0
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: Function.setACSetPoint(address, channel: UInt8(Int(device.channel)), coolingSetPoint: UInt8(Int(device.coolTemperature)+number), heatingSetPoint: UInt8(Int(device.heatTemperature))), gateway: device.gateway)
        }
    }
    
    @IBAction func lowHeat(sender: AnyObject) {
        if heatNumber >= 1 {
            heatNumber -= 1
            lblHeat.text = "\(heatNumber)"
            hvacCommand.heatTemperature = heatNumber
        }
    }
    
    @IBAction func highHeat(sender: AnyObject) {
        if heatNumber <= 36 {
            heatNumber += 1
            lblHeat.text = "\(heatNumber)"
            hvacCommand.heatTemperature = heatNumber
        }
    }
    func heatTemeperatureUpdate (timer:NSTimer) {
        if let number = timer.userInfo as? Int {
            temperatureNumber = 0
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: Function.setACSetPoint(address, channel: UInt8(Int(device.channel)), coolingSetPoint: UInt8(Int(device.coolTemperature)), heatingSetPoint: UInt8(Int(device.heatTemperature)+number)), gateway: device.gateway)
        }
    }

}

extension UIViewController {
    func showClimaSettings(indexPathRow: Int, devices:[Device]) {
        let ad = ClimaSettingsViewController(device: devices[indexPathRow])
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.presentViewController(ad, animated: true, completion: nil)
    }
}
