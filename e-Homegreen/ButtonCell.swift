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
    
    var shadowColor: UIColor!
    
    var backgroundLayer: CAGradientLayer!
    
    @IBOutlet weak var realButton: RealButton!
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
            realButton.center = contentView.center
            realButton.layoutIfNeeded()
            
            switch button.buttonColor! {
                case ButtonColor.red   : shadowColor = .red
                case ButtonColor.blue  : shadowColor = .blue
                case ButtonColor.gray  : shadowColor = Colors.AndroidGrayColor
                case ButtonColor.green : shadowColor = .green
                default: shadowColor = .black
            }
            
            realButton.button = button
            setButton(button: button)
            layoutIfNeeded()
            //setNeedsLayout()
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setButtonColor()
        setShadows()
    }
    
}

// MARK: - Button setup
extension ButtonCell {
    
    func updateCell() {
        backgroundColor              = .clear
        clipsToBounds                = true
        layer.masksToBounds          = true
        contentView.backgroundColor  = .clear
        contentView.clipsToBounds    = true
        realButton.layer.borderWidth = 1
    }
    

    
    // MARK: - Gradient background & Shadows
    fileprivate func setButtonColor() {
        removeGradient()
        
        var color: UIColor!
        switch button.buttonState! {
        case ButtonState.visible, ButtonState.disable:
            switch button.buttonColor! {
                case ButtonColor.red    : color = .red
                case ButtonColor.gray   : color = Colors.AndroidGrayColor
                case ButtonColor.green  : color = .green
                case ButtonColor.blue   : color = .blue
                default                 : color = .clear
            }
        default: color = .clear
        }
        
        addGradient(color: color)
        //realButton.setGradientBackground(colors: [color.withAlphaComponent(0.5).cgColor, color.cgColor])
        
        if let imageView = realButton.imageView {
            realButton.bringSubview(toFront: imageView)
        }
        
        switch button.buttonState! {
            case ButtonState.visible                        :
                switch button.buttonInternalType! {
                    case ButtonInternalType.image       : hideBorder()
                    case ButtonInternalType.imageButton : showBorder()
                    case ButtonInternalType.regular     : showBorder()
                    default: break
                }
            case ButtonState.invisible, ButtonState.disable : hideBorder()
            default: break
        }
        realButton.clipsToBounds = true
        realButton.layoutSubviews()
        realButton.layoutIfNeeded()
        realButton.setNeedsDisplay()

    }
    
    fileprivate func removeGradient() {
        if backgroundLayer != nil { backgroundLayer.removeFromSuperlayer() }
//        if (realButton.layer.sublayers?[0] != nil && realButton.layer.sublayers?[0] is CAGradientLayer) { realButton.layer.sublayers![0].removeFromSuperlayer() }
    }
    
    fileprivate func setShadows() {
        switch button.buttonState! {
            case ButtonState.visible:
                switch button.buttonInternalType! {
                    case ButtonInternalType.image       : hideShadows()
                    case ButtonInternalType.imageButton : showShadows()
                    case ButtonInternalType.regular     : showShadows()
                    default: break
                }
            case ButtonState.invisible, ButtonState.disable: hideShadows()
            default: break
        }
    }
    
    func showShadows() {
        //realButton.addButtonShadows()
        realButton.needsShadow = true
    }
    func hideShadows() {
        //realButton.addButtonShadows(isOn: false)
        realButton.needsShadow = false
    }
    
    func showBorder() {
        realButton.layer.borderColor = Colors.DarkGray
    }
    func hideBorder() {
        realButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Visibility
    func setVisible() {
        realButton.isHidden                 = false
        realButton.isUserInteractionEnabled = true
    }
    
    func setInvisible() {
        realButton.isHidden                 = true
        realButton.isUserInteractionEnabled = true
    }
    
    func setDisabled() {
        realButton.isHidden                 = false
        realButton.isUserInteractionEnabled = false
    }
    
    // MARK: - Button Internal Type
    fileprivate func setupImageButton() {
        setButtonColor()
        setShadows()
        scaleAndSetButtonImage()
    }
    
    fileprivate func setupImage() {
        removeGradient()
        setShadows()
        scaleAndSetButtonImage()
    }
    
    fileprivate func setupRegular() {
        setButtonColor()
        setShadows()
        realButton.setImage(nil, for: UIControlState())
    }
    
    func setButton(button: RemoteButton) {
        
        switch button.buttonShape! {
            case ButtonShape.circle       :
                realButton.frame.size = CGSize(width: height, height: height)
                realButton.layer.cornerRadius = height / 2
                btnWidthConstraint.constant   = height
                btnHeightConstraint.constant  = height
            case ButtonShape.rectangle    :
                realButton.frame.size = CGSize(width: width, height: height)
                realButton.layer.cornerRadius = 3
                btnWidthConstraint.constant   = width
                btnHeightConstraint.constant  = height
            default: break
        }
        
        realButton.layoutIfNeeded()
        
        switch button.buttonState! {
            case ButtonState.visible    : setVisible()
            case ButtonState.invisible  : setInvisible()
            case ButtonState.disable    : setDisabled()
            default: break
        }
        
        realButton.setTitle(button.name, for: UIControlState())
        realButton.setTitleColor(.white, for: UIControlState())
        if let rbLabel = realButton.titleLabel {        
            rbLabel.textAlignment             = .center
            rbLabel.font                      = .tahoma(size: 15)
            rbLabel.adjustsFontSizeToFitWidth = true
        }
        
        let tap  = UITapGestureRecognizer(target: self, action: #selector(sendCommand)); tap.numberOfTapsRequired = 1
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(openButtonSettings)); lpgr.minimumPressDuration = 1.0
        realButton.addGestureRecognizer(tap)
        addGestureRecognizer(lpgr)
        
        switch button.buttonType! {
            case ButtonType.sceneButton : loadScene()
            case ButtonType.irButton    : loadIRDevice()
            case ButtonType.hexButton   : loadHexByteArray()
            default: break
        }
        
        switch button.buttonInternalType! {
            case ButtonInternalType.image       : setupImage()
            case ButtonInternalType.imageButton : setupImageButton()
            case ButtonInternalType.regular     : setupRegular()
            default: break
        }
        
    }        

}

// MARK: - Setup Views
extension ButtonCell {
    @objc fileprivate func openButtonSettings() {
        if let vc = parentViewController as? RemoteDetailsViewController {
            vc.showRemoteButtonSettings(button: button)
        }
    }
    
    fileprivate func scaleAndSetButtonImage() {
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
        } else {
            realButton.setImage(nil, for: UIControlState())
        }
    }
    
    fileprivate func addGradient(color: UIColor) {
        let colors = [color.withAlphaComponent(0.5).cgColor, color.cgColor]
        let gradient = CAGradientLayer.gradientLayerForBounds(bounds, colors: colors)
        backgroundLayer = gradient
        realButton.layer.insertSublayer(backgroundLayer, at: 1)
    }
    
}

extension UIImage {
    fileprivate func getScaledButtonImage(x: CGFloat, y: CGFloat) -> UIImage? {
        
        let newSize = CGSize(width: size.width * x, height: size.height * y)
        
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
