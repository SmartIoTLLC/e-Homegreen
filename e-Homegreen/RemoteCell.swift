//
//  RemoteCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class RemoteCell: UICollectionViewCell {
    
    var remote: RemoteDummy? {
        didSet {
            remoteNameLabel.text = remote?.buggerOff
        }
    }
    
    @IBOutlet weak var remoteNameLabel: UILabel!
    @IBOutlet weak var remoteImageView: UIImageView!
    
    func setCell(remote: RemoteDummy) {
        remoteNameLabel.textColor = .white
        remoteNameLabel.font = UIFont.tahoma(size: 14)
        remoteNameLabel.textAlignment = .center
        
        remoteImageView.image = #imageLiteral(resourceName: "Remote")
        remoteImageView.contentMode = .scaleAspectFit
        remoteImageView.isUserInteractionEnabled = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(editRemote))
        longPress.minimumPressDuration = 0.5
        remoteImageView.addGestureRecognizer(longPress)
        
        self.remote = remote
    }
    
    func editRemote() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        self.parentViewController?.showEditRemoteVC(remote: remote!)
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 5.0, height: 5.0))
        path.addClip()
        path.lineWidth = 2
        UIColor.lightGray.setStroke()
        
        let context = UIGraphicsGetCurrentContext()
        let colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).withAlphaComponent(0.95).cgColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).withAlphaComponent(1.0).cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: self.bounds.height)
        
        context?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
        path.stroke()
    }
}
