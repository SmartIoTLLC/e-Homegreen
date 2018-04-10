//
//  MacrosViewController.swift
//  e-Homegreen
//
//  Created by Bratislav Baljak on 3/20/18.
//  Copyright © 2018 NS Web Development. All rights reserved.
//

import UIKit

class MacrosViewController: PopoverVC {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addNewButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var macroList = [Macro]()
    var filterScrollView = FilterPullDown()

    let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    let cellId = "MacrosCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let macroList = DatabaseMacrosController.sharedInstance.fetchAllMacrosFromCD() {
            self.macroList = macroList
        }
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        revealViewController().delegate = self
        setupSWRevealViewController(menuButton: menuButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setScrollViewBottomOffset(scrollView: &filterScrollView)
    }
    
    override func viewWillLayoutSubviews() {
        setContentOffset(for: filterScrollView)
    }
    
    override func nameAndId(_ name: String, id: String) {
        filterScrollView.setButtonTitle(name, id: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addNewMacroVC = segue.destination as? AddNewMacroViewController {
            addNewMacroVC.macroDelegate = self as SuccessfullyAddedMacroDelegate
        }
    }
    
    func reloadCollectionView() {
        if let macroList = DatabaseMacrosController.sharedInstance.fetchAllMacrosFromCD() {
            self.macroList = macroList
            collectionView.reloadData()
        }
    }
    
    @IBAction func addNewButton_Action(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addNewMacroPopUp", sender: nil)
    }
    
    func startMacro(_ gestureRecognizer:UITapGestureRecognizer) {
        let tag = gestureRecognizer.view!.tag
        let macro = macroList[tag]
        let macroActions = DatabaseMacrosController.sharedInstance.fetchMacroActionsFor(macro: macro)
        
        if macroActions.count != 0 {
            for oneAction in macroActions {
                let gateway = CoreDataController.sharedInstance.fetchGatewayWithId(oneAction.gatewayId!)
                let device = CoreDataController.sharedInstance.fetchDeviceByGatewayAndAddressAndChannel(gateway!, address: oneAction.deviceAddress!, channel: oneAction.deviceChannel!)
                //send command
                sendingHandler(device: device!, oneAction: oneAction, gateway: gateway!)
               
            
                //send command
            }
        }
        
    }
    
    func stopMacro(_ gestureRecognizer:UITapGestureRecognizer) {
        print(gestureRecognizer.view!.tag)
    }
    
    private func sendingHandler(device: Device, oneAction: Macro_action, gateway: Gateway) {
        let controlType = device.controlType
        let address = [getByte(device.gateway.addressOne), getByte(device.gateway.addressTwo), getByte(device.address)]
        var setDeviceValue: UInt8 = 0
        let deviceCurrentValue = device.currentValue
        var skipLevel: UInt8 = 0
        
        //oneAction.command == 0 - off, 1 - on, 2 - toggle
        
        if Int(deviceCurrentValue) > 0 {
            setDeviceValue = UInt8(0)
            skipLevel = 0
        } else {
            setDeviceValue = UInt8(255)
            skipLevel = getByte(device.skipState)
        }
        device.currentValue = NSNumber(value: Int(setDeviceValue))
        print("old value \(deviceCurrentValue), new value \(setDeviceValue)")
        RunnableList.sharedInstance.checkForSameDevice(
            device: (device.objectID),
            newCommand: NSNumber(value: setDeviceValue),
            oldValue: (deviceCurrentValue)
        )
        
        switch controlType {
        case ControlType.Dimmer:
           print("Dimmer")
        case ControlType.Relay:
            _ = RepeatSendingHandler(byteArray: OutgoingHandler.setLightRelayStatus(address, channel: self.getByte(device.channel), value: setDeviceValue, delay: Int(device.delay), runningTime: Int(device.runtime), skipLevel: skipLevel),
                gateway: device.gateway,
                device: device,
                oldValue: Int(deviceCurrentValue),
                command: NSNumber(value: setDeviceValue)
            )
        case ControlType.Climate:
            print("Climate")
        case ControlType.Curtain:
            print("Curtain")
        case ControlType.SaltoAccess:
            print("SaltoAccess")
        default:
            print("did not found device control type")
        }
        
    }
    

}
extension MacrosViewController {
    
    fileprivate func updateViews() {
        if #available(iOS 11, *) { titleView.layoutIfNeeded() }
        //Background image
        backgroundImage.image = #imageLiteral(resourceName: "Background")
        
        //Collection View
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MacrosCell.self, forCellWithReuseIdentifier: cellId)
        
        //Scroll  VIew
        filterScrollView.delegate = self
        view.addSubview(filterScrollView)
        updateConstraints(item: filterScrollView)
        filterScrollView.setItem(self.view)
        
        //Navigation controller
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: UIBarMetrics.default)
        titleView.setTitle("Macros")
        navigationItem.titleView = titleView
    }
}
extension MacrosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? MacrosCell {
        
            cell.cellHeight = 150
            cell.cellWidth = 180
            cell.layer.borderColor = UIColor.lightGray.cgColor
            cell.layer.borderWidth = 0.5
            cell.layer.cornerRadius = 12
            cell.setCell(tag: indexPath.row)
            cell.startButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startMacro(_:))))
            cell.stopButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stopMacro(_:))))
            
//            gradient.frame = cell.bounds
//            gradient.colors = [Colors.DirtyBlueColor, UIColor.blue.cgColor]
//            gradient.cornerRadius = 12
//            cell.layer.insertSublayer(gradient, at: 0)
            //cell.layer.backgroundColor = UIColor.blue.withAlphaComponent(0.400000005960464).cgColor
            //cell.backgroundView = UIImageView(image: #imageLiteral(resourceName: "background_macro"))

            if macroList.count != 0 {
                cell.nameLabel.text = macroList[indexPath.row].name
                cell.logoImageView.image = UIImage(named: macroList[indexPath.row].negative_image!)
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (macroList.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        <#code#>
//    }
}
extension MacrosViewController: SWRevealViewControllerDelegate {
    func revealController(_ revealController: SWRevealViewController!,  willMoveTo position: FrontViewPosition){
        if position == .left { collectionView.isUserInteractionEnabled = true } else { collectionView.isUserInteractionEnabled = false }
    }
    
    func revealController(_ revealController: SWRevealViewController!,  didMoveTo position: FrontViewPosition){
        if position == .left { collectionView.isUserInteractionEnabled = true } else { collectionView.isUserInteractionEnabled = false }
    }
}
extension MacrosViewController: SuccessfullyAddedMacroDelegate {
    func refreshMacroVC() {
        reloadCollectionView()
    }
}
extension MacrosViewController: FilterPullDownDelegate {
    
    func filterParametars(_ filterItem: FilterItem) {
        //DatabaseFilterController.shared.saveFilter(filterItem, menu: Menu.macros) // Saves filter to database for later
    
    }
    
    func saveDefaultFilter() {
        self.view.makeToast(message: "Default filter parametar saved!")
    }
}


























