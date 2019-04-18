//
//  BigSliderXIB.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 8/29/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

protocol BigSliderDelegate {
    func valueChanged(_ sender:UISlider)
    func endValueChanged(_ sender:UISlider)
    func setONOFFDimmer(_ index:Int, turnOff: Bool)
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
        
        setupSlider()
    }
    
    func setupSlider() {
        slider.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BigSliderXIB.changeSliderValueOnOneTap(_:))))
        
        slider.value = Float(device.currentValue)/255
        slider.tag = index
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView) { return false }
        return true
    }
    
    @objc func changeSliderValueOnOneTap (_ gesture:UIGestureRecognizer) {
        let s = gesture.view as! UISlider
        if s.isHighlighted { return } // tap on thumb, let slider deal with it
        
        let pt:CGPoint           = gesture.location(in: s)
        let percentage:CGFloat   = pt.x / s.bounds.size.width
        let delta:CGFloat        = percentage * (CGFloat(s.maximumValue) - CGFloat(s.minimumValue))
        let value:CGFloat        = CGFloat(s.minimumValue) + delta
        
        s.setValue(Float(value), animated: true)
        delegate?.valueChanged(slider)
    }
    
    @IBAction func on(_ sender: AnyObject) {
        delegate?.setONOFFDimmer(index, turnOff: false)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func off(_ sender: AnyObject) {
        delegate?.setONOFFDimmer(index, turnOff: true)
        dismiss(animated: true, completion: nil)
    }

    @IBAction func changeValue(_ sender: UISlider) {
        delegate?.valueChanged(sender)
    }
    
    @IBAction func end(_ sender: UISlider) {
        delegate?.endValueChanged(sender)
    }
    
}

extension UIViewController {
    func showBigSlider(_ device: Device, index:Int) -> BigSliderXIB {
        let vc = BigSliderXIB(device: device, index: index)
        self.present(vc, animated: true, completion: nil)
        return vc
    }
}
