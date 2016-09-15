//
//  BigSliderXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 8/29/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol BigSliderDelegate {
    func valueChanged(sender:UISlider)
    func endValueChanged(sender:UISlider)
    func setONOFFDimmer(index:Int, turnOff: Bool)
}

class BigSliderXIB: CommonXIBTransitionVC {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var slider: UISlider!
    
    var device:Device!
    var index:Int!
    
    var delegate:BigSliderDelegate?
    
    init(device: Device, index:Int){
        super.init(nibName: "BigSliderXIB", bundle: nil)
        
        self.device = device
        self.index = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BigSliderXIB.changeSliderValueOnOneTap(_:))))
        
        slider.value = Float(device.currentValue)/255
        slider.tag = index

        // Do any additional setup after loading the view.
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isDescendantOfView(backView){
            return false
        }
        return true
    }
    
    func changeSliderValueOnOneTap (gesture:UIGestureRecognizer) {
        let s = gesture.view as! UISlider
        if s.highlighted{
            return // tap on thumb, let slider deal with it
        }
        let pt:CGPoint = gesture.locationInView(s)
        let percentage:CGFloat = pt.x / s.bounds.size.width
        let delta:CGFloat = percentage * (CGFloat(s.maximumValue) - CGFloat(s.minimumValue))
        let value:CGFloat = CGFloat(s.minimumValue) + delta;
        s.setValue(Float(value), animated: true)
        delegate?.valueChanged(slider)
    }
    
    @IBAction func on(sender: AnyObject) {
        delegate?.setONOFFDimmer(index, turnOff: false)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func off(sender: AnyObject) {
        delegate?.setONOFFDimmer(index, turnOff: true)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func changeValue(sender: UISlider) {
        delegate?.valueChanged(sender)
    }
    
    @IBAction func end(sender: UISlider) {
        delegate?.endValueChanged(sender)
    }
    
}

extension UIViewController {
    func showBigSlider(device: Device, index:Int) -> BigSliderXIB {
        let vc = BigSliderXIB(device: device, index: index)
        self.presentViewController(vc, animated: true, completion: nil)
        return vc
    }
}
