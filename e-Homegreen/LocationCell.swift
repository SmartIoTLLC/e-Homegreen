//
//  LocationCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

protocol GatewayCellDelegate{
    func deleteGateway(_ gateway:Gateway, sender:UIButton)
    func scanDevice(_ gateway:Gateway)
    func changeSwitchValue(_ gateway:Gateway, gatewaySwitch:UISwitch)
}

// Gateway cell
class GatewayCell: UITableViewCell {
    
    var gateway:Gateway?
    var delegate:GatewayCellDelegate?
    @IBOutlet weak var lblGatewayDeviceNumber: UILabel!
    @IBOutlet weak var lblGatewayDescription: MarqueeLabel!
    var gradientLayer: CAGradientLayer?
    
    var backColor:CGColor = UIColor().e_homegreenColor().cgColor
    
    @IBOutlet weak var buttonGatewayScan: UIButton!
    @IBOutlet weak var switchGatewayState: UISwitch!
    
    @IBOutlet weak var add1: UILabel!
    @IBOutlet weak var add2: UILabel!
    @IBOutlet weak var add3: UILabel!
    
    @IBAction func scanDevicesAction(_ sender: AnyObject) {
        if let gate = gateway{
            delegate?.scanDevice(gate)
        }
    }
    
    @IBAction func deleteGateway(_ sender: UIButton) {
        if let gate = gateway{
            delegate?.deleteGateway(gate, sender: sender)
        }
    }
    
    @IBAction func changeSwitchValue(_ sender: AnyObject) {
        if let gatewaySwitch = sender as? UISwitch, let gate = gateway{
            delegate?.changeSwitchValue(gate, gatewaySwitch: gatewaySwitch)
        }
    }
    
    override func awakeFromNib() {
        self.add1.layer.cornerRadius = 2
        self.add2.layer.cornerRadius = 2
        self.add3.layer.cornerRadius = 2
        self.add1.clipsToBounds = true
        self.add2.clipsToBounds = true
        self.add3.clipsToBounds = true
        
        self.add1.layer.borderWidth = 1
        self.add2.layer.borderWidth = 1
        self.add3.layer.borderWidth = 1
        
        self.add1.layer.borderColor = UIColor.darkGray.cgColor
        self.add2.layer.borderColor = UIColor.darkGray.cgColor
        self.add3.layer.borderColor = UIColor.darkGray.cgColor
        
    }
    
    func setItem(_ gateway:Gateway){
        self.backgroundColor = UIColor.clear
        self.gateway = gateway
        
        self.lblGatewayDescription.text = gateway.gatewayDescription
        self.lblGatewayDeviceNumber.text = "\(gateway.devices.count) device(s)"
        self.add1.text = returnThreeCharactersForByte(Int(gateway.addressOne))
        self.add2.text = returnThreeCharactersForByte(Int(gateway.addressTwo))
        self.add3.text = returnThreeCharactersForByte(Int(gateway.addressThree))
        self.switchGatewayState.isOn = gateway.turnedOn.boolValue
        if gateway.turnedOn.boolValue {
            self.buttonGatewayScan.isEnabled = true
        } else {
            self.buttonGatewayScan.isEnabled = false
        }
    }
    
    func setEhomeblue(){
        backColor = UIColor().e_homeblueColor().cgColor
        setNeedsDisplay()
    }
    
    func setEhomegreen(){
        backColor = UIColor().e_homegreenColor().cgColor
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let rectNew = CGRect(x: 3, y: 3, width: rect.size.width - 6, height: rect.size.height - 6)
        let path = UIBezierPath(roundedRect: rectNew,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 1
        
        UIColor.darkGray.setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [backColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor, UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 0.35, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                                  colors: colors as CFArray,
                                                  locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:self.bounds.width , y:0)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
    
}

//location cell
class LocationCell: UITableViewCell {
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    func setItem(_ location:Location, isColapsed:Bool){
        locationNameLabel.text = location.name
        if isColapsed{
            arrowImage.image = UIImage(named: "strelica_gore")
        }else{
            arrowImage.image = UIImage(named: "strelica_dole")
        }
    }
    
}

//surveillance cell
protocol SurveillanceCellDelegate{
    func deleteSurveillance(_ surveillance:Surveillance, sender:UIButton)
    func scanURL(_ surveillance:Surveillance)
}

class SurvCell: UITableViewCell{
    
    var surveillance:Surveillance?
    var delegate:SurveillanceCellDelegate?
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnUrl: CustomGradientButton!
    
    func setItem(_ surveillance:Surveillance){
        self.backgroundColor = UIColor.clear
        self.surveillance = surveillance
        self.lblName.text = surveillance.name
    }
    @IBAction func deleteSurveillance(_ sender: UIButton) {
        if let surv  = surveillance{
            delegate?.deleteSurveillance(surv, sender: sender)
        }
    }
    
    @IBAction func URLActions(_ sender: AnyObject) {
        if let surv  = surveillance{
            delegate?.scanURL(surv)
        }
    }
    override func draw(_ rect: CGRect) {
        let rectNew = CGRect(x: 3, y: 3, width: rect.size.width - 6, height: rect.size.height - 6)
        let path = UIBezierPath(roundedRect: rectNew,
                                byRoundingCorners: UIRectCorner.allCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 1
        UIColor.darkGray.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor().surveillanceColor().cgColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor, UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 0.35, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                                  colors: colors as CFArray,
                                                  locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:self.bounds.width , y:0)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}
