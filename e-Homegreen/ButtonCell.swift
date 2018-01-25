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
        
        var color: UIColor!
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
                            default                 : color = .clear
                        }
                    default: color = .clear
                }

            default: color = .clear
        }
        
        addGradient(color: color)
        
        if let imageView = realButton.imageView {
            realButton.bringSubview(toFront: imageView)
        }
        
        switch button.buttonState! {
            case ButtonState.visible                        :
                switch button.buttonInternalType! {
                case ButtonInternalType.image       : hideBorder()
                case ButtonInternalType.imageButton : showBorder()
                case ButtonInternalType.regular     : showBorder()
                default: showBorder()
                }
            case ButtonState.invisible, ButtonState.disable : hideBorder()
            default: showBorder()
        }

    }
    
    fileprivate func removeGradient() {
        if backgroundLayer != nil { backgroundLayer.removeFromSuperlayer() }
    }
    
    fileprivate func setShadows() {
        switch button.buttonState! {
            case ButtonState.visible:
                switch button.buttonInternalType! {
                case ButtonInternalType.image       : hideShadows()
                case ButtonInternalType.imageButton : showShadows()
                case ButtonInternalType.regular     : showShadows()
                default: showShadows()
                }
            case ButtonState.invisible, ButtonState.disable: hideShadows()
            default: showShadows()
        }
    }
    
    func showShadows() {
        needsShadow = true
    }
    func hideShadows() {
        needsShadow = false
    }
    
    fileprivate func setShadow() {
        var color: CGColor! = UIColor.clear.cgColor
        if shadowLayer != nil { shadowLayer.removeFromSuperlayer() }
        if needsShadow { color = UIColor.black.cgColor }
        
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
        setShadows()
        setButtonColor()
        scaleAndSetButtonImage()
    }
    
    fileprivate func setupImage() {
        setShadows()
        setButtonColor()
        scaleAndSetButtonImage()
    }
    
    fileprivate func setupRegular() {
        setShadows()
        setButtonColor()
        realButton.setImage(nil, for: UIControlState())
    }
    
    func setButton(button: RemoteButton) {
        
        switch button.buttonShape! {
        case ButtonShape.circle       :
            realButton.layer.cornerRadius = height / 2
            btnWidthConstraint.constant   = height
            btnHeightConstraint.constant  = height
        case ButtonShape.rectangle    :
            realButton.layer.cornerRadius = 3
            btnWidthConstraint.constant   = width
            btnHeightConstraint.constant  = height
        default:
            realButton.layer.cornerRadius = height / 2
            btnWidthConstraint.constant   = height
            btnHeightConstraint.constant  = height
        }
        
        realButton.layoutIfNeeded()
        
        switch button.buttonState! {
            case ButtonState.visible    : setVisible()
            case ButtonState.invisible  : setInvisible()
            case ButtonState.disable    : setDisabled()
            default: setVisible()
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
            default: loadScene()
        }
        
        switch button.buttonInternalType! {
            case ButtonInternalType.image       : setupImage()
            case ButtonInternalType.imageButton : setupImageButton()
            case ButtonInternalType.regular     : setupRegular()
            default: setupRegular()
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
        let colors   = [color.withAlphaComponent(0.5).cgColor, color.cgColor]
        let bounds = CGRect(x: 0, y: 0, width: self.bounds.width + 2000, height: self.bounds.height)
        let gradient = CAGradientLayer.gradientLayerForBounds(bounds, colors: colors)
        backgroundLayer          = gradient
        backgroundLayer.position = realButton.center
//        var index: UInt32 = 0
//        if needsShadow { index = 1 }
//        realButton.layer.insertSublayer(backgroundLayer, at: index)
        realButton.layer.insertSublayer(backgroundLayer, above: shadowLayer)
    }
    
}

extension UIImage {
    fileprivate func getScaledButtonImage(x: CGFloat, y: CGFloat) -> UIImage? {
        
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
