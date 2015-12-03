//
//  DeviceCollectionViewCells.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 12/3/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import Foundation

//Light
class DeviceCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: CustomGradientBackground!
    @IBOutlet weak var typeOfLight: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var lightSlider: UISlider!
    
    @IBOutlet weak var disabledCellView: UIView!
    var device:Device?
    func getDevice (device:Device) {
        self.device = device
    }
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBAction func btnRefresh(sender: AnyObject) {
        let address = [UInt8(Int(device!.gateway.addressOne)),UInt8(Int(device!.gateway.addressTwo)),UInt8(Int(device!.address))]
        SendingHandler.sendCommand(byteArray: Function.getLightRelayStatus(address), gateway: device!.gateway)
        SendingHandler.sendCommand(byteArray: Function.resetRunningTime(address, channel: 0xFF), gateway: device!.gateway)
    }
}
//Appliance on/off
class ApplianceCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var onOff: UIButton!
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
//curtain
class CurtainCollectionCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var curtainName: UILabel!
    @IBOutlet weak var curtainImage: UIImageView!
    @IBOutlet weak var curtainSlider: UISlider!
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelRunningTime: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
//Door
class AccessControllCell: UICollectionViewCell {
    @IBOutlet weak var accessLabel: UILabel!
    @IBOutlet weak var accessImage: UIImageView!
}
//Clima
class ClimateCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var imageOnOff: UIImageView!
    @IBOutlet weak var climateName: UILabel!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var temperatureSetPoint: UILabel!
    @IBOutlet weak var climateMode: UILabel!
    @IBOutlet weak var modeImage: UIImageView!
    @IBOutlet weak var climateSpeed: UILabel!
    @IBOutlet weak var fanSpeedImage: UIImageView!
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblVoltage: UILabel!
    @IBOutlet weak var labelPowrUsege: UILabel!
    @IBOutlet weak var lblElectricity: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
}
//Multisensor 10 in 1 and 6 in 1
class MultiSensorCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var sensorTitle: UILabel!
    @IBOutlet weak var sensorState: UILabel!
    
    @IBOutlet weak var disabledCellView: UIView!
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCategory: UILabel!
    @IBOutlet weak var labelLevel: UILabel!
    @IBOutlet weak var labelZone: UILabel!
}


