//
//  MacrosCell.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/21/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

class MacrosCell: UICollectionViewCell {
    
    var nameLabel: UILabel!
    var logoImageView: UIImageView!
    var startButton: UIButton!
    var stopButton: UIButton!
    var thirdStateButton: UIButton! //for queue and restart functions
    
    var cellHeight: CGFloat!
    var cellWidth: CGFloat!
  
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        cellWidth = 150
        cellHeight = 180
        
        nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 3.0, y: 8.0, width: cellWidth - 6, height: 18.5)
        nameLabel.textAlignment = .center
        nameLabel.textColor = .white
        nameLabel.font = .tahoma(size: 14)
        
        logoImageView = UIImageView()
        logoImageView.frame = CGRect(x: 20, y: nameLabel.frame.maxY + 3, width: cellWidth - 40, height: 110)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.isUserInteractionEnabled = true
        
        //add to view
        contentView.addSubview(nameLabel)
        contentView.addSubview(logoImageView)
        
        setUpButtons()
        test()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    
    func setUpButtons() {
        startButton = UIButton()
        stopButton = UIButton()
        thirdStateButton = UIButton()
        
        startButton.frame = CGRect(x: 6, y: cellHeight - 5 - 31, width: cellWidth - 12, height: 31)
        startButton.backgroundColor = .blue
        
        //add to view
        contentView.addSubview(startButton)

    }
    
    func test() {
        nameLabel.text = "First Macro"
        logoImageView.image = #imageLiteral(resourceName: "lightBulb")
    }
    
    
    
    
    
    
    

}
