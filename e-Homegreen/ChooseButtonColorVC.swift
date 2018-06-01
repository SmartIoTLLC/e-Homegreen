//
//  ChooseButtonColorVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/16/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class ChooseButtonColorVC: CommonXIBTransitionVC {
    
    var pickedColorShape: String!
    var masterColorShape: String!
    
    var isRemote: Bool!
    var isForColors: Bool!
    
    @IBOutlet weak var tableView: UITableView!
    
    var colorsAndShapes: [String] = [] {
        didSet { tableView.reloadData() }
    }
    
    @IBOutlet weak var backgroundHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dismissArea: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    override func viewDidLoad() {
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setColorsAndHeight()
    }
    
}

// MARK: - TableView Data Source
extension ChooseButtonColorVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch isForColors {
            case true : return isRemote ? 4 : 5
            default   : return isRemote ? 2 : 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

// MARK: - TableView Delegate
extension ChooseButtonColorVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickValue(at: indexPath)
    }
    
}

// MARK: - View setup
extension ChooseButtonColorVC {
    fileprivate func updateViews() {
        view.backgroundColor = .clear
        backgroundView.backgroundColor = Colors.AndroidGrayColor
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .clear
        tableView.separatorColor  = .clear
        dismissArea.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissModal)))
    }
    
    fileprivate func setColorsAndHeight() {
        isForColors ? (colorsAndShapes = [ButtonColor.gray, ButtonColor.red, ButtonColor.green, ButtonColor.blue]) : (colorsAndShapes = [ButtonShape.rectangle, ButtonShape.circle])
        
        switch isRemote {
            case false:
                colorsAndShapes.insert("Use master", at: 0)
                backgroundHeightConstraint.constant = (isForColors ? 220 : 132)
            
            default: backgroundHeightConstraint.constant = (isForColors ? 176 : 88)
        }
        
        backgroundView.layoutIfNeeded()
        tableView.layoutIfNeeded()
    }
    
    fileprivate func getCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = colorsAndShapes[indexPath.row]
        cell.textLabel?.textAlignment = .left
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .tahoma(size: 17)
        cell.backgroundColor = .clear
        let bg = UIView()
        bg.backgroundColor = .clear
        cell.selectedBackgroundView = bg
        
        return cell
    }
}

// MARK: - Logic
extension ChooseButtonColorVC {
    fileprivate func pickValue(at indexPath: IndexPath) {
        pickedColorShape = colorsAndShapes[indexPath.row]
        var notificationName: Notification.Name = .ButtonColorChosen; if !isForColors { notificationName = .ButtonShapeChosen }
        NotificationCenter.default.post(name: notificationName, object: pickedColorShape)
        dismissModal()
    }
    
}

extension UIViewController {
    @objc func showChooseButtonColorOrShapeVC(masterValue: String, isRemote: Bool = true, isForColors: Bool = true) {
        let vc = ChooseButtonColorVC()
        vc.isRemote = isRemote
        vc.isForColors = isForColors
        vc.masterColorShape = masterValue
        present(vc, animated: true, completion: nil)
    }
}
