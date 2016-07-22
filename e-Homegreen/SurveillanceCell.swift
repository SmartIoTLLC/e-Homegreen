//
//  SurveillanceCell.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 4/19/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import Foundation

class SurveillenceCell:UICollectionViewCell{
    
    @IBOutlet weak var lblName: MarqueeLabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    var camera:Surveillance!
    var timer:NSTimer?
    
    func setItem(surv:Surveillance, filterParametar:FilterItem){
        camera = surv
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(SurveillenceCell.update), userInfo: nil, repeats: true)
        lblName.text = getName(surv, filterParametar: filterParametar)
    }
    
    func update(){
        print(camera.name)
        SurveillanceHandler(surv: camera)
        
//        SurveillanceHandler.shared.getCameraImage(camera) { (success) in
        
            if let data = self.camera.imageData {
                self.setImageForSurveillance(UIImage(data: data))
            }else{
                self.setImageForSurveillance(UIImage(named: "loading")!)
            }
            
            if self.camera.lastDate != nil {
                let formatter = NSDateFormatter()
                formatter.timeZone = NSTimeZone.localTimeZone()
                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                self.lblTime.text = formatter.stringFromDate(self.camera.lastDate!)
            } else {
                self.lblTime.text = " "
            }

//        }
    }
    
    func getName(surv:Surveillance, filterParametar:FilterItem) -> String{
        var name:String = ""
        if surv.location!.name != filterParametar.location{
            name += surv.location!.name! + " "
        }
        if surv.surveillanceLevel != filterParametar.levelName{
            name += surv.surveillanceLevel! + " "
        }
        if surv.surveillanceZone != filterParametar.zoneName{
            name += surv.surveillanceZone! + " "
        }
        name += surv.name!
        return name
    }
    
    func setImageForSurveillance (image:UIImage?) {
        self.image.image = image
        setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        timer?.invalidate()
    }

    
}
