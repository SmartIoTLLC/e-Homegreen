//
//  ChooseButtonColorVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/16/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

private struct LocalConstants {
    static let cellHeight: CGFloat = 44
    static let numberOfRemoteColors: Int = 4
    static let numberOfButtonColors: Int = 5
    static let numberOfRemoteShapes: Int = 2
    static let numberOfButtonShapes: Int = 3
    
    static let tableViewSidePadding: CGFloat = 32
}

class ChooseButtonColorOrShapeViewController: CommonXIBTransitionVC {
    
    private var pickedColorShape: String!
    var masterColorShape: String!
    
    var isRemote: Bool!
    var isForColors: Bool!
    
    fileprivate var colorsAndShapes: [String] = []
    
    private var tableViewHeight: CGFloat = 0
    
    private let tableView: UITableView = UITableView()
    private let dismissArea: UIView = UIView()
    
    override func viewDidLoad() {
        
        setupBackground()
        addTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setColorsAndHeight()
        setupConstraints()
    }
    
    // MARK: - View setup
    private func setupBackground() {
        view.backgroundColor = .clear
        
        dismissArea.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dismissArea.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissModal)))
        
        view.addSubview(dismissArea)
    }
    
    private func addTableView() {
        tableView.delegate        = self
        tableView.dataSource      = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = Colors.AndroidGrayColor
        tableView.separatorColor  = .clear
        tableView.register(ButtonShapeColorTableViewCell.self, forCellReuseIdentifier: ButtonShapeColorTableViewCell.reuseIdentifier)
        
        view.addSubview(tableView)
    }        
    
    private func setColorsAndHeight() {
        isForColors ? (colorsAndShapes = [ButtonColor.gray, ButtonColor.red, ButtonColor.green, ButtonColor.blue]) : (colorsAndShapes = [ButtonShape.rectangle, ButtonShape.circle])
        
        switch isRemote! {
            case false:
                colorsAndShapes.insert("Use master", at: 0)
                tableViewHeight = (isForColors ? (LocalConstants.numberOfButtonColors.cgFloat * LocalConstants.cellHeight) : (LocalConstants.numberOfButtonShapes.cgFloat * LocalConstants.cellHeight))
            
            case true: tableViewHeight = (isForColors ? (LocalConstants.numberOfRemoteColors.cgFloat * LocalConstants.cellHeight) : (LocalConstants.numberOfRemoteShapes.cgFloat * LocalConstants.cellHeight))
        }

        tableView.reloadData()
    }
    
    private func setupConstraints() {
        dismissArea.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(LocalConstants.tableViewSidePadding)
            make.trailing.equalToSuperview().inset(LocalConstants.tableViewSidePadding)
            make.centerY.equalToSuperview()
            make.height.equalTo(tableViewHeight)
        }
    }
    
    // MARK: - Logic
    fileprivate func pickValue(at indexPath: IndexPath) {
        pickedColorShape = colorsAndShapes[indexPath.row]
        var notificationName: Notification.Name = .ButtonColorChosen; if !isForColors { notificationName = .ButtonShapeChosen }
        NotificationCenter.default.post(name: notificationName, object: pickedColorShape)
        dismissModal()
    }

}

// MARK: - TableView Data Source & Delegate
extension ChooseButtonColorOrShapeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch isForColors! {
            case true  : return isRemote ? LocalConstants.numberOfRemoteColors : LocalConstants.numberOfButtonColors
            case false : return isRemote ? LocalConstants.numberOfRemoteShapes : LocalConstants.numberOfButtonShapes
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ButtonShapeColorTableViewCell.reuseIdentifier, for: indexPath) as? ButtonShapeColorTableViewCell {
            cell.setCell(with: colorsAndShapes[indexPath.row])
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LocalConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickValue(at: indexPath)
    }
}

extension UIViewController {
    @objc func showChooseButtonColorOrShapeVC(masterValue: String, isRemote: Bool = true, isForColors: Bool = true) {
        let vc = ChooseButtonColorOrShapeViewController()
        vc.isRemote = isRemote
        vc.isForColors = isForColors
        vc.masterColorShape = masterValue
        present(vc, animated: true, completion: nil)
    }
}

// MARK: Colors and Shapes cell
class ButtonShapeColorTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "ButtonShapeColorTableViewCell"
    
    private let titleLabel: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setBackground()
        addTitleLabel()
        
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
     
        setBackground()
        addTitleLabel()
        
        setupConstraints()
    }
    
    private func setBackground() {
        backgroundColor = .clear
        let bg = UIView()
        bg.backgroundColor = .clear
        selectedBackgroundView = bg
    }
    
    private func addTitleLabel() {
        titleLabel.textColor = .white
        titleLabel.font = .tahoma(size: 17)
        
        addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
        }
    }
    
    func setCell(with title: String) {
        titleLabel.text = title
    }
}
