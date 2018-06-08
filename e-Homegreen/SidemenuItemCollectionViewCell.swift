//
//  SidemenuItemCollectionViewCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/8/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let imageViewSize: CGFloat = 50
    static let labelHeight: CGFloat = 14.5
}

class SidemenuItemCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "SidemenuItemCollectionViewCell"
    
    private let menuItemImageView: UIImageView = UIImageView()
    private let menuItemLabel: UILabel = UILabel()
    
    private var colorOne: CGColor! = UIColor(red: 52/255, green: 52/255, blue: 49/255, alpha: 1).cgColor
    private var colorTwo: CGColor! = UIColor(red: 28/255, green: 28/255, blue: 26/255, alpha: 1).cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        addMenuItemImageView()
        addMenuItemLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
        addMenuItemImageView()
        addMenuItemLabel()
        
        setupConstraints()
    }
    
    private func addMenuItemImageView() {
        menuItemImageView.contentMode = .scaleAspectFit
        
        addSubview(menuItemImageView)
    }
    
    private func addMenuItemLabel() {
        menuItemLabel.font = .tahoma(size: 12)
        menuItemLabel.textColor = .white
        menuItemLabel.textAlignment = .center
        
        addSubview(menuItemLabel)
    }
    
    private func setup() {
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    private func setupConstraints() {
        menuItemImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(11)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(LocalConstants.imageViewSize)
        }
        
        menuItemLabel.snp.makeConstraints { (make) in
            make.top.equalTo(menuItemImageView.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(LocalConstants.labelHeight)
        }
    }
    
    func setCell(with menuItem: MenuItem) {
        
        if let item = Menu(rawValue: Int(menuItem.id)) {
            menuItemImageView.image = UIImage(named: item.description)
            menuItemLabel.text = item.description
        }
    }
    
    override var isHighlighted: Bool {
        willSet(newValue) {
            if newValue {
                colorOne = UIColor(red: 38/255, green: 38/255, blue: 38/255, alpha: 1).cgColor
                colorTwo = UIColor(red: 81/255, green: 82/255, blue: 83/255, alpha: 1).cgColor
            } else {
                colorOne = UIColor(red: 52/255, green: 52/255, blue: 49/255, alpha: 1).cgColor
                colorTwo = UIColor(red: 28/255, green: 28/255, blue: 26/255, alpha: 1).cgColor
            }
        }
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        let colors = [ colorOne, colorTwo]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations:[CGFloat] = [0.0, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x:0, y:bounds.height)
        context!.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))
    }
}
