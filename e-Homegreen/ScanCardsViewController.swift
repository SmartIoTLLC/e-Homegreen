//
//  ScanCardsViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 9/12/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class ScanCardsViewController: UIViewController, ProgressBarDelegate {
    
    @IBOutlet weak var devAddressOne: UITextField!
    @IBOutlet weak var devAddressTwo: UITextField!
    @IBOutlet weak var devAddressThree: UITextField!
    @IBOutlet weak var fromTextField: UITextField!
    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var cardsTableView: UITableView!
    
    var gateway:Gateway!
    var cards:[Card] = []
    var appDel: AppDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDel = UIApplication.shared.delegate as! AppDelegate
        
        cardsTableView.tableFooterView = UIView()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        
        devAddressThree.delegate = self
        toTextField.delegate = self
        fromTextField.delegate = self
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.isEnabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.isEnabled = false
        
        reloadCards()

    }
    override func viewWillAppear(_ animated: Bool) {
        addObservers()
    }
    override func viewWillDisappear(_ animated: Bool) {
        removeObservers()
    }

    @IBAction func scanCards(_ sender: AnyObject) {
        findNames()
    }
    @IBAction func clearRangeTextFields(_ sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    func reloadCards(){
        cards = DatabaseCardsController.shared.getCardsByGateway(gateway)
        cardsTableView.reloadData()
    }
    
    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. cardNameReceivedFromPLC)
    var cardNameTimer:Foundation.Timer?
    var cardParameterTimer: Foundation.Timer?
    var timesRepeatedCounterNames:Int = 0
    var timesRepeatedCounterParameters: Int = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    var arrayOfParametersToBeSearched = [Int]()
    var indexOfParametersToBeSearched = 0
    var progressBarScreenTimerNames: ProgressBarVC?
    //    var progressBarScreenTimerParameters: ProgressBarVC?
    var shouldFindCardParameters = false
    var shouldFindTimerNames = false
    var shouldFindTimerParameters = false
    var addressOne = 0x00
    var addressTwo = 0x00
    var addressThree = 0x00
    
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findNames() {
        
            arrayOfNamesToBeSearched = [Int]()
            indexOfNamesToBeSearched = 0
            
            addressOne = Int(devAddressOne.text!)!
            addressTwo = Int(devAddressTwo.text!)!
            
            guard let address3Text = devAddressThree.text else{
                self.view.makeToast(message: "Address can't be empty")
                return
            }
            guard let address3 = Int(address3Text) else{
                self.view.makeToast(message: "Address can be only number")
                return
            }
            addressThree = address3
            
            var from = 1
            var to = 255
            
            if let rangeFromText = fromTextField.text, let rangeFrom = Int(rangeFromText){
                from = rangeFrom
            }

            if let rangeToText = toTextField.text, let rangeTo = Int(rangeToText){
                to = rangeTo
            }
            
            if to < from {
                self.view.makeToast(message: "Range is not properly set")
                return
            }
            for i in from...to{
                arrayOfNamesToBeSearched.append(i)
            }
            shouldFindCardParameters = true
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstTimerIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.present(progressBarScreenTimerNames!, animated: true, completion: nil)
                cardNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: firstTimerIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstTimerIndexThatDontHaveName)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningCardNames)
                sendCommandForFindingNameWithCardAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfCardDidGetName (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            cardNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: timerIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetName \(timerIndex)")
            sendCommandForFindingNameWithCardAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: timerIndex){ // Get the index of received cardId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfTimerIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfTimerIndexInArrayOfNamesToBeSearched+1]
                    timesRepeatedCounterNames = 0
                    cardNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetName \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingNameWithCardAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                }else{
                    dismissScaningControls()
                }
            }else{
                dismissScaningControls()
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func cardNameReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningCardNames) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["cardId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                
                timesRepeatedCounterNames = 0
                cardNameTimer?.invalidate()
                cardNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func cardNameReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingNameWithCardAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithCardAddress(_ cardId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingNames(cardId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCardName(address, cardId: UInt8(cardId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingNames (_ cardId:Int) {
        print("Progresbar for Names: \(cardId)")
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: cardId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            if let _ = progressBarScreenTimerNames?.lblHowMuchOf, let _ = progressBarScreenTimerNames?.lblPercentage, let _ = progressBarScreenTimerNames?.progressView{
                progressBarScreenTimerNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfNamesToBeSearched+1) / \(arrayOfNamesToBeSearched.count)"
                progressBarScreenTimerNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)*100) + " %"
                progressBarScreenTimerNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfNamesToBeSearched+1)/Float(arrayOfNamesToBeSearched.count)
            }
        }
    }
    
    // MARK: - Card parameters
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findParametarsForCard() {
        progressBarScreenTimerNames?.dissmissProgressBar()
        progressBarScreenTimerNames = nil
        
            arrayOfParametersToBeSearched = [Int]()
            indexOfParametersToBeSearched = 0
            
            guard let rangeFromText = fromTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
               self.view.makeToast(message: "Range can be only number")
                return
            }
            let from = rangeFrom
            
            guard let rangeToText = toTextField.text else{
                self.view.makeToast(message: "Range can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                self.view.makeToast(message: "Range can be only number")
                return
            }
            let to = rangeTo
            
            if rangeTo < rangeFrom {
                self.view.makeToast(message: "Range is not properly set")
                return
            }
            
            shouldFindTimerNames = true
            
            for i in from...to{
                for cardTemp in cards {
                    if cardTemp.id.intValue == i{
                        arrayOfParametersToBeSearched.append(i)
                    }
                }
            }
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenTimerNames = nil
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding card parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.present(progressBarScreenTimerNames!, animated: true, completion: nil)
                cardParameterTimer?.invalidate()
                cardParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningCardParameters)
                sendCommandForFindingParameterWithCardAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from FindParameter")
            }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithCardAddress for that specific timer id.
    func checkIfCardDidGetParametar (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let cardIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            cardParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: cardIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetParameter \(cardIndex)")
            sendCommandForFindingParameterWithCardAddress(cardIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            print("Command sent for parameter from CheckIfTimerDidGetParameter (repeat \(timesRepeatedCounterParameters))")
        }else{
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: cardIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfTimerIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfTimerIndexInArrayOfParametersToBeSearched+1]
                    timesRepeatedCounterParameters = 0
                    cardParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetParameter \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingParameterWithCardAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                    print("Command sent for parameter from checkIfTimerDidGetParametar: next parameter")
                }else{
                    shouldFindCardParameters = false
                    dismissScaningControls()
                }
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func cardParametarReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningCardParameters) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let cardIndex = info["cardId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: cardIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                cardParameterTimer?.invalidate()
                cardParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func parameterReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingParameterWithCardAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from timerParameterReceivedFromPLC: next parameter")
            }else{
                shouldFindCardParameters = false
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingParameterWithCardAddress(_ timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getCardParametar(address, cardId: UInt8(timerId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingParameters (_ timerId:Int) {
        if let indexOfDeviceIndexInArrayOfPatametersToBeSearched = arrayOfParametersToBeSearched.index(of: timerId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
            print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
            if let _ = progressBarScreenTimerNames?.lblHowMuchOf {
                if let _ = progressBarScreenTimerNames?.lblPercentage{
                    if let _ = progressBarScreenTimerNames?.progressView{
                        print("Progresbar for Parameters: \(indexOfDeviceIndexInArrayOfPatametersToBeSearched)")
                        progressBarScreenTimerNames?.lblHowMuchOf.text = "\(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1) / \(arrayOfParametersToBeSearched.count)"
                        progressBarScreenTimerNames?.lblPercentage.text = String.localizedStringWithFormat("%.01f", Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)*100) + " %"
                        progressBarScreenTimerNames?.progressView.progress = Float(indexOfDeviceIndexInArrayOfPatametersToBeSearched+1)/Float(arrayOfParametersToBeSearched.count)
                    }
                }
            }
        }
    }
    
    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. cardNameReceivedFromPLC)
    var timerNameTimer:Foundation.Timer?
    var timerParameterTimer: Foundation.Timer?
    var arrayTimerAddresses = [Int]()

    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findTimerNames() {
            arrayOfNamesToBeSearched = [Int]()
            arrayTimerAddresses = [Int]()
            indexOfNamesToBeSearched = 0
            
            addressOne = Int(devAddressOne.text!)!
            addressTwo = Int(devAddressTwo.text!)!
            
            // make array of timers to be searched
            // make array of gateway addresses for timers to be searched
            for i in cards{
                arrayOfNamesToBeSearched.append(i.timerId.intValue)
                arrayTimerAddresses.append(i.timerAddress.intValue)
            }
            shouldFindTimerParameters = true
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstTimerIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding timer names", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.present(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: firstTimerIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstTimerIndexThatDontHaveName)")
                Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningTimerNames)
                sendCommandForFindingNameWithTimerAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
            }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfTimerDidGetName (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: timerIndex) {
                let timerAddress = arrayTimerAddresses[indexOfTimerIndexInArrayOfNamesToBeSearched]
                timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: timerIndex, repeats: false)
                NSLog("func checkIfDeviceDidGetName \(timerIndex)")
                sendCommandForFindingNameWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
            }
        }else{
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfTimerIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                    let timerAddress = arrayTimerAddresses[indexOfNamesToBeSearched]
                    timesRepeatedCounterNames = 0
                    timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetName \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
                }else{
                    shouldFindTimerNames = false
                    dismissScaningControls()
                }
            }else{
                shouldFindTimerNames = false
                dismissScaningControls()
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func timerNameReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerNames) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["timerId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.index(of: timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                timerNameTimer?.invalidate()
                timerNameTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
            }else{
                shouldFindTimerNames = false
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithTimerAddress(_ timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        print("KOMANDA ZA TRAZENJE TIMER IMENA: \((addressOne)) : \((addressTwo)) : \((addressThree)), timerId: \((timerId))")
        setProgressBarParametarsForFindingNames(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getTimerName(address, timerId: UInt8(timerId)) , gateway: self.gateway)
    }
    
    // MARK: - Timer parameters
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findParametarsForTimer() {
        progressBarScreenTimerNames?.dissmissProgressBar()
        progressBarScreenTimerNames = nil

            arrayOfParametersToBeSearched = [Int]()
            arrayTimerAddresses = [Int]()
            indexOfParametersToBeSearched = 0
            
            for i in cards{
                arrayOfParametersToBeSearched.append(i.timerId.intValue)
                arrayTimerAddresses.append(i.timerAddress.intValue)
            }
            
            Foundation.UserDefaults.standard.set(true, forKey: UserDefaults.IsScaningTimerParameters)
            
            UIApplication.shared.isIdleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenTimerNames = nil
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding timer parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.present(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerParameterTimer?.invalidate()
                timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                sendCommandForFindingParameterWithTimerAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
                print("Command sent for parameter from FindParameter")
            }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
    func checkIfTimerDidGetParametar (_ timer:Foundation.Timer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: timerIndex){
                timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: timerIndex, repeats: false)
                let timerAddress = arrayTimerAddresses[indexOfTimerIndexInArrayOfParametersToBeSearched]
                NSLog("func checkIfDeviceDidGetParameter \(timerIndex)")
                sendCommandForFindingParameterWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
                print("Command sent for parameter from CheckIfTimerDidGetParameter (repeat \(timesRepeatedCounterParameters))")
            }
        }else{
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfTimerIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                    let timerAddress = arrayTimerAddresses[indexOfParametersToBeSearched]
                    timesRepeatedCounterParameters = 0
                    timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetParameter \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingParameterWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
                    print("Command sent for parameter from checkIfTimerDidGetParametar: next parameter")
                }else{
                    shouldFindTimerParameters = false
                    dismissScaningControls()
                }
            }
        }
    }
    // If message is received from PLC, notification is sent and notification calls this function.
    // Checks whether there is next timer ID to search for. If there is not, dismiss progres bar and end the search.
    func timerParametarReceivedFromPLC (_ notification:Notification) {
        if Foundation.UserDefaults.standard.bool(forKey: UserDefaults.IsScaningTimerParameters) {
            guard let info = (notification as NSNotification).userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["timerId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.index(of: timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                timerParameterTimer?.invalidate()
                timerParameterTimer = Foundation.Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func parameterReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingParameterWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
                print("Command sent for parameter from timerParameterReceivedFromPLC: next parameter")
            }else{
                shouldFindTimerParameters = false
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingParameterWithTimerAddress(_ timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: OutgoingHandler.getTimerParametar(address, id: UInt8(timerId)) , gateway: self.gateway)
    }
    
    // Helpers
    func progressBarDidPressedExit() {
        shouldFindCardParameters = false
        dismissScaningControls()
    }
    func dismissScaningControls() {
        timesRepeatedCounterNames = 0
        timesRepeatedCounterParameters = 0
        cardNameTimer?.invalidate()
        cardParameterTimer?.invalidate()
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningCardNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningCardParameters)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerParameters)
        progressBarScreenTimerNames!.dissmissProgressBar()
        
        arrayOfNamesToBeSearched = [Int]()
        arrayTimerAddresses = [Int]()
        indexOfNamesToBeSearched = 0
        arrayOfParametersToBeSearched = [Int]()
        indexOfParametersToBeSearched = 0
        reloadCards()
        if !shouldFindCardParameters && !shouldFindTimerNames && !shouldFindTimerParameters{
            UIApplication.shared.isIdleTimerDisabled = false
        }else{
            if shouldFindCardParameters {
                _ = Foundation.Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(ScanCardsViewController.findParametarsForCard), userInfo: nil, repeats: false)
            }
            if shouldFindTimerNames {
                _ = Foundation.Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(ScanCardsViewController.findTimerNames), userInfo: nil, repeats: false)
            }
            if shouldFindTimerParameters{
                _ = Foundation.Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(ScanCardsViewController.findParametarsForTimer), userInfo: nil, repeats: false)
            }
        }
    }
    
    func addObservers(){
        // Notification that tells us that card is received and stored
        NotificationCenter.default.addObserver(self, selector: #selector(ScanCardsViewController.cardNameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveCardFromGateway), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanCardsViewController.cardParametarReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveCardParameterFromGateway), object: nil)
        // Notification that tells us that timer is received and stored
        NotificationCenter.default.addObserver(self, selector: #selector(ScanCardsViewController.timerNameReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveTimerFromGateway), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ScanCardsViewController.timerParametarReceivedFromPLC(_:)), name: NSNotification.Name(rawValue: NotificationKey.DidReceiveTimerParameterFromGateway), object: nil)
    }
    func removeObservers(){
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningCardNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningCardParameters)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerNames)
        Foundation.UserDefaults.standard.set(false, forKey: UserDefaults.IsScaningTimerParameters)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.RefreshDevice), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidFindDeviceName), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidFindDevice), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NotificationKey.DidFindSensorParametar), object: nil)
    }
}

extension ScanCardsViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

extension ScanCardsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CardsCell())) as? CardsCell {
            cell.backgroundColor = UIColor.clear
            
            cell.labelID.text = "\(cards[(indexPath as NSIndexPath).row].id)"
            cell.cardNameLabel.text = cards[(indexPath as NSIndexPath).row].cardName
            cell.cardIdLabel.text = cards[(indexPath as NSIndexPath).row].cardId
            cell.address.text = "\(String(format: "%03d", cards[(indexPath as NSIndexPath).row].gateway.addressOne.intValue)):\(String(format: "%03d", cards[(indexPath as NSIndexPath).row].gateway.addressTwo.intValue)):\(String(format: "%03d", cards[(indexPath as NSIndexPath).row].timerAddress.intValue)):\(cards[(indexPath as NSIndexPath).row].timerId)"
            
            return cell
        }
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "DefaultCell")
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:IndexPath) in
            self.tableView(self.cardsTableView, commit: UITableViewCellEditingStyle.delete, forRowAt: indexPath)
        })
        
        button.backgroundColor = UIColor.red
        return [button]
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            appDel.managedObjectContext?.delete(cards[(indexPath as NSIndexPath).row])
            CoreDataController.shahredInstance.saveChanges()
            reloadCards()
        }
    }
}


