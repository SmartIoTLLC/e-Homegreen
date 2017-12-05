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
    
    var device:Device! {
        didSet {
            address = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
            channel = getByte(device.channel)
            gateway = device.gateway
        }
    }
    var address: [Byte]!
    var channel: Byte!
    var gateway: Gateway!
    
    init(device: Device){
        super.init(nibName: "ClimaSettingsViewController", bundle: nil)
        self.device = device
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: settingsView) { return false }
        return true
    }
    
    @IBAction func btnSet(_ sender: AnyObject) {
        print(hvacCommand)
        var timeInterval = 0.0
        if hvacCommand.coolTemperature != hvacCommandBefore.coolTemperature || hvacCommand.heatTemperature != hvacCommandBefore.heatTemperature {
            Foundation.Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(setACSetPoint), userInfo: nil, repeats: false)
            timeInterval += 0.3
        }
        if hvacCommand.fan != hvacCommandBefore.fan {
            Foundation.Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(setACSpeed), userInfo: nil, repeats: false)
            timeInterval += 0.3
        }
        if hvacCommand.mode != hvacCommandBefore.mode {
            Foundation.Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(setACmode), userInfo: nil, repeats: false)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func setACSetPoint () {
        SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSetPoint(address, channel: channel, coolingSetPoint: getIByte(hvacCommand.coolTemperature), heatingSetPoint: getIByte(hvacCommand.heatTemperature)), gateway: gateway)
    }
    
    func setACSpeed () {
        switch hvacCommand.fan {
            case .low   : setACSpeedWith(value: 0x01)
            case .med   : setACSpeedWith(value: 0x02)
            case .high  : setACSpeedWith(value: 0x03)
            case .auto  : setACSpeedWith(value: 0x00)
            default :break
        }
    }
    fileprivate func setACSpeedWith(value: Byte) {
        SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSpeed(address, channel: channel, value: value), gateway: gateway)
    }
    
    func setACmode () {
        switch hvacCommand.mode {
            case .cool  : setACModeWith(value: 0x01)
            case .heat  : setACModeWith(value: 0x02)
            case .fan   : setACModeWith(value: 0x03)
            case .auto  : setACModeWith(value: 0x00)
            default :break
        }
    }
    fileprivate func setACModeWith(value: Byte) {
        SendingHandler.sendCommand(byteArray: OutgoingHandler.setACmode(address, channel: channel, value: value), gateway: gateway)
    }
    
    func setupViews() {
        hvacCommand.coolTemperature = Int(device.coolTemperature)
        hvacCommand.heatTemperature = Int(device.heatTemperature)
        
        lblCool.text = "\(device.coolTemperature)"
        lblHeat.text = "\(device.heatTemperature)"
        coolNumber = Int(device.coolTemperature)
        heatNumber = Int(device.heatTemperature)
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        getACState()
        
        if device.coolModeVisible == false {
            btnCool.isHidden     = true
            coolView.isHidden    = true
            
            if device.heatModeVisible == false {
                btnHeat.isHidden            = true
                thresholdSTackView.isHidden = true
                threshholdLbl.isHidden      = true
            }
        }
        
        if device.heatModeVisible == false { btnHeat.isHidden = true; heatView.isHidden = true }
        if device.fanModeVisible == false { btnFan.isHidden = true }
        if device.autoModeVisible == false { btnAuto.isHidden = true }
        if device.coolModeVisible == false && device.heatModeVisible == false && device.fanModeVisible == false && device.autoModeVisible == false {
            modeLbl.isHidden = true
            modeStackView.isHidden = true
        }
        if device.lowSpeedVisible == false { btnLow.isHidden = true }
        if device.medSpeedVisible == false { btnMed.isHidden = true }
        if device.highSpeedVisible == false { btnHigh.isHidden = true }
        if device.autoSpeedVisible == false { btnAutoFan.isHidden = true }
        if device.lowSpeedVisible == false && device.medSpeedVisible == false && device.highSpeedVisible == false && device.autoSpeedVisible == false {
            fanLbl.isHidden = true
            fanStackView.isHidden = true
        }
        if device.temperatureVisible == false { tempLbl.isHidden = true }
        if device.humidityVisible == false { humidityLbl.isHidden = true }
        if device.temperatureVisible == false && device.humidityVisible == false {
            currentLbl.isHidden = true
            currentStackView.isHidden = true
        }
    }
    
    func updateDevice () {
        appDel = UIApplication.shared.delegate as! AppDelegate
        if let moc = appDel.managedObjectContext {
            if let fetResults = moc.object(with: devices[indexPathRow].objectID) as? Device {
                device = fetResults
            }
        }
    }
    
    func getACState () {
        updateDevice()
        let speedState = device.speed
        
        switch speedState {
            case "Low"  : hvacCommand.fan = .low; pressedLow()
            case "Med"  : hvacCommand.fan = .med; pressedMed()
            case "High" : hvacCommand.fan = .high; pressedHigh()
            default     : hvacCommand.fan = .auto; pressedAutoSecond()
        }
        
        let modeState = device.mode
        switch modeState {
            case "Cool" : hvacCommand.mode = .cool; pressedCool()
            case "Heat" : hvacCommand.mode = .heat; pressedHeat()
            case "Fan"  : hvacCommand.mode = .fan; pressedFan()
            default     : hvacCommand.mode = .auto; pressedAuto()
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
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: channel, status: 0xFF), gateway: gateway)
        }
        if device.currentValue == 0xFF {
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACStatus(address, channel: channel, status: 0x00), gateway: gateway)
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
            SendingHandler.sendCommand(byteArray: OutgoingHandler.setACSetPoint(address, channel: channel, coolingSetPoint: getByte(device.coolTemperature), heatingSetPoint: getIByte(Int(device.heatTemperature)+number)), gateway: gateway)
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
