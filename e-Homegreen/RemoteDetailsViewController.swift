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
    
    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    var rows        : Int!
    var columns     : Int!
    var buttonHeight: CGFloat!
    var marginTop   : CGFloat!
    var marginBottom: CGFloat!
    var buttonWidth : CGFloat!
    
    var sectionInsets = UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8)
    var sectionInsetsDict: [Int: UIEdgeInsets] = [:]

    var chunksOfButtons: [[RemoteButton]] = []
    let cellId = "buttonCell"
    
    var headerBorder: CAShapeLayer!
    var footerBorder: CAShapeLayer!
    
    var remote: Remote! {
        didSet {
            rows          = Int(remote.rows!)
            columns       = Int(remote.columns!)
            buttonHeight  = CGFloat(remote.buttonHeight!)
            buttonWidth   = CGFloat(remote.buttonWidth!)
            marginTop     = CGFloat(remote.marginTop!)
            marginBottom  = CGFloat(remote.marginBottom!)
            sectionInsets = UIEdgeInsets(top: marginTop, left: 8, bottom: 0, right: 8)
        }
    }
    
    @IBOutlet weak var remoteScrollView: UIScrollView!    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addObservers()
        setupViews()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loadButtons()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeFullscreenImage(fullscreenButton: fullScreenButton)
        layoutHeaderAndFooter()
    }
    
}

// MARK: - View setup & Logic
extension RemoteDetailsViewController {
    
    fileprivate func setupViews() {
        buttonsCollectionView.register(UINib(nibName: String(describing: ButtonCell.self), bundle: nil), forCellWithReuseIdentifier: cellId)
        buttonsCollectionView.delegate   = self
        buttonsCollectionView.dataSource = self
        
        navigationItem.backBarButtonItem?.setBackgroundImage(#imageLiteral(resourceName: "back"), for: .normal, barMetrics: .default)
    }
    
    fileprivate func updateViews() {
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        titleView.setTitle("")
        navigationItem.titleView       = titleView
        
        remoteTitleLabel.text          = remote.name
        remoteTitleLabel.font          = .tahoma(size: 15)
        remoteTitleLabel.textColor     = .white
        remoteTitleLabel.textAlignment = .center
        
        remoteBackground.backgroundColor    = Colors.AndroidGrayColor
        remoteBackground.layer.cornerRadius = 10
        remoteBackground.layer.borderWidth  = 2
        remoteBackground.layer.borderColor  = Colors.DarkGray
        
        remoteSignal.layer.cornerRadius = remoteSignal.frame.width / 2
        remoteSignal.layer.borderColor  = Colors.AndroidGrayColor.cgColor
        remoteSignal.layer.borderWidth  = 2
        
        remoteHeader.setGradient(isUp: true)
        roundUp(view: remoteHeader, isHeader: true)
        remoteFooter.setGradient(isUp: false)
        roundUp(view: remoteFooter, isHeader: false)
        
        buttonsCollectionView.isScrollEnabled   = false
        buttonsCollectionView.backgroundColor   = Colors.AndroidGrayColor
        buttonsCollectionView.layer.borderWidth = 2
        buttonsCollectionView.layer.borderColor = Colors.DarkGray
        
        calculateRemoteHeight(remote: remote)
    }
    
    fileprivate func calculateRemoteHeight(remote: Remote) {
        
        let biggestButtons       = getBiggestButtons()
        
        var height: CGFloat      = 0
        var collectionViewHeight = CGFloat(remote.marginTop!) + CGFloat(remote.marginBottom!)
        for button in biggestButtons { collectionViewHeight += (CGFloat(button.buttonHeight!) + CGFloat(button.marginTop!)) + 4 }
        height = collectionViewHeight + (2 * 60) + (2 * 8)
        
        remoteHeightConstraint.constant           = buttonsCollectionView.collectionViewLayout.collectionViewContentSize.height
        remoteBackgroundHeightConstraint.constant = height
        findMargins()
        buttonsCollectionView.layoutIfNeeded()
        remoteBackground.layoutIfNeeded()
        remoteScrollView.contentSize.height       = height
    }
    
    fileprivate func loadButtons() {
        if let btns = remote.buttons {
            var buttons: [RemoteButton] = []
            
            for button in btns { buttons.append(button as! RemoteButton) }
            buttons            = buttons.sorted(by: { Int($0.buttonId!) < Int($1.buttonId!) } )
            chunksOfButtons    = buttons.chunks(Int(remote.columns!))
            buttonsCollectionView.reloadData()
        }
    }
    
    fileprivate func getBiggestButtons() -> [RemoteButton] {
        var biggestButtons: [RemoteButton] = []
        
        for group in chunksOfButtons {
            var biggestButton = group[0]
            group.forEach({ (button) in
                if Int(button.buttonHeight!) > Int(biggestButton.buttonHeight!) || (Int(button.buttonHeight!) == Int(biggestButton.buttonHeight!) && Int(button.marginTop!) > Int(biggestButton.marginTop!)) {
                    biggestButton = button
                }
            })
            biggestButtons.append(biggestButton)
        }
        return biggestButtons
    }
    
    fileprivate func findMargins() {
        sectionInsetsDict = [:]
        let biggestButtons = getBiggestButtons()
        for i in 0..<biggestButtons.count {
            var si = sectionInsets
            si.top = CGFloat(biggestButtons[i].marginTop!)
            if i == 0 { si.top += marginTop }
            if i == chunksOfButtons.count - 1 { si.bottom = marginBottom }
            sectionInsetsDict[i] = si
        }
        // TODO: situacija kada je dugme manje ali ima marginu koja je veca od razlike u visini sa najvecim dugmetom + njegovom marginom
        buttonsCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    fileprivate func roundUp(view: UIView, isHeader: Bool) {
        var corners: UIRectCorner = []
        if isHeader { corners = [.topLeft, .topRight] } else { corners = [.bottomLeft, .bottomRight] }
        
        let rectShape = CAShapeLayer()
        rectShape.bounds           = view.frame
        rectShape.position         = view.center
        rectShape.path             = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
        view.layer.backgroundColor = Colors.MediumGray
        view.layer.mask            = rectShape
        
        let borderLayer = CAShapeLayer()
        borderLayer.path        = rectShape.path
        borderLayer.fillColor   = UIColor.clear.cgColor
        borderLayer.strokeColor = Colors.DarkGray
        borderLayer.lineWidth   = 2
        borderLayer.bounds      = rectShape.frame
        borderLayer.position    = view.center
        
        if isHeader {
            if headerBorder != nil { headerBorder.removeFromSuperlayer() }
            headerBorder = borderLayer
            view.layer.addSublayer(headerBorder)
        } else {
            if footerBorder != nil { footerBorder.removeFromSuperlayer() }
            footerBorder = borderLayer
            view.layer.addSublayer(footerBorder)
        }
    }
    
    fileprivate func layoutHeaderAndFooter() {
        remoteHeader.layoutIfNeeded()
        remoteFooter.layoutIfNeeded()
    }
    
    @objc fileprivate func refreshRemote() {
        loadButtons()
        calculateRemoteHeight(remote: remote)
        buttonsCollectionView.reloadData()
    }
 
    @objc fileprivate func signalRedIndicator() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        UIView.animate(withDuration: 0.2, animations: {
            self.remoteSignal.backgroundColor = .red
        }) { (true) in
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: { self.remoteSignal.backgroundColor = .darkGray })
        }
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(signalRedIndicator), name: Notification.Name(rawValue: NotificationKey.SendRemoteCommand), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRemote), name: .ButtonUpdated, object: nil)
    }
    
}

extension UIView {
    fileprivate func setGradient(isUp: Bool) {
        let gradientLayer = CAGradientLayer.gradientLayerForBounds(bounds, isReversed: isUp)
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
