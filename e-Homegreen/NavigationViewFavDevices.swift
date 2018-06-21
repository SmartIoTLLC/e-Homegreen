//
//  NavigationViewFavDevices.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 4/24/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation

enum FavDeviceFilterType: String {
    case locationLevelZoneName = "LOCATION LEVEL ZONE NAME"
    case levelZoneName         = "LEVEL ZONE NAME"
    case zoneName              = "ZONE NAME"
    case deviceName            = "NAME"
}

private struct LocalConstants {
    static let frameWidth: CGFloat = 240
    static let itemPadding: CGFloat = 4
    static let labelSize: CGSize = CGSize(width: 80, height: 44)
    static let filterButtonWidthMeasure: CGFloat = (240 - 84 - 4) / 4
    static let filterButtonHeight: CGFloat = 40
}

class NavigationViewFavDevices: UIView {
    
    private var filterType: FavDeviceFilterType!
    
    private let favLabel: UILabel = UILabel()
    private let filterButton: CustomGradientButton = CustomGradientButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        addFavoriteLabel()
        addFilterButton()
        
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = .black
        
        addFavoriteLabel()
        addFilterButton()
        
        setConstraints()
    }
    
    private func addFavoriteLabel() {
        filterType = FavDeviceFilterType(rawValue: Foundation.UserDefaults.standard.string(forKey: UserDefaults.FavDevicesLabelType)!)!
        favLabel.font = .tahoma(size: 17)
        favLabel.text = "Favorites"
        favLabel.textColor = .white
        
        addSubview(favLabel)
    }
    
    private func addFilterButton() {
        filterButton.addTarget(self, action: #selector(changeType), for: .touchUpInside)
        filterButton.titleLabel?.font = .tahoma(size: 17)
        filterButton.titleLabel?.adjustsFontSizeToFitWidth = true
        filterButton.setTitle(filterType.rawValue, for: UIControlState())
        
        
        addSubview(filterButton)
    }
    
    fileprivate func setConstraints() {
        changeFilterButtonConstraints()
        
        favLabel.snp.makeConstraints { (make) in
            make.height.equalTo(LocalConstants.labelSize.height)
            make.width.equalTo(LocalConstants.labelSize.width)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(LocalConstants.itemPadding)
        }
        
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
        changeFilterButtonConstraints()
        NotificationCenter.default.post(name: .favDeviceFilterTypeChanged, object: filterType)
    }
    
    fileprivate func changeFilterButtonConstraints() {
        var i: CGFloat = 1
        switch filterType {
            case .locationLevelZoneName : i = 4
            case .levelZoneName         : i = 3
            case .zoneName              : i = 2
            case .deviceName            : i = 1
            default: break
        }
        
        filterButton.snp.remakeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(LocalConstants.itemPadding)
            make.width.equalTo(LocalConstants.filterButtonWidthMeasure * i)
        }
    }
}

extension Notification.Name {
    static let favDeviceFilterTypeChanged = Notification.Name("favDeviceFilterTypeChanged")
}
