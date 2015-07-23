//
//  ClimaSettingsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir on 7/9/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit

class ClimaSettingsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var indexPathRow: Int = -1
    var socket:OutSocket = OutSocket(ip: "255.255.255.255", port: 9000)
    var devices:[Device] = []
    var isPresenting: Bool = true
    
    @IBOutlet weak var lblConsumption: UILabel!
    @IBOutlet weak var lblHumadity: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    
    @IBOutlet weak var settingsViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var onOffButton: UIButton!
    
    //Mode button
    @IBOutlet weak var btnCool: UIButton!
    @IBOutlet weak var btnHeat: UIButton!
    @IBOutlet weak var btnFan: UIButton!
    @IBOutlet weak var btnAuto: UIButton!
    
    //Fan button
    @IBOutlet weak var btnLow: UIButton!
    @IBOutlet weak var btnMed: UIButton!
    @IBOutlet weak var btnHigh: UIButton!
    @IBOutlet weak var btnAutoFan: UIButton!
    
    @IBOutlet weak var lblCool: UILabel!
    @IBOutlet weak var lblHeat: UILabel!
    var coolTemperature = 28
    var heatTemperature = 18
    
    @IBOutlet weak var settingsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        self.view.tag = 1
        
        btnModeSetUp()
        btnFanSetUp()
//        removeLayers()
//        btnModeSetUp()
        
        lblCool.text = "\(coolTemperature)"
        lblHeat.text = "\(heatTemperature)"
        
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.7)
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = settingsView.bounds
        gradient.colors = [UIColor.blackColor().colorWithAlphaComponent(0.95).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor]
        settingsView.layer.insertSublayer(gradient, atIndex: 0)
        settingsView.layer.borderWidth = 1
        settingsView.layer.borderColor = UIColor.lightGrayColor().CGColor
        settingsView.layer.cornerRadius = 10
        settingsView.clipsToBounds = true
        
        onOffButton.layer.cornerRadius = 20
        onOffButton.clipsToBounds = true

        // Do any additional setup after loading the view.
    }
    
    var gradientLayerForButon:CAGradientLayer = CAGradientLayer()
    var gradientLayerForButon1:CAGradientLayer = CAGradientLayer()
    var gradientLayerForButon2:CAGradientLayer = CAGradientLayer()
    var gradientLayerForButon3:CAGradientLayer = CAGradientLayer()
    
    func btnModeSetUp(){
        
//        var gradientLayerForButon:CAGradientLayer = CAGradientLayer()
        gradientLayerForButon.frame = btnCool.bounds
        gradientLayerForButon.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnCool.layer.insertSublayer(gradientLayerForButon, atIndex: 0)
        btnCool.layer.cornerRadius = 5
        btnCool.layer.borderWidth = 1
        btnCool.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnCool.clipsToBounds = true
        btnCool.setImage(UIImage(named: "cool"), forState: .Normal)
        btnCool.imageEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 1)
        btnCool.setTitle("COOL", forState: .Normal)
        btnCool.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnCool.bringSubviewToFront(btnCool.imageView!)
        
//        var gradientLayerForButon1:CAGradientLayer = CAGradientLayer()
        gradientLayerForButon1.frame = btnCool.bounds
        gradientLayerForButon1.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnHeat.layer.insertSublayer(gradientLayerForButon1, atIndex: 0)
        btnHeat.layer.cornerRadius = 5
        btnHeat.layer.borderWidth = 1
        btnHeat.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnHeat.clipsToBounds = true
        btnHeat.setImage(UIImage(named: "heat"), forState: .Normal)
        btnHeat.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnHeat.setTitle("HEAT", forState: .Normal)
        btnHeat.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnHeat.bringSubviewToFront(btnHeat.imageView!)
        
//        var gradientLayerForButon2:CAGradientLayer = CAGradientLayer()
        gradientLayerForButon2.frame = btnCool.bounds
        gradientLayerForButon2.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnFan.layer.insertSublayer(gradientLayerForButon2, atIndex: 0)
        btnFan.layer.cornerRadius = 5
        btnFan.layer.borderWidth = 1
        btnFan.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnFan.clipsToBounds = true
        btnFan.setImage(UIImage(named: "fan"), forState: .Normal)
        btnFan.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnFan.setTitle("FAN", forState: .Normal)
        btnFan.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnFan.bringSubviewToFront(btnFan.imageView!)
        
        gradientLayerForButon3.frame = btnCool.bounds
        gradientLayerForButon3.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnAuto.layer.insertSublayer(gradientLayerForButon3, atIndex: 0)
        btnAuto.layer.cornerRadius = 5
        btnAuto.layer.borderWidth = 1
        btnAuto.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnAuto.clipsToBounds = true
        btnAuto.setImage(UIImage(named: "fanauto"), forState: .Normal)
        btnAuto.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnAuto.setTitle("AUTO", forState: .Normal)
        btnAuto.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnAuto.bringSubviewToFront(btnAuto.imageView!)
        
    }
    
    var gradientLayerForFan:CAGradientLayer = CAGradientLayer()
    var gradientLayerForFan1:CAGradientLayer = CAGradientLayer()
    var gradientLayerForFan2:CAGradientLayer = CAGradientLayer()
    var gradientLayerForFan3:CAGradientLayer = CAGradientLayer()
    
    func btnFanSetUp(){
        
        
        gradientLayerForFan.frame = btnCool.bounds
        gradientLayerForFan.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnLow.layer.insertSublayer(gradientLayerForFan, atIndex: 0)
        btnLow.layer.cornerRadius = 5
        btnLow.layer.borderWidth = 1
        btnLow.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnLow.clipsToBounds = true
        btnLow.setImage(UIImage(named: "lowfan"), forState: .Normal)
        btnLow.imageEdgeInsets = UIEdgeInsetsMake(0, -1, 0, 1)
        btnLow.setTitle("LOW", forState: .Normal)
        btnLow.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnLow.bringSubviewToFront(btnLow.imageView!)
        
        
        gradientLayerForFan1.frame = btnCool.bounds
        gradientLayerForFan1.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnMed.layer.insertSublayer(gradientLayerForFan1, atIndex: 0)
        btnMed.layer.cornerRadius = 5
        btnMed.layer.borderWidth = 1
        btnMed.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnMed.clipsToBounds = true
        btnMed.setImage(UIImage(named: "medfan"), forState: .Normal)
        btnMed.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnMed.setTitle("MED", forState: .Normal)
        btnMed.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnMed.bringSubviewToFront(btnMed.imageView!)
        
        
        gradientLayerForFan2.frame = btnCool.bounds
        gradientLayerForFan2.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnHigh.layer.insertSublayer(gradientLayerForFan2, atIndex: 0)
        btnHigh.layer.cornerRadius = 5
        btnHigh.layer.borderWidth = 1
        btnHigh.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnHigh.clipsToBounds = true
        btnHigh.setImage(UIImage(named: "fan"), forState: .Normal)
        btnHigh.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnHigh.setTitle("FAN", forState: .Normal)
        btnHigh.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnHigh.bringSubviewToFront(btnHigh.imageView!)
        
        
        gradientLayerForFan3.frame = btnCool.bounds
        gradientLayerForFan3.colors = [UIColor.blackColor().colorWithAlphaComponent(0.8).CGColor, UIColor.blackColor().colorWithAlphaComponent(0.4).CGColor]
        
        btnAutoFan.layer.insertSublayer(gradientLayerForFan3, atIndex: 0)
        btnAutoFan.layer.cornerRadius = 5
        btnAutoFan.layer.borderWidth = 1
        btnAutoFan.layer.borderColor = UIColor.lightGrayColor().CGColor
        btnAutoFan.clipsToBounds = true
        btnAutoFan.setImage(UIImage(named: "fanauto"), forState: .Normal)
        btnAutoFan.imageEdgeInsets = UIEdgeInsetsMake(0, -2, 0, 2)
        btnAutoFan.setTitle("AUTO", forState: .Normal)
        btnAutoFan.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0)
        btnAutoFan.bringSubviewToFront(btnAutoFan.imageView!)
        
    }
    
    func removeLayers(){
        gradientLayerForButon.removeFromSuperlayer()
        gradientLayerForButon1.removeFromSuperlayer()
        gradientLayerForButon2.removeFromSuperlayer()
        gradientLayerForButon3.removeFromSuperlayer()
        btnCool.backgroundColor = UIColor.groupTableViewBackgroundColor()
        btnFan.backgroundColor = UIColor.groupTableViewBackgroundColor()
        btnAuto.backgroundColor = UIColor.groupTableViewBackgroundColor()
        btnHeat.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }

    
    @IBAction func btnModePressed(sender: UIButton) {
        removeLayers()
        btnHeat.layer.insertSublayer(gradientLayerForButon1, atIndex: 0)
        btnFan.layer.insertSublayer(gradientLayerForButon2, atIndex: 0)
        btnAuto.layer.insertSublayer(gradientLayerForButon3, atIndex: 0)
        btnCool.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACmode(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x00), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACmode(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x00))
    }
    
    @IBAction func test(sender: UIButton) {
        removeLayers()
        btnCool.layer.insertSublayer(gradientLayerForButon, atIndex: 0)
        btnFan.layer.insertSublayer(gradientLayerForButon2, atIndex: 0)
        btnAuto.layer.insertSublayer(gradientLayerForButon3, atIndex: 0)
        btnHeat.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACmode(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x01), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACmode(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x01))
    }

    @IBAction func fan(sender: UIButton) {
        removeLayers()
        btnCool.layer.insertSublayer(gradientLayerForButon, atIndex: 0)
        btnHeat.layer.insertSublayer(gradientLayerForButon1, atIndex: 0)
        btnAuto.layer.insertSublayer(gradientLayerForButon3, atIndex: 0)
        btnFan.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACmode(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x02), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACmode(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x02))
    }
    
    @IBAction func auto(sender: UIButton) {
        removeLayers()
        btnCool.layer.insertSublayer(gradientLayerForButon, atIndex: 0)
        btnHeat.layer.insertSublayer(gradientLayerForButon1, atIndex: 0)
        btnFan.layer.insertSublayer(gradientLayerForButon2, atIndex: 0)
        btnAuto.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACmode(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x03), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACmode(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x03))
        
    }
    
    func removeFanLayers(){
        gradientLayerForFan.removeFromSuperlayer()
        gradientLayerForFan1.removeFromSuperlayer()
        gradientLayerForFan2.removeFromSuperlayer()
        gradientLayerForFan3.removeFromSuperlayer()
        btnLow.backgroundColor = UIColor.groupTableViewBackgroundColor()
        btnMed.backgroundColor = UIColor.groupTableViewBackgroundColor()
        btnHigh.backgroundColor = UIColor.groupTableViewBackgroundColor()
        btnAutoFan.backgroundColor = UIColor.groupTableViewBackgroundColor()
    }
    
    @IBAction func low(sender: AnyObject) {
        removeFanLayers()
        btnMed.layer.insertSublayer(gradientLayerForFan1, atIndex: 0)
        btnHigh.layer.insertSublayer(gradientLayerForFan2, atIndex: 0)
        btnAutoFan.layer.insertSublayer(gradientLayerForFan3, atIndex: 0)
        btnLow.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACSpeed(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x00), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACSpeed(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x00))
    }
    
    @IBAction func med(sender: AnyObject) {
        removeFanLayers()
        btnLow.layer.insertSublayer(gradientLayerForFan, atIndex: 0)
        btnHigh.layer.insertSublayer(gradientLayerForFan2, atIndex: 0)
        btnAutoFan.layer.insertSublayer(gradientLayerForFan3, atIndex: 0)
        btnMed.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACSpeed(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x01), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACSpeed(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x01))
    }
 
    @IBAction func high(sender: AnyObject) {
        removeFanLayers()
        btnLow.layer.insertSublayer(gradientLayerForFan, atIndex: 0)
        btnMed.layer.insertSublayer(gradientLayerForFan1, atIndex: 0)
        btnAutoFan.layer.insertSublayer(gradientLayerForFan3, atIndex: 0)
        btnHigh.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACSpeed(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x02), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACSpeed(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x02))
    }
    
    @IBAction func fanAuto(sender: AnyObject) {
        removeFanLayers()
        btnLow.layer.insertSublayer(gradientLayerForFan, atIndex: 0)
        btnMed.layer.insertSublayer(gradientLayerForFan1, atIndex: 0)
        btnHigh.layer.insertSublayer(gradientLayerForFan2, atIndex: 0)
        btnAutoFan.backgroundColor = UIColor.lightTextColor()
        var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
        SendingHandler(byteArray: Functions().setACSpeed(address, channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x03), gateway: devices[indexPathRow].gateway)
//        socket.sendByte(Functions().setACSpeed(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), value: 0x03))
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func handleTap(gesture:UITapGestureRecognizer){
        var point:CGPoint = gesture.locationInView(self.view)
        var tappedView:UIView = self.view.hitTest(point, withEvent: nil)!
        println(tappedView.tag)
        if tappedView.tag == 1{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    var checkOnOf = 0x00
    @IBAction func onOff(sender: AnyObject) {
        if checkOnOf == 0x00 {
            var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
            SendingHandler(byteArray: Functions().setACStatus(address, channel: UInt8(Int(devices[indexPathRow].channel)), status: 0xFF), gateway: devices[indexPathRow].gateway)
//            socket.sendByte(Functions().setACStatus(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), status: 0xFF))
            onOffButton.setImage(UIImage(named:"poweron"), forState: UIControlState.Normal)
            checkOnOf = 0xFF
        } else {
            var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
            SendingHandler(byteArray: Functions().setACStatus(address, channel: UInt8(Int(devices[indexPathRow].channel)), status: 0x00), gateway: devices[indexPathRow].gateway)
//            socket.sendByte(Functions().setACStatus(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), status: 0x00))
            onOffButton.setImage(UIImage(named:"poweroff"), forState: UIControlState.Normal)
            checkOnOf = 0x00
        }
    }    
    
    init(){
        super.init(nibName: "ClimaSettingsViewController", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.Custom
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func lowCool(sender: AnyObject) {
        if coolTemperature >= 18 {
            coolTemperature -= 1
            lblCool.text = "\(coolTemperature)"
            var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
            SendingHandler(byteArray: Functions().setACSetPoint(address, channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)), gateway: devices[indexPathRow].gateway)
//            socket.sendByte(Functions().setACSetPoint(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)))
        }
    }
    
    @IBAction func highCool(sender: AnyObject) {
        if coolTemperature <= 36 {
            coolTemperature += 1
            lblCool.text = "\(coolTemperature)"
            var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
            SendingHandler(byteArray: Functions().setACSetPoint(address, channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)), gateway: devices[indexPathRow].gateway)
//            socket.sendByte(Functions().setACSetPoint(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)))
        }
    }
    
    @IBAction func lowHeat(sender: AnyObject) {
        if coolTemperature >= 18 {
            heatTemperature -= 1
            lblHeat.text = "\(heatTemperature)"
            var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
            SendingHandler(byteArray: Functions().setACSetPoint(address, channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)), gateway: devices[indexPathRow].gateway)
//            socket.sendByte(Functions().setACSetPoint(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)))
        }
    }
    
    @IBAction func highHeat(sender: AnyObject) {
        if coolTemperature <= 36 {
            heatTemperature += 1
            lblHeat.text = "\(heatTemperature)"
            var address = [UInt8(Int(devices[indexPathRow].gateway.addressOne)),UInt8(Int(devices[indexPathRow].gateway.addressTwo)),UInt8(Int(devices[indexPathRow].address))]
            SendingHandler(byteArray: Functions().setACSetPoint(address, channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)), gateway: devices[indexPathRow].gateway)
//            socket.sendByte(Functions().setACSetPoint(UInt8(Int(devices[indexPathRow].address)), channel: UInt8(Int(devices[indexPathRow].channel)), coolingSetPoint: UInt8(coolTemperature), heatingSetPoint: UInt8(heatTemperature)))
        }
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.height == 320{
                settingsViewConstraint.constant = 300
                
            }else if self.view.frame.size.height == 375{
                settingsViewConstraint.constant = 340
            }else if self.view.frame.size.height == 414{
                settingsViewConstraint.constant = 390
            }else{
                settingsViewConstraint.constant = 420
            }
        }else{
            
            settingsViewConstraint.constant = 420
            
        }
    }
    
    
    


}

extension ClimaSettingsViewController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        if isPresenting == true{
            isPresenting = false
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
            //        presentedControllerView.center.y -= containerView.bounds.size.height
            presentedControllerView.alpha = 0
            presentedControllerView.transform = CGAffineTransformMakeScale(1.05, 1.05)
            containerView.addSubview(presentedControllerView)
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //            presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 1
                presentedControllerView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let containerView = transitionContext.containerView()
            
            // Animate the presented view off the bottom of the view
            UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .AllowUserInteraction, animations: {
                //                presentedControllerView.center.y += containerView.bounds.size.height
                presentedControllerView.alpha = 0
                presentedControllerView.transform = CGAffineTransformMakeScale(1.1, 1.1)
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension ClimaSettingsViewController : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        }
        else {
            return nil
        }
    }
    
}
extension UIViewController {
    func showClimaSettings(indexPathRow: Int, devices:[Device]) {
        var ad = ClimaSettingsViewController()
        ad.indexPathRow = indexPathRow
//        ad.socket = socket
        ad.devices = devices
        self.view.window?.rootViewController?.presentViewController(ad, animated: true, completion: nil)
    }
}
