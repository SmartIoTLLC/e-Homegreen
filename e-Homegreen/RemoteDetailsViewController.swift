//
//  RemoteDetailsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/29/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class RemoteDetailsViewController: UIViewController {
    
    var remote: RemoteDummy!
    
    // napraviti tag u celiji i dodeliti mu vrednost indexPath.row/item
    
    @IBOutlet weak var remoteBackground: UIView!
    @IBOutlet weak var remoteHeader: UIView!
    @IBOutlet weak var remoteFooter: UIView!
    
    @IBOutlet weak var remoteTitleLabel: UILabel!
    
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    
    @IBOutlet weak var bg: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
    }
    
    func updateViews() {
        remoteTitleLabel.text = remote.buggerOff
        remoteTitleLabel.font = UIFont(name: "Tahoma", size: 17)
        remoteTitleLabel.textColor = .white
        remoteTitleLabel.textAlignment = .center
        
        remoteBackground.backgroundColor = Colors.AndroidGrayColor
        remoteBackground.layer.cornerRadius = 10
        remoteBackground.layer.borderWidth = 2
        remoteBackground.layer.borderColor = Colors.DarkGray
        
        roundUp(view: remoteHeader, corners: [.topLeft, .topRight])
        roundUp(view: remoteFooter, corners: [.bottomLeft, .bottomRight])
        
        buttonsCollectionView.backgroundColor = Colors.AndroidGrayColor
        buttonsCollectionView.layer.borderWidth = 2
        buttonsCollectionView.layer.borderColor = Colors.DarkGray
    }
    
    func roundUp(view: UIView, corners: UIRectCorner) {
        let rectShape = CAShapeLayer()

        rectShape.bounds = view.frame
        rectShape.position = view.center
        rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
        rectShape.borderColor = Colors.DarkGray
        rectShape.borderWidth = 2
        view.layer.backgroundColor = Colors.MediumGray
        view.layer.mask = rectShape
    }

    
}
