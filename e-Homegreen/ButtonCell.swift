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
    
    var needsShadow: Bool = true {
        didSet {
            setShadow()
        }
    }
    var shadowLayer: CAShapeLayer!
    var shadowColor: UIColor!
    
    var backgroundLayer: CAGradientLayer!
    
    @IBOutlet weak var realButton: RealButton!
    @IBOutlet weak var btnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnHeightConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removeGradient()
    }
    
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
                default                : shadowColor = .black
            }
            layoutIfNeeded()
            setNeedsDisplay()
            setButton(button: button)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setShadows()
        setButtonColor()
    }
    
}

// MARK: - Button setup
extension ButtonCell {
    
    func updateCell() {
        backgroundColor                = .clear
        clipsToBounds                  = true
        layer.masksToBounds            = true
        contentView.backgroundColor    = .clear
        contentView.clipsToBounds      = true
        realButton.layer.borderWidth   = 1
        realButton.layer.masksToBounds = true
    }
    
    // MARK: - Gradient background & Shadows
    fileprivate func setButtonColor() {
        removeGradient()
        
        var color: UIColor! = .clear
        switch button.buttonState! {
            case ButtonState.visible, ButtonState.disable:
                switch button.buttonInternalType! {
                    case ButtonInternalType.image   : color = .clear
                    case ButtonInternalType.imageButton, ButtonInternalType.regular:
                        switch button.buttonColor! {
                            case ButtonColor.red    : color = .red
                            case ButtonColor.gray   : color = Colors.AndroidGrayColor
                            case ButtonColor.green  : color = .green
                            case ButtonColor.blue   : color = .blue
                            default                 : break
                        }
                    default: break
                }
            case ButtonState.invisible: color = .clear
            default: break
        }
        if color != .clear { addGradient(color: color) } else { removeGradient() }
        if let imageView = realButton.imageView { realButton.bringSubview(toFront: imageView) }
        
        switch button.buttonState! {
            case ButtonState.visible                        :
                switch button.buttonInternalType! {
                    case ButtonInternalType.image       : hideBorder()
                    case ButtonInternalType.imageButton : showBorder()
                    case ButtonInternalType.regular     : showBorder()
                    default                             : break
                }
            case ButtonState.invisible, ButtonState.disable : hideBorder()
            default                                         : break
        }
    }
    
    fileprivate func removeGradient() {
        if backgroundLayer != nil { backgroundLayer.removeFromSuperlayer() }
    }
    
    fileprivate func setShadows() {
        switch button.buttonState! {
            case ButtonState.visible:
                switch button.buttonInternalType! {
                    case ButtonInternalType.image       : needsShadow = false
                    case ButtonInternalType.imageButton : needsShadow = true
                    case ButtonInternalType.regular     : needsShadow = true
                    default: break
                }
            case ButtonState.invisible, ButtonState.disable: needsShadow = false
            default: break
        }
    }
    
    fileprivate func setShadow() {
        var color: CGColor! = UIColor.clear.cgColor
        if shadowLayer != nil { shadowLayer.removeFromSuperlayer() }
        if needsShadow { color = UIColor.black.cgColor } else { color = UIColor.clear.cgColor }
        
        shadowLayer = CAShapeLayer()
        switch button.buttonShape! {
            case ButtonShape.rectangle : shadowLayer.path = UIBezierPath(roundedRect: realButton.bounds, cornerRadius: 3).cgPath
            case ButtonShape.circle    : shadowLayer.path = UIBezierPath(roundedRect: realButton.bounds, cornerRadius: bounds.height / 2).cgPath
            default: break
        }
        shadowLayer.fillColor     = UIColor.clear.cgColor
        shadowLayer.shadowColor   = color
        shadowLayer.shadowPath    = shadowLayer.path
        shadowLayer.shadowOffset  = CGSize(width: 1, height: 2)
        shadowLayer.shadowOpacity = 0.9
        shadowLayer.shadowRadius  = 2
        
        realButton.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func showBorder() {
        realButton.layer.borderColor = Colors.DarkGray
    }
    func hideBorder() {
        realButton.layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Button shape
    func setShape() {
        switch button.buttonShape! {
        case ButtonShape.circle       :
            realButton.layer.cornerRadius = height / 2
            btnWidthConstraint.constant   = height
        case ButtonShape.rectangle    :
            realButton.layer.cornerRadius = 3
            btnWidthConstraint.constant   = width
        default                       : break
        }
        btnHeightConstraint.constant  = height
        realButton.layoutIfNeeded()
    }
    // MARK: - Visibility
    fileprivate func setState() {
        switch button.buttonState! {
            case ButtonState.visible   : realButton.isHidden = false; realButton.isUserInteractionEnabled = true
            case ButtonState.invisible : realButton.isHidden = true; realButton.isUserInteractionEnabled = true
            case ButtonState.disable   : realButton.isHidden = false; realButton.isUserInteractionEnabled = false
            default                    : break
        }
    }
    // MARK: - Button type
    func setType() {
        switch button.buttonType! {
            case ButtonType.sceneButton : loadScene()
            case ButtonType.irButton    : loadIRDevice()
            case ButtonType.hexButton   : loadHexByteArray()
            default                     : break
        }
    }
    // MARK: - Button Internal Type
    fileprivate func setInternalType() {
        setShadow()
        setButtonColor()
        switch button.buttonInternalType! {
            case ButtonInternalType.image, ButtonInternalType.imageButton : scaleAndSetButtonImage(); realButton.setTitle(nil, for: UIControlState())
            case ButtonInternalType.regular                               : realButton.setImage(nil, for: UIControlState()); realButton.setTitle(button.name!, for: UIControlState())
            default                                                       : break
        }
    }
    
    func setButton(button: RemoteButton) {
        setShape()
        setState()
        setType()
        setInternalType()
        
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
        let bounds = CGRect(x: 0, y: 0, width: realButton.bounds.width + 200, height: realButton.bounds.height + 200)
        let gradient = CAGradientLayer.gradientLayerForBounds(bounds, colors: colors)
        backgroundLayer          = gradient
        backgroundLayer.position = realButton.center
        realButton.layer.insertSublayer(backgroundLayer, above: shadowLayer)
    }
    
}

extension UIImage {
    fileprivate func getScaledButtonImage(x: CGFloat, y: CGFloat) -> UIImage? {
        // TODO: ako su brojevi isti - nece uraditi nista
        let newSize = CGSize(width: size.width * x, height: size.height * y)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        draw(in: CGRect(origin: .zero, size: newSize))
        
        if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return newImage
        }
        
        UIGraphicsEndImageContext()
        return nil
    }
}
