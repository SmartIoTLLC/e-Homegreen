//
//  RemoteDetailsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/29/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AudioToolbox

class RemoteDetailsViewController: UIViewController {
    
    var remote: RemoteDummy!
    let cellId = "buttonCell"
    
    var sectionInsets: UIEdgeInsets = UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16)
    var interItemSpacing: CGFloat! = 0
    
    // napraviti tag u celiji i dodeliti mu vrednost indexPath.row/item
    // sectionInsets i velicina celije na osnovu remote.rows
    //
    
    @IBOutlet weak var remoteBackground: UIView!
    @IBOutlet weak var remoteHeader: UIView!
    @IBOutlet weak var remoteFooter: UIView!
    
    @IBOutlet weak var remoteHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var remoteBackgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var remoteTitleLabel: UILabel!
    
    
    @IBOutlet weak var remoteSignal: UIView!
    
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    
    @IBOutlet weak var bg: UIImageView!
    
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBAction func fullScreenButton(_ sender: UIButton) {
        sender.switchFullscreen()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFullscreenImage(fullscreenButton: fullScreenButton)        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonsCollectionView.register(UINib(nibName: String(describing: ButtonCell.self), bundle: nil), forCellWithReuseIdentifier: cellId)
        
        buttonsCollectionView.delegate = self
        buttonsCollectionView.dataSource = self
        
        updateViews()
    }
    
    fileprivate func updateViews() {
        remoteTitleLabel.text = remote.buggerOff
        remoteTitleLabel.font = UIFont.tahoma(size: 15)
        remoteTitleLabel.textColor = .white
        remoteTitleLabel.textAlignment = .center
        
        remoteBackground.backgroundColor = Colors.AndroidGrayColor
        remoteBackground.layer.cornerRadius = 10
        remoteBackground.layer.borderWidth = 2
        remoteBackground.layer.borderColor = Colors.DarkGray
        
        remoteSignal.layer.cornerRadius = remoteSignal.frame.width / 2
        remoteSignal.layer.borderColor = UIColor.black.cgColor
        remoteSignal.layer.borderWidth = 1
        
        roundUp(view: remoteHeader, corners: [.topLeft, .topRight])
        roundUp(view: remoteFooter, corners: [.bottomLeft, .bottomRight])
        
        buttonsCollectionView.backgroundColor = Colors.AndroidGrayColor
        buttonsCollectionView.layer.borderWidth = 2
        buttonsCollectionView.layer.borderColor = Colors.DarkGray
        
        setSectionInsets()
        calculateRemoteHeight(remote: remote)
    }
    
    fileprivate func calculateRemoteHeight(remote: RemoteDummy) {
        var height: CGFloat = 0
        
        let collectionViewHeight = CGFloat(remote.rows!) * (remote.buttonSize?.height)! + CGFloat((remote.rows! - 1) * 5) + remote.buttonMargins.top + remote.buttonMargins.bottom
        height = collectionViewHeight + (2 * 60) + (2 * 8)
        remoteHeightConstraint.constant = collectionViewHeight
        remoteBackgroundHeightConstraint.constant = height
        buttonsCollectionView.layoutIfNeeded()
        remoteBackground.layoutIfNeeded()
    }
    
    fileprivate func setSectionInsets() {
        let availableSpace = buttonsCollectionView.frame.width - (CGFloat(remote.columns) * remote.buttonSize.width)
        interItemSpacing = availableSpace / remote.columns
        sectionInsets = remote.buttonMargins
    }
    
    fileprivate func roundUp(view: UIView, corners: UIRectCorner) {
        let rectShape = CAShapeLayer()

        rectShape.bounds = view.frame
        rectShape.position = view.center
        rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
        rectShape.borderColor = Colors.DarkGray
        rectShape.borderWidth = 2
        view.layer.backgroundColor = Colors.MediumGray
        view.layer.mask = rectShape
    }
    
    fileprivate func signalRedIndicator() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        UIView.animate(withDuration: 0.2, animations: {
            self.remoteSignal.backgroundColor = .red
        }) { (true) in
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: { self.remoteSignal.backgroundColor = .darkGray })
        }
    }
    
}

extension RemoteDetailsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remote.columns * remote.rows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = buttonsCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ButtonCell {
            
            if indexPath.row < 2 { cell.isHidden = true }
            
            cell.remote = remote
            cell.buttonTag = indexPath.item
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
}

extension RemoteDetailsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: send command function
        signalRedIndicator()
    }
}

extension RemoteDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: remote.buttonSize.width, height: remote.buttonSize.height)
    }
}
