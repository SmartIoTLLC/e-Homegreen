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
    
    var colorsAndShapes: [String] = []
    
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
            case true : if isRemote { return 4 } else { return 5 }
            default   : if isRemote { return 2 } else { return 3 }
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
        switch isForColors {
            case true  : colorsAndShapes = [ButtonColor.gray, ButtonColor.red, ButtonColor.green, ButtonColor.blue]
            default    : colorsAndShapes = [ButtonShape.rectangle, ButtonShape.circle]
        }
        
        switch isRemote {
            case false:
                colorsAndShapes.insert("Use master", at: 0)
                if isForColors { backgroundHeightConstraint.constant = 220 } else { backgroundHeightConstraint.constant = 132 }
            
            default: if isForColors { backgroundHeightConstraint.constant = 176 } else { backgroundHeightConstraint.constant = 88 }
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

