//
//  RadioStationTableViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 5/31/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

private struct LocalConstants {
    static let labelHeight: CGFloat = 21
}

class RadioStationTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "RadioStationTableViewCell"
    
    private let titleLabel: RadioLabel = RadioLabel()
    private let cityLabel: RadioLabel = RadioLabel()
    private let areaLabel: RadioLabel = RadioLabel()
    private let genreLabel: RadioLabel = RadioLabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setBackgroundView()
        
        addTitleLabel()
        addCityLabel()
        addAreaLabel()
        addGenreLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setBackgroundView()
        
        addTitleLabel()
        addCityLabel()
        addAreaLabel()
        addGenreLabel()
        
        setupConstraints()
    }
    
    private func addTitleLabel() {
        titleLabel.font = .tahoma(size: 20)
        
        addSubview(titleLabel)
    }
    
    private func addCityLabel() {
        cityLabel.font = .tahoma(size: 15)
        
        addSubview(cityLabel)
    }
    
    private func addAreaLabel() {
        areaLabel.font = .tahoma(size: 13)
        
        addSubview(areaLabel)
    }
    
    private func addGenreLabel() {
        genreLabel.font = .tahoma(size: 13)
        
        addSubview(genreLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(LocalConstants.labelHeight)
        }
        
        genreLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(GlobalConstants.sidePadding)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(LocalConstants.labelHeight)
        }
        areaLabel.snp.makeConstraints { (make) in
            make.top.equalTo(genreLabel.snp.bottom)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(LocalConstants.labelHeight)
        }
        
        cityLabel.snp.makeConstraints { (make) in
            make.top.equalTo(areaLabel.snp.bottom)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.height.equalTo(LocalConstants.labelHeight)
        }
    }
    
    func setCell(with radioStation: Radio) {
        titleLabel.text = radioStation.stationName
        genreLabel.text = radioStation.genre
        areaLabel.text  = radioStation.area
        cityLabel.text  = radioStation.city
    }
    
    func setBackgroundView() {
        backgroundColor = .clear
        
        let bg = UIView()
        bg.backgroundColor     = UIColor.white.withAlphaComponent(0.4)
        selectedBackgroundView = bg
    }
}

private class RadioLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        textColor = .white
        adjustsFontSizeToFitWidth = true
    }
}
