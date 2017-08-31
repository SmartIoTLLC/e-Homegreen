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
    var mode:Mode = .noMode
    var fan:Fan = .noFan
    var coolTemperature = 0
    var heatTemperature = 0
}
enum Mode {
    case cool
    case heat
    case fan
    case auto
    case noMode
}
enum Fan {
    case low
    case med
    case high
    case auto
    case noFan
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
    
    var timerForTemperatureSetPoint:Foundation.Timer = Foundation.Timer()
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
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)        
        
        getACState()
        
        if device.coolModeVisible == false {
        
            btnCool.isHidden = true
            
            coolView.isHidden = true
            
            if device.heatModeVisible == false {
                
                btnHeat.isHidden = true
                
                thresholdSTackView.isHidden = true
                threshholdLbl.isHidden = true
            }
        }
        
        if device.heatModeVisible == false {
            btnHeat.isHidden = true
            heatView.isHidden = true
        }
        if device.fanModeVisible == false {
            btnFan.isHidden = true
        }
        if device.autoModeVisible == false {
            btnAuto.isHidden = true
        }
        
        if device.coolModeVisible == false && device.heatModeVisible == false && device.fanModeVisible == false && device.autoModeVisible == false {
            modeLbl.isHidden = true
            modeStackView.isHidden = true
        }

        if device.lowSpeedVisible == false {
            btnLow.isHidden = true
        }
        if device.medSpeedVisible == false {
            btnMed.isHidden = true
        }
        if device.highSpeedVisible == false {
            btnHigh.isHidden = true
        }
        if device.autoSpeedVisible == false {
            btnAutoFan.isHidden = true
        }
        
        if device.lowSpeedVisible == false && device.medSpeedVisible == false && device.highSpeedVisible == false && device.autoSpeedVisible == false {
            fanLbl.isHidden = true
            fanStackView.isHidden = true
        }
        
        if device.temperatureVisible == false {
            tempLbl.isHidden = true
        }
        if device.humidityVisible == false {
            humidityLbl.isHidden = true
        }
        
        if device.temperatureVisible == false && device.humidityVisible == false {
            currentLbl.isHidden = true
            currentStackView.isHidden = true
        }

        
        print("Stanje klime - temperatura + humidity: \(device.temperatureVisible) \(device.humidityVisible)")
        
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: settingsView){
            return false
        }
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(NotificationKey.RefreshClimate)
    }
    
    @IBAction func btnSet(_ sender: AnyObject) {
        print(hvacCommand)
        if hvacCommand != hvacCommandBefore {
            Foundation.Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(ClimaSettingsViewController.setACSetPoint), userInfo: nil, repeats: false)
            Foundation.Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(ClimaSettingsViewController.setACSpeed), userInfo: nil, repeats: false)
            Foundation.Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(ClimaSettingsViewController.setACmode), userInfo: nil, repeats: false)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func setACSetPoint () {
        let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSetPoint(address, channel: UInt8(Int(device.channel)), coolingSetPoint: UInt8(hvacCommand.coolTemperature), heatingSetPoint: UInt8(hvacCommand.heatTemperature)), gateway: device.gateway)
    }
    
    func setACSpeed () {
        let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
        switch hvacCommand.fan {
        case .low:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x01), gateway: device.gateway)
        case .med:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x02), gateway: device.gateway)
        case .high:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x03), gateway: device.gateway)
        case .auto:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSpeed(address, channel: UInt8(Int(device.channel)), value: 0x00), gateway: device.gateway)
        default :break
        }
    }
    
    func setACmode () {
        let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
        switch hvacCommand.mode {
        case .cool:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x01), gateway: device.gateway)
        case .heat:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x02), gateway: device.gateway)
        case .fan:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x03), gateway: device.gateway)
        case .auto:
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACmode(address, channel: UInt8(Int(device.channel)), value: 0x00), gateway: device.gateway)
        default :break
        }
    }
    
    func updateDevice () {
        appDel = UIApplication.shared.delegate as! AppDelegate
        let fetResults = appDel.managedObjectContext!.object(with: devices[indexPathRow].objectID) as? Device
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
            hvacCommand.fan = .low
            pressedLow()
        case "Med" :
            hvacCommand.fan = .med
            pressedMed()
        case "High":
            hvacCommand.fan = .high
            pressedHigh()
        default:
            hvacCommand.fan = .auto
            pressedAutoSecond()
        }
        let modeState = device.mode
        switch modeState {
        case "Cool":
            hvacCommand.mode = .cool
            pressedCool()
        case "Heat":
            hvacCommand.mode = .heat
            pressedHeat()
        case "Fan":
            hvacCommand.mode = .fan
            pressedFan()
        default:
            hvacCommand.mode = .auto
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
    @IBAction func btnCoolPressed(_ sender: UIButton) {
        hvacCommand.mode = .cool
        pressedCool()
    }
    @IBAction func btnHeatPressed(_ sender: UIButton) {
        hvacCommand.mode = .heat
        pressedHeat()
    }
    @IBAction func fan(_ sender: UIButton) {
        hvacCommand.mode = .fan
        pressedFan()
    }
    @IBAction func auto(_ sender: UIButton) {
        hvacCommand.mode = .auto
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
    
    @IBAction func low(_ sender: AnyObject) {
        hvacCommand.fan = .low
        pressedLow()
    }
    
    @IBAction func med(_ sender: AnyObject) {
        hvacCommand.fan = .med
        pressedMed()
    }
    
    @IBAction func high(_ sender: AnyObject) {
        hvacCommand.fan = .high
        pressedHigh()
    }
    
    @IBAction func fanAuto(_ sender: AnyObject) {
        hvacCommand.fan = .auto
        pressedAutoSecond()
    }
    
    @IBAction func onOff(_ sender: AnyObject) {
        if device.currentValue == 0x00 {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0xFF), gateway: device.gateway)
        }
        if device.currentValue == 0xFF {
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: UInt8(Int(device.channel)), status: 0x00), gateway: device.gateway)
        }
    }
    
    @IBAction func lowCool(_ sender: AnyObject) {
        if coolNumber >= 1 {
            coolNumber -= 1
            lblCool.text = "\(coolNumber)"
            hvacCommand.coolTemperature = coolNumber
        }
    }
    
    @IBAction func highCool(_ sender: AnyObject) {
        if coolNumber <= 36 {
            coolNumber += 1
            lblCool.text = "\(coolNumber)"
            hvacCommand.coolTemperature = coolNumber
        }
    }
    
    func coolTemeperatureUpdate (_ timer:Foundation.Timer) {
        if let number = timer.userInfo as? Int {
            temperatureNumber = 0
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSetPoint(address, channel: UInt8(Int(device.channel)), coolingSetPoint: UInt8(Int(device.coolTemperature)+number), heatingSetPoint: UInt8(Int(device.heatTemperature))), gateway: device.gateway)
        }
    }
    
    @IBAction func lowHeat(_ sender: AnyObject) {
        if heatNumber >= 1 {
            heatNumber -= 1
            lblHeat.text = "\(heatNumber)"
            hvacCommand.heatTemperature = heatNumber
        }
    }
    
    @IBAction func highHeat(_ sender: AnyObject) {
        if heatNumber <= 36 {
            heatNumber += 1
            lblHeat.text = "\(heatNumber)"
            hvacCommand.heatTemperature = heatNumber
        }
    }
    func heatTemeperatureUpdate (_ timer:Foundation.Timer) {
        if let number = timer.userInfo as? Int {
            temperatureNumber = 0
            let address = [UInt8(Int(device.gateway.addressOne)),UInt8(Int(device.gateway.addressTwo)),UInt8(Int(device.address))]
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSetPoint(address, channel: UInt8(Int(device.channel)), coolingSetPoint: UInt8(Int(device.coolTemperature)), heatingSetPoint: UInt8(Int(device.heatTemperature)+number)), gateway: device.gateway)
        }
    }

}

extension UIViewController {
    func showClimaSettings(_ indexPathRow: Int, devices:[Device]) {
        let ad = ClimaSettingsViewController(device: devices[indexPathRow])
        ad.indexPathRow = indexPathRow
        ad.devices = devices
        self.present(ad, animated: true, completion: nil)
    }
}
