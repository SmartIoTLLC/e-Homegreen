//
//  NavigationViewFavDevices.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 2/27/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation

enum FavDeviceFilterType: String {
    case locationLevelZoneName = "LOCATION LEVEL ZONE NAME"
    case levelZoneName         = "LEVEL ZONE NAME"
    case zoneName              = "ZONE NAME"
    case deviceName            = "NAME"
}

class NavigationViewFavDevices: UIView {

    private var filterType: FavDeviceFilterType!
    
    var favLabel: UILabel!
    var filterButton: CustomGradientButton!
    var fbWidthMeasure: CGFloat!

    var buttonTrailing: NSLayoutConstraint!
    var buttonTop: NSLayoutConstraint!
    var buttonBottom: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        setConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        favLabel.frame = CGRect(x: 4, y: 0, width: 80, height: 44)
        favLabel.layoutIfNeeded()
        changeButtonWidth()
    }
    
    fileprivate func setupViews() {
        filterType = FavDeviceFilterType(rawValue: Foundation.UserDefaults.standard.string(forKey: UserDefaults.FavDevicesLabelType)!)!
        favLabel = UILabel(frame: CGRect(x: 4, y: 0, width: 80, height: 44))
        favLabel.font = .tahoma(size: 17)
        favLabel.text = "Favorites"
        favLabel.textColor = .white
        favLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fbWidthMeasure = (frame.width - 84 - 4) / 4
        filterButton = CustomGradientButton(frame: CGRect(x: 84, y: 0, width: fbWidthMeasure, height: 40))
        filterButton.addTarget(self, action: #selector(changeType), for: .touchUpInside)
        filterButton.titleLabel?.font = .tahoma(size: 17)
        filterButton.titleLabel?.adjustsFontSizeToFitWidth = true
        filterButton.setTitle(filterType.rawValue, for: UIControlState())
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(favLabel)
        addSubview(filterButton)
        
        backgroundColor = .black
    }
    
    fileprivate func setConstraints() {
        buttonTrailing    = NSLayoutConstraint(item: filterButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 4)
        buttonTop         = NSLayoutConstraint(item: filterButton, attribute: .topMargin, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        buttonBottom      = NSLayoutConstraint(item: filterButton, attribute: .bottomMargin, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        
        self.addConstraints(
            [buttonTrailing,
             buttonTop,
             buttonBottom]
        )
    }
    
    @objc fileprivate func changeType() {
        switch filterType {
            case .locationLevelZoneName : filterType = .levelZoneName
            case .levelZoneName         : filterType = .zoneName
            case .zoneName              : filterType = .deviceName
            case .deviceName            : filterType = .locationLevelZoneName
            default: break
        }
        filterButton.setTitle(filterType.rawValue, for: UIControlState())
        Foundation.UserDefaults.standard.set(filterType.rawValue, forKey: UserDefaults.FavDevicesLabelType)
        changeButtonWidth()
        NotificationCenter.default.post(name: .favDeviceFilterTypeChanged, object: filterType)
    }
    fileprivate func changeButtonWidth() {
        var i: CGFloat = 1
        switch filterType {
            case .locationLevelZoneName : i = 4
            case .levelZoneName         : i = 3
            case .zoneName              : i = 2
            case .deviceName            : i = 1
            default: break
        }
        filterButton.frame = CGRect(x: frame.width - fbWidthMeasure * i, y: 0, width: fbWidthMeasure * i, height: 40)
        filterButton.layoutIfNeeded()
    }
}

extension Notification.Name {
    static let favDeviceFilterTypeChanged = Notification.Name("favDeviceFilterTypeChanged")
}
