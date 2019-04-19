//
//  FavoriteDevicesVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 2/26/18.
//  Copyright © 2018 Teodor Stevic. All rights reserved.
//
import Foundation

#warning("Kada Khalifa prihvati License Agreement na AppStoreConnectu, bundle id treba vratiti na com.e-homeautomation.eHomegreen i tim prebaciti na SmartIoT nalog")

private struct LocalConstants {
    static let titleViewSize: CGSize = CGSize(width: 240, height: 44)
    static let collectionViewWidth: CGFloat = 240
}

class FavoriteDevicesVC: UIViewController {
    
    private var gotRunningTimes: Bool = false
    private var isScrolling:Bool = false
    var deviceInControlMode = false
    
    var devices: [Device] = []
    fileprivate var collectionViewCellSize: CGSize = CGSize(width: 113.5, height: 150)
    private let titleView: NavigationViewFavDevices = NavigationViewFavDevices()
    let deviceCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private var filterParameter: FilterItem = FilterItem.loadFilter(type: .Device) ?? FilterItem.loadEmptyFilter()
    private var filterNameType: FavDeviceFilterType! { get { return FavDeviceFilterType(rawValue: defaults.string(forKey: UserDefaults.FavDevicesLabelType)!) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitleView()
        addDeviceCollectionView()
        
        setupConstraints()
        
        addObservers()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadFavDevices()
        
    }
    
    private func addTitleView() {
        view.addSubview(titleView)
    }
    
    private func addDeviceCollectionView() {
        deviceCollectionView.delegate = self
        deviceCollectionView.dataSource = self
        
        deviceCollectionView.register(DimmerCollectionViewCell.self, forCellWithReuseIdentifier: DimmerCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(CurtainCollectionViewCell.self, forCellWithReuseIdentifier: CurtainCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(ApplianceCollectionViewCell.self, forCellWithReuseIdentifier: ApplianceCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(ClimateCollectionViewCell.self, forCellWithReuseIdentifier: ClimateCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(MultisensorCollectionViewCell.self, forCellWithReuseIdentifier: MultisensorCollectionViewCell.reuseIdentifier)
        deviceCollectionView.register(SaltoAccessCollectionViewCell.self, forCellWithReuseIdentifier: SaltoAccessCollectionViewCell.reuseIdentifier)
                
        view.addSubview(deviceCollectionView)
    }
    
    private func setupConstraints() {
        titleView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(GlobalConstants.statusBarHeight)
            make.trailing.equalToSuperview()
            make.width.equalTo(LocalConstants.titleViewSize.width)
            make.height.equalTo(LocalConstants.titleViewSize.height)
        }
        
        deviceCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleView.snp.bottom)
            make.trailing.equalToSuperview()
            make.width.equalTo(LocalConstants.collectionViewWidth)
            make.bottom.equalToSuperview()
        }
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadFavDevices), name: .favoriteDeviceToggled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDeviceNamesAccordingToFilter), name: .favDeviceFilterTypeChanged, object: nil)
    }
    
    fileprivate func setupViews() {
        view.backgroundColor = .black
        
        revealViewController().rightViewRevealWidth = 240
    }
    
    // MARK: - Logic
    @objc fileprivate func loadFavDevices() {
        if let devices = DatabaseDeviceController.shared.getDevices() {
            self.devices = devices.filter({ (device) -> Bool in device.isFavorite!.boolValue == true })
            updateDeviceNamesAccordingToFilter()
            deviceCollectionView.reloadData()
        }
    }
    
    @objc fileprivate func updateDeviceNamesAccordingToFilter() {
        devices.forEach({ (device) in device.cellTitle = DatabaseDeviceController.shared.returnNameForFavoriteDevice(filterParameter: filterParameter, nameType: filterNameType, device: device) })
        deviceCollectionView.reloadData()
    }
    
    func updateCells() {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell   = deviceCollectionView.cellForItem(at: indexPath)
            let device = devices[indexPath.row]
            let tag    = indexPath.row
            
            if let cell = cell as? DeviceCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? CurtainCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? MultiSensorCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? ClimateCell { cell.setCell(device: device, tag: tag); cell.setNeedsDisplay() }
            else if let cell = cell as? ApplianceCollectionCell { cell.refreshDevice(device); cell.setNeedsDisplay() }
            else if let cell = cell as? SaltoAccessCell { cell.setCell(device: device, tag: tag); cell.setNeedsDisplay() }
        }
    }
    
    func updateDeviceStatus (indexPathRow: Int) {
        let device      = devices[indexPathRow]
        let controlType = device.controlType
        let gateway     = device.gateway
        let channel     = device.channel.intValue
        
        for d in devices { if d.gateway == device.gateway && d.address == device.address { d.stateUpdatedAt = Date() } }
        
        let address = device.moduleAddress
        switch controlType {
        case ControlType.Dimmer,
             ControlType.Relay       : SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
        case ControlType.Climate     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getACStatus(address), gateway: gateway)
        case ControlType.Sensor,
             ControlType.IntelligentSwitch,
             ControlType.Gateway     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getSensorState(address), gateway: gateway)
        case ControlType.Curtain     : SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: gateway)
        case ControlType.SaltoAccess : SendingHandler.sendCommand(byteArray: OutgoingHandler.getSaltoAccessState(address, lockId: channel), gateway: gateway)
        default: break
        }
        
        CoreDataController.sharedInstance.saveChanges()
    }
    
    @objc func refreshVisibleDevicesInScrollView () {
        let indexPaths = deviceCollectionView.indexPathsForVisibleItems
        for indexPath in indexPaths { updateDeviceStatus (indexPathRow: indexPath.row) }
    }
    
    @objc func refreshCollectionView() {
        deviceCollectionView.reloadData()
    }
    
    @objc func refreshDevice(_ sender:AnyObject) {
        if let button = sender as? UIButton {
            let tag         = button.tag
            let controlType = devices[tag].controlType
            let gateway     = devices[tag].gateway
            let address     = devices[tag].moduleAddress
            
            switch controlType {
            case ControlType.Dimmer:
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            case ControlType.Relay:
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getLightRelayStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            case ControlType.Curtain:
                SendingHandler.sendCommand(byteArray: OutgoingHandler.getCurtainStatus(address), gateway: gateway)
                SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(address, channel: 0xFF), gateway: gateway)
            default: break
            }
            
        }
    }
    fileprivate func refreshRunningTimes() {
        if !gotRunningTimes {
            devices.forEach { (device) in
                switch device.controlType {
                case ControlType.Dimmer,
                     ControlType.Relay,
                     ControlType.Curtain:
                    
                    SendingHandler.sendCommand(byteArray: OutgoingHandler.resetRunningTime(device.moduleAddress, channel: 0xFF), gateway: device.gateway)
                default: break
                }
            }
            gotRunningTimes = true
        }
    }
}

// MARK: - CollectionView Data Source
extension FavoriteDevicesVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let device      = devices[indexPath.row]
        let controlType = device.controlType
        let tag         = indexPath.row
        
        switch controlType {
        case ControlType.Dimmer:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DimmerCollectionViewCell.reuseIdentifier, for: indexPath) as? DimmerCollectionViewCell {
                
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Curtain:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CurtainCollectionViewCell.reuseIdentifier, for: indexPath) as? CurtainCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.SaltoAccess:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaltoAccessCollectionViewCell.reuseIdentifier, for: indexPath) as? SaltoAccessCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Relay,
             ControlType.DigitalOutput:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ApplianceCollectionViewCell.reuseIdentifier, for: indexPath) as? ApplianceCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Climate:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClimateCollectionViewCell.reuseIdentifier, for: indexPath) as? ClimateCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
            
        case ControlType.Sensor,
             ControlType.IntelligentSwitch,
             ControlType.Gateway,
             ControlType.DigitalInput:
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultisensorCollectionViewCell.reuseIdentifier, for: indexPath) as? MultisensorCollectionViewCell {
                cell.setCell(with: device, tag: tag)
                return cell
            }
        default:
            break
        }
        
        return UICollectionViewCell()
    }
    
}

// MARK: - Collection View Delegate Flow layout
extension FavoriteDevicesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewCellSize.width, height: collectionViewCellSize.height)
    }
}

// MARK: - Gesture Recognizer Delegate
extension FavoriteDevicesVC: UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view! is UISlider { return false }
        return true
    }
}

extension Notification.Name {
    static let favoriteDeviceToggled = Notification.Name("favoriteDeviceToggled")
}
