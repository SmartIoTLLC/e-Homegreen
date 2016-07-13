//
//  LocationCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/1/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

protocol GatewayCellDelegate{
    func deleteGateway(gateway:Gateway)
    func scanDevice(gateway:Gateway)
    func changeSwitchValue(gateway:Gateway, gatewaySwitch:UISwitch)
}

// Gateway cell
class GatewayCell: UITableViewCell {
    
    var gateway:Gateway?
    var delegate:GatewayCellDelegate?
    @IBOutlet weak var lblGatewayDeviceNumber: UILabel!
    @IBOutlet weak var lblGatewayDescription: MarqueeLabel!
    var gradientLayer: CAGradientLayer?
    
    var backColor:CGColor = UIColor().e_homegreenColor().CGColor
    
    @IBOutlet weak var buttonGatewayScan: UIButton!
    @IBOutlet weak var switchGatewayState: UISwitch!
    
    @IBOutlet weak var add1: UILabel!
    @IBOutlet weak var add2: UILabel!
    @IBOutlet weak var add3: UILabel!
    
    @IBAction func scanDevicesAction(sender: AnyObject) {
        if let gate = gateway{
            delegate?.scanDevice(gate)
        }
    }
    
    @IBAction func deleteGateway(sender: AnyObject) {
        if let gate = gateway{
            delegate?.deleteGateway(gate)
        }
    }
    
    @IBAction func changeSwitchValue(sender: AnyObject) {
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
        
        self.add1.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.add2.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.add3.layer.borderColor = UIColor.darkGrayColor().CGColor
        
    }
    
    func setItem(gateway:Gateway){
        
        self.gateway = gateway
        
        self.lblGatewayDescription.text = gateway.gatewayDescription
        self.lblGatewayDeviceNumber.text = "\(gateway.devices.count) device(s)"
        self.add1.text = returnThreeCharactersForByte(Int(gateway.addressOne))
        self.add2.text = returnThreeCharactersForByte(Int(gateway.addressTwo))
        self.add3.text = returnThreeCharactersForByte(Int(gateway.addressThree))
        self.switchGatewayState.on = gateway.turnedOn.boolValue
        if gateway.turnedOn.boolValue {
            self.buttonGatewayScan.enabled = true
        } else {
            self.buttonGatewayScan.enabled = false
        }
    }
    
    func setEhomeblue(){
        backColor = UIColor().e_homeblueColor().CGColor
        setNeedsDisplay()
    }
    
    func setEhomegreen(){
        backColor = UIColor().e_homegreenColor().CGColor
        setNeedsDisplay()
    }
    
    override func drawRect(rect: CGRect) {
        var rectNew = CGRectMake(3, 3, rect.size.width - 6, rect.size.height - 6)
        let path = UIBezierPath(roundedRect: rectNew,
                                byRoundingCorners: UIRectCorner.AllCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 1
        
        UIColor.darkGrayColor().setStroke()
        let context = UIGraphicsGetCurrentContext()
        let colors = [backColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor, UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 0.35, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
                                                  colors,
                                                  colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:self.bounds.width , y:0)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
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
    
    func setItem(location:Location, isColapsed:Bool){
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
    func deleteSurveillance(surveillance:Surveillance)
    func scanURL(surveillance:Surveillance)
}

class SurvCell: UITableViewCell{
    
    var surveillance:Surveillance?
    var delegate:SurveillanceCellDelegate?
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnUrl: CustomGradientButton!
    
    func setItem(surveillance:Surveillance){
        self.surveillance = surveillance
        self.lblName.text = surveillance.name
    }
    @IBAction func deleteSurveillance(sender: AnyObject) {
        if let surv  = surveillance{
            delegate?.deleteSurveillance(surv)
        }
    }
    
    @IBAction func URLActions(sender: AnyObject) {
        if let surv  = surveillance{
            delegate?.scanURL(surv)
        }
    }
    override func drawRect(rect: CGRect) {
        var rectNew = CGRectMake(3, 3, rect.size.width - 6, rect.size.height - 6)
        let path = UIBezierPath(roundedRect: rectNew,
                                byRoundingCorners: UIRectCorner.AllCorners,
                                cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 1
        UIColor.darkGrayColor().setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor().surveillanceColor().CGColor, UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).CGColor, UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).CGColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 0.35, 1.0]
        let gradient = CGGradientCreateWithColors(colorSpace,
                                                  colors,
                                                  colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:self.bounds.width , y:0)
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}
