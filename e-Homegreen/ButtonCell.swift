//
//  ButtonCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/2/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class ButtonCell: UICollectionViewCell {
    var width: CGFloat!
    var height: CGFloat!
    var imageScaleX: CGFloat?
    var imageScaleY: CGFloat?
    
    var scene: Scene?
    var irDevice: Device?
    var hex: [Byte]?
    
    @IBOutlet weak var realButton: UIButton!
    
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnHeightConstraint: NSLayoutConstraint!
    
    var button: RemoteButton! {
        didSet {
            width  = CGFloat(button.buttonWidth!)
            height = CGFloat(button.buttonHeight!)
            imageScaleX = CGFloat(button.imageScaleX!)
            imageScaleY = CGFloat(button.imageScaleY!)
            btnWidthConstraint.constant = width
            btnHeightConstraint.constant = height
            realButton.layoutIfNeeded()
            setButton(button: button)
            setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        updateCell()
    }
    /* TODO:
        - refaktorisati deo logike oko borderColor zbog setDisabled i setRegular
        - scale image odraditi manuelno na frame imageView-a
     
     scale - buttonframe - width*X & height*Y
     */
    
}

// MARK: - Button setup
extension ButtonCell {
    
    func updateCell() {
        backgroundColor              = .clear
        clipsToBounds                = true
        layer.masksToBounds          = true
        contentView.backgroundColor  = .clear
        contentView.clipsToBounds    = true
    }
    
    fileprivate func setButtonColor() {
        switch button.buttonColor! {
            case ButtonColor.red    : contentView.backgroundColor = .red
            case ButtonColor.gray   : contentView.backgroundColor = Colors.AndroidGrayColor
            case ButtonColor.green  : contentView.backgroundColor = .green
            case ButtonColor.blue   : contentView.backgroundColor = .red
            default                 : contentView.backgroundColor = Colors.AndroidGrayColor
        }
    }
    
    func setVisible() {
        realButton.isHidden                 = false
        realButton.isUserInteractionEnabled = true
        realButton.backgroundColor          = Colors.AndroidGrayColor
    }
    
    func setInvisible() {
        realButton.isHidden                 = true
        realButton.isUserInteractionEnabled = true
        realButton.backgroundColor          = Colors.AndroidGrayColor
    }
    
    func setDisabled() {
        realButton.isHidden                 = false
        realButton.isUserInteractionEnabled = false
        realButton.backgroundColor          = .clear
    }
    
    func setButton(button: RemoteButton) {
        setButtonColor()
        
        switch button.buttonShape! {
            case ButtonShape.circle         : realButton.frame.size = CGSize(width: height, height: height); realButton.layer.cornerRadius = height / 2
            case ButtonShape.rectangle    : realButton.frame.size = CGSize(width: width, height: height); realButton.layer.cornerRadius = 3
            default: break
        }
        
        switch button.buttonState! {
            case ButtonState.visible    : setVisible()
            case ButtonState.invisible  : setInvisible()
            case ButtonState.disable    : setDisabled()
            default: break
            // NIJE DOBRO
        }
        
        realButton.setTitle(button.name, for: UIControlState())
        realButton.setTitleColor(.white, for: UIControlState())
        realButton.titleLabel?.textAlignment             = .center
        realButton.titleLabel?.font                      = .tahoma(size: 15)
        realButton.titleLabel?.adjustsFontSizeToFitWidth = true

        let tap  = UITapGestureRecognizer(target: self, action: #selector(sendCommand)); tap.numberOfTapsRequired = 1
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(openButtonSettings)); lpgr.minimumPressDuration = 1.0
        realButton.addGestureRecognizer(tap)
        addGestureRecognizer(lpgr)
        
        switch button.buttonType! {
            case ButtonType.sceneButton : loadScene()
            case ButtonType.irButton    : loadIRDevice()
            case ButtonType.hexButton   : hex = formatHexStringToByteArray(hex: button.hexString!)
            default: break
        }
        
        switch button.buttonInternalType! {
            case ButtonInternalType.image       : setupImage()
            case ButtonInternalType.imageButton : setupImageButton()
            case ButtonInternalType.regular     : setupRegular()
            default: break
        }
    }
    
    fileprivate func setupImageButton() {
        setButtonColor()
        realButton.addShadows(opacity: 1)
        scaleAndSetButtonImage()
    }
    
    fileprivate func setupImage() {
        addShadows(opacity: 1, isOn: false)
        realButton.backgroundColor = .clear
        scaleAndSetButtonImage()
    }
    
    fileprivate func setupRegular() {
        setButtonColor()
        realButton.addShadows(opacity: 1)
        
        realButton.setImage(nil, for: UIControlState())
    }
}

// MARK: - Setup Views
extension ButtonCell {
    @objc fileprivate func openButtonSettings() {
        if let vc = parentViewController as? RemoteDetailsViewController {
            vc.showRemoteButtonSettings(button: button)
        }
    }
    
    fileprivate func scaleAndSetButtonImage() { // Ne valja kad se dodeljuje 0.5 i 0.5

        if let image = button.image {
            let uiImage = UIImage(data: image as Data)
            if imageScaleX != 1.0 || imageScaleY != 1.0 {
                if let scaledImage = uiImage?.getScaledButtonImage(x: imageScaleX!, y: imageScaleY!) {
                    realButton.setImage(scaledImage, for: UIControlState())
                }
            } else {
                realButton.setImage(uiImage, for: UIControlState())
            }
            realButton.imageView?.contentMode = .scaleAspectFit
            realButton.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        }
    }
    
}

extension UIImage {
    fileprivate func getScaledButtonImage(x: CGFloat, y: CGFloat) -> UIImage? {
        
        let newSize        = CGSize(width: size.width * x, height: size.height * y)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage
        }
        
        UIGraphicsEndImageContext()
        return nil
    }
}
