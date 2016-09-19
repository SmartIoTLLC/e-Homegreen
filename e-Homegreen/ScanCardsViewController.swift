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
        
        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        
        cardsTableView.tableFooterView = UIView()
        
        devAddressThree.inputAccessoryView = CustomToolBar()
        toTextField.inputAccessoryView = CustomToolBar()
        fromTextField.inputAccessoryView = CustomToolBar()
        
        devAddressThree.delegate = self
        toTextField.delegate = self
        fromTextField.delegate = self
        
        devAddressOne.text = "\(returnThreeCharactersForByte(Int(gateway.addressOne)))"
        devAddressOne.enabled = false
        devAddressTwo.text = "\(returnThreeCharactersForByte(Int(gateway.addressTwo)))"
        devAddressTwo.enabled = false
        
        reloadCards()

    }
    override func viewWillAppear(animated: Bool) {
        addObservers()
    }
    override func viewWillDisappear(animated: Bool) {
        removeObservers()
    }

    @IBAction func scanCards(sender: AnyObject) {
        findNames()
    }
    @IBAction func clearRangeTextFields(sender: AnyObject) {
        fromTextField.text = ""
        toTextField.text = ""
    }
    
    func reloadCards(){
        cards = DatabaseCardsController.shared.getCardsByGateway(gateway)
        cardsTableView.reloadData()
    }
    
    
    // MARK: - FINDING NAMES FOR DEVICE
    // Info: Add observer for received info from PLC (e.g. cardNameReceivedFromPLC)
    var cardNameTimer:NSTimer?
    var cardParameterTimer: NSTimer?
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
        do {
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
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstTimerIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding name", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.presentViewController(progressBarScreenTimerNames!, animated: true, completion: nil)
                cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: firstTimerIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstTimerIndexThatDontHaveName)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningCardNames)
                sendCommandForFindingNameWithCardAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfCardDidGetName (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: timerIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetName \(timerIndex)")
            sendCommandForFindingNameWithCardAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex){ // Get the index of received cardId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfTimerIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfTimerIndexInArrayOfNamesToBeSearched+1]
                    timesRepeatedCounterNames = 0
                    cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func cardNameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningCardNames) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["cardId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfDeviceIndexInArrayOfNamesToBeSearched+1]
                
                timesRepeatedCounterNames = 0
                cardNameTimer?.invalidate()
                cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func cardNameReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingNameWithCardAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithCardAddress(cardId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingNames(cardId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getCardName(address, cardId: UInt8(cardId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingNames (cardId:Int) {
        print("Progresbar for Names: \(cardId)")
        if let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(cardId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
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
        do {
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
                    if cardTemp.id.integerValue == i{
                        arrayOfParametersToBeSearched.append(i)
                    }
                }
            }
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenTimerNames = nil
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding card parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.presentViewController(progressBarScreenTimerNames!, animated: true, completion: nil)
                cardParameterTimer?.invalidate()
                cardParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningCardParameters)
                sendCommandForFindingParameterWithCardAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from FindParameter")
            }
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithCardAddress for that specific timer id.
    func checkIfCardDidGetParametar (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let cardIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            cardParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: cardIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetParameter \(cardIndex)")
            sendCommandForFindingParameterWithCardAddress(cardIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            print("Command sent for parameter from CheckIfTimerDidGetParameter (repeat \(timesRepeatedCounterParameters))")
        }else{
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(cardIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfTimerIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfTimerIndexInArrayOfParametersToBeSearched+1]
                    timesRepeatedCounterParameters = 0
                    cardParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func cardParametarReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningCardParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let cardIndex = info["cardId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(cardIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                cardParameterTimer?.invalidate()
                cardParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func sendCommandForFindingParameterWithCardAddress(timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getCardParametar(address, cardId: UInt8(timerId)) , gateway: self.gateway)
    }
    func setProgressBarParametarsForFindingParameters (timerId:Int) {
        if let indexOfDeviceIndexInArrayOfPatametersToBeSearched = arrayOfParametersToBeSearched.indexOf(timerId){ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
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
    var timerNameTimer:NSTimer?
    var timerParameterTimer: NSTimer?
    var arrayTimerAddresses = [Int]()

    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findTimerNames() {
        do {
            arrayOfNamesToBeSearched = [Int]()
            arrayTimerAddresses = [Int]()
            indexOfNamesToBeSearched = 0
            
            addressOne = Int(devAddressOne.text!)!
            addressTwo = Int(devAddressTwo.text!)!
            
            // make array of timers to be searched
            // make array of gateway addresses for timers to be searched
            for i in cards{
                arrayOfNamesToBeSearched.append(i.timerId.integerValue)
                arrayTimerAddresses.append(i.timerAddress.integerValue)
            }
            shouldFindTimerParameters = true
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfNamesToBeSearched.count != 0{
                let firstTimerIndexThatDontHaveName = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding timer names", percentage: Float(1)/Float(arrayOfNamesToBeSearched.count), howMuchOf: "1 / \(arrayOfNamesToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.presentViewController(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: firstTimerIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstTimerIndexThatDontHaveName)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningTimerNames)
                sendCommandForFindingNameWithTimerAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
            }
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    // Called from findNames or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingNames for that specific timer id.
    func checkIfTimerDidGetName (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterNames += 1
        if timesRepeatedCounterNames < 3 {
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex) {
                let timerAddress = arrayTimerAddresses[indexOfTimerIndexInArrayOfNamesToBeSearched]
                timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: timerIndex, repeats: false)
                NSLog("func checkIfDeviceDidGetName \(timerIndex)")
                sendCommandForFindingNameWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
            }
        }else{
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfTimerIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                    let timerAddress = arrayTimerAddresses[indexOfNamesToBeSearched]
                    timesRepeatedCounterNames = 0
                    timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func timerNameReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningTimerNames) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["timerId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                indexOfNamesToBeSearched = indexOfDeviceIndexInArrayOfNamesToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfNamesToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfNamesToBeSearched]
                timesRepeatedCounterNames = 0
                timerNameTimer?.invalidate()
                timerNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
            }else{
                shouldFindTimerNames = false
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithTimerAddress(timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        print("KOMANDA ZA TRAZENJE TIMER IMENA: \((addressOne)) : \((addressTwo)) : \((addressThree)), timerId: \((timerId))")
        setProgressBarParametarsForFindingNames(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getTimerName(address, timerId: UInt8(timerId)) , gateway: self.gateway)
    }
    
    // MARK: - Timer parameters
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findParametarsForTimer() {
        progressBarScreenTimerNames?.dissmissProgressBar()
        progressBarScreenTimerNames = nil
        do {
            arrayOfParametersToBeSearched = [Int]()
            arrayTimerAddresses = [Int]()
            indexOfParametersToBeSearched = 0
            
            for i in cards{
                arrayOfParametersToBeSearched.append(i.timerId.integerValue)
                arrayTimerAddresses.append(i.timerAddress.integerValue)
            }
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningTimerParameters)
            
            UIApplication.sharedApplication().idleTimerDisabled = true
            if arrayOfParametersToBeSearched.count != 0{
                let parameterIndex = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                progressBarScreenTimerNames = nil
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding timer parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.presentViewController(progressBarScreenTimerNames!, animated: true, completion: nil)
                timerParameterTimer?.invalidate()
                timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                sendCommandForFindingParameterWithTimerAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
                print("Command sent for parameter from FindParameter")
            }
        } catch let error as InputError {
            self.view.makeToast(message: error.description)
        } catch {
            self.view.makeToast(message: "Something went wrong.")
        }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
    func checkIfTimerDidGetParametar (timer:NSTimer) {
        // If entered in this function that means that we still havent received good response from PLC because in that case timer would be invalidated.
        // Here we just need to see whether we repeated the call to PLC less than 3 times.
        // If not tree times, send same command again
        // If three times reached, search for next timer ID if it exists
        guard let timerIndex = timer.userInfo as? Int else{
            return
        }
        timesRepeatedCounterParameters += 1
        if timesRepeatedCounterParameters < 3 {
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(timerIndex){
                timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: timerIndex, repeats: false)
                let timerAddress = arrayTimerAddresses[indexOfTimerIndexInArrayOfParametersToBeSearched]
                NSLog("func checkIfDeviceDidGetParameter \(timerIndex)")
                sendCommandForFindingParameterWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: timerAddress)
                print("Command sent for parameter from CheckIfTimerDidGetParameter (repeat \(timesRepeatedCounterParameters))")
            }
        }else{
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(timerIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfTimerIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                    let timerAddress = arrayTimerAddresses[indexOfParametersToBeSearched]
                    timesRepeatedCounterParameters = 0
                    timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func timerParametarReceivedFromPLC (notification:NSNotification) {
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaults.IsScaningTimerParameters) {
            guard let info = notification.userInfo! as? [String:Int] else{
                return
            }
            guard let timerIndex = info["timerId"] else{
                return
            }
            guard let indexOfDeviceIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(timerIndex) else{ // Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                return
            }
            
            if indexOfDeviceIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                indexOfParametersToBeSearched = indexOfDeviceIndexInArrayOfParametersToBeSearched+1
                let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfParametersToBeSearched]
                let timerAddress = arrayTimerAddresses[indexOfParametersToBeSearched]
                timesRepeatedCounterParameters = 0
                timerParameterTimer?.invalidate()
                timerParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanTimerViewController.checkIfTimerDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
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
    func sendCommandForFindingParameterWithTimerAddress(timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
        setProgressBarParametarsForFindingParameters(timerId)
        let address = [UInt8(addressOne), UInt8(addressTwo), UInt8(addressThree)]
        SendingHandler.sendCommand(byteArray: Function.getTimerParametar(address, id: UInt8(timerId)) , gateway: self.gateway)
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
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningCardNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningCardParameters)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerParameters)
        progressBarScreenTimerNames!.dissmissProgressBar()
        
        arrayOfNamesToBeSearched = [Int]()
        arrayTimerAddresses = [Int]()
        indexOfNamesToBeSearched = 0
        arrayOfParametersToBeSearched = [Int]()
        indexOfParametersToBeSearched = 0
        reloadCards()
        if !shouldFindCardParameters && !shouldFindTimerNames && !shouldFindTimerParameters{
            UIApplication.sharedApplication().idleTimerDisabled = false
        }else{
            if shouldFindCardParameters {
                _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ScanCardsViewController.findParametarsForCard), userInfo: nil, repeats: false)
            }
            if shouldFindTimerNames {
                _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ScanCardsViewController.findTimerNames), userInfo: nil, repeats: false)
            }
            if shouldFindTimerParameters{
                _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ScanCardsViewController.findParametarsForTimer), userInfo: nil, repeats: false)
            }
        }
    }
    
    func addObservers(){
        // Notification that tells us that card is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanCardsViewController.cardNameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveCardFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanCardsViewController.cardParametarReceivedFromPLC(_:)), name: NotificationKey.DidReceiveCardParameterFromGateway, object: nil)
        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanCardsViewController.timerNameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveTimerFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanCardsViewController.timerParametarReceivedFromPLC(_:)), name: NotificationKey.DidReceiveTimerParameterFromGateway, object: nil)
    }
    func removeObservers(){
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningCardNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningCardParameters)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerNames)
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: UserDefaults.IsScaningTimerParameters)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.RefreshDevice, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidFindDeviceName, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidFindDevice, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NotificationKey.DidFindSensorParametar, object: nil)
    }
}

extension ScanCardsViewController: UITextFieldDelegate{
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        let maxLength = 3
        let currentString: NSString = textField.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }
}

extension ScanCardsViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(String(CardCell)) as? CardCell {
            cell.backgroundColor = UIColor.clearColor()
            
            cell.labelID.text = "\(cards[indexPath.row].id)"
            cell.cardNameLabel.text = cards[indexPath.row].cardName
            cell.cardIdLabel.text = cards[indexPath.row].cardId
            cell.address.text = "\(String(format: "%03d", cards[indexPath.row].gateway.addressOne.integerValue)):\(String(format: "%03d", cards[indexPath.row].gateway.addressTwo.integerValue)):\(String(format: "%03d", cards[indexPath.row].timerAddress.integerValue)):\(cards[indexPath.row].timerId)"
            
            return cell
        }
        
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "DefaultCell")
        return cell
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button:UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) in
            self.tableView(self.cardsTableView, commitEditingStyle: UITableViewCellEditingStyle.Delete, forRowAtIndexPath: indexPath)
        })
        
        button.backgroundColor = UIColor.redColor()
        return [button]
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            appDel.managedObjectContext?.deleteObject(cards[indexPath.row])
            CoreDataController.shahredInstance.saveChanges()
            reloadCards()
        }
    }
}

class CardCell:UITableViewCell{
    @IBOutlet weak var labelID: UILabel!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardIdLabel: UILabel!
    @IBOutlet weak var address: UILabel!
}
