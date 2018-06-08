//
//  SidemenuCollectionViewFooter.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 6/8/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//

import Foundation
import UIKit

private struct LocalConstants {
    static let imageSize: CGSize = CGSize(width: 140, height: 50)
}

class SidemenuCollectionViewFooter: UICollectionReusableView {
    
    static let reuseIdentifier: String = "SidemenuCollectionViewFooter"
    
    private let footerImageView: UIImageView! = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addFooterImageView()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addFooterImageView()
        
        setupConstraints()
    }
    
    private func addFooterImageView() {
        footerImageView.image = #imageLiteral(resourceName: "main_manu_bottom")
        footerImageView.contentMode = .scaleAspectFit
        
        addSubview(footerImageView)
    }
    
    private func setupConstraints() {
        footerImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.width.equalTo(LocalConstants.imageSize.width)
            make.height.equalTo(LocalConstants.imageSize.height)
        }
    }
}
