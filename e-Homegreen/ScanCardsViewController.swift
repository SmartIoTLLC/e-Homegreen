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

        // Notification that tells us that timer is received and stored
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanCardsViewController.nameReceivedFromPLC(_:)), name: NotificationKey.DidReceiveCardFromGateway, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ScanCardsViewController.cardParametarReceivedFromPLC(_:)), name: NotificationKey.DidReceiveCardParameterFromGateway, object: nil)
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
    // Info: Add observer for received info from PLC (e.g. nameReceivedFromPLC)
    var cardNameTimer:NSTimer?
    var cardParameterTimer: NSTimer?
    var timesRepeatedCounterNames:Int = 0
    var timesRepeatedCounterParameters: Int = 0
    var arrayOfNamesToBeSearched = [Int]()
    var indexOfNamesToBeSearched = 0
    var arrayOfParametersToBeSearched = [Int]()
    var indexOfParametersToBeSearched = 0
    var alertController:UIAlertController?
    var progressBarScreenTimerNames: ProgressBarVC?
    //    var progressBarScreenTimerParameters: ProgressBarVC?
    var shouldFindCardParameters = false
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
                alertController("Error", message: "Address can't be empty")
                return
            }
            guard let address3 = Int(address3Text) else{
                alertController("Error", message: "Address can be only number")
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
                alertController("Error", message: "Range \"from\" can't be higher than range \"to\"")
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
                cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfTimerDidGetName(_:)), userInfo: firstTimerIndexThatDontHaveName, repeats: false)
                NSLog("func findNames \(firstTimerIndexThatDontHaveName)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningCardNames)
                sendCommandForFindingNameWithTimerAddress(firstTimerIndexThatDontHaveName, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
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
            cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfTimerDidGetName(_:)), userInfo: timerIndex, repeats: false)
            NSLog("func checkIfDeviceDidGetName \(timerIndex)")
            sendCommandForFindingNameWithTimerAddress(timerIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
        }else{
            if let indexOfTimerIndexInArrayOfNamesToBeSearched = arrayOfNamesToBeSearched.indexOf(timerIndex){ // Get the index of received cardId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfNamesToBeSearched+1 < arrayOfNamesToBeSearched.count{ // if next exists
                    indexOfNamesToBeSearched = indexOfTimerIndexInArrayOfNamesToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfNamesToBeSearched[indexOfTimerIndexInArrayOfNamesToBeSearched+1]
                    timesRepeatedCounterNames = 0
                    cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetName \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
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
    func nameReceivedFromPLC (notification:NSNotification) {
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
                cardNameTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfTimerDidGetName(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                NSLog("func nameReceivedFromPLC index:\(index) :deviceIndex\(nextTimerIndexToBeSearched)")
                sendCommandForFindingNameWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            }else{
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingNameWithTimerAddress(cardId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
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
    
    // MARK: - Timer parameters
    // Gets all input parameters and prepares everything for scanning, and initiates scanning.
    func findParametarsForCard() {
        progressBarScreenTimerNames?.dissmissProgressBar()
        progressBarScreenTimerNames = nil
        do {
            arrayOfParametersToBeSearched = [Int]()
            indexOfParametersToBeSearched = 0
            
            guard let rangeFromText = fromTextField.text else{
                alertController("Error", message: "Range can't be empty")
                return
            }
            
            guard let rangeFrom = Int(rangeFromText) else{
                alertController("Error", message: "Range can be only number")
                return
            }
            let from = rangeFrom
            
            guard let rangeToText = toTextField.text else{
                alertController("Error", message: "Range can't be empty")
                return
            }
            
            guard let rangeTo = Int(rangeToText) else{
                alertController("Error", message: "Range can be only number")
                return
            }
            let to = rangeTo
            
            if rangeTo < rangeFrom {
                alertController("Error", message: "Range \"from\" can't be higher than range \"to\"")
                return
            }
            
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
                progressBarScreenTimerNames = ProgressBarVC(title: "Finding timer parametars", percentage: Float(1)/Float(self.arrayOfParametersToBeSearched.count), howMuchOf: "1 / \(self.arrayOfParametersToBeSearched.count)")
                progressBarScreenTimerNames?.delegate = self
                self.presentViewController(progressBarScreenTimerNames!, animated: true, completion: nil)
                cardParameterTimer?.invalidate()
                cardParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: parameterIndex, repeats: false)
                NSLog("func findNames \(parameterIndex)")
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: UserDefaults.IsScaningCardParameters)
                sendCommandForFindingParameterWithTimerAddress(parameterIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from FindParameter")
            }
        } catch let error as InputError {
            alertController("Error", message: error.description)
        } catch {
            alertController("Error", message: "Something went wrong.")
        }
    }
    // Called from findParametarsForTimer or from it self.
    // Checks which timer ID should be searched for and calls sendCommandForFindingParameterWithTimerAddress for that specific timer id.
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
            sendCommandForFindingParameterWithTimerAddress(cardIndex, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
            print("Command sent for parameter from CheckIfTimerDidGetParameter (repeat \(timesRepeatedCounterParameters))")
        }else{
            if let indexOfTimerIndexInArrayOfParametersToBeSearched = arrayOfParametersToBeSearched.indexOf(cardIndex){ // Get the index of received timerId. Array "arrayOfNamesToBeSearched" contains indexes of devices that don't have name
                if indexOfTimerIndexInArrayOfParametersToBeSearched+1 < arrayOfParametersToBeSearched.count{ // if next exists
                    indexOfParametersToBeSearched = indexOfTimerIndexInArrayOfParametersToBeSearched+1
                    let nextTimerIndexToBeSearched = arrayOfParametersToBeSearched[indexOfTimerIndexInArrayOfParametersToBeSearched+1]
                    timesRepeatedCounterParameters = 0
                    cardParameterTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ScanCardsViewController.checkIfCardDidGetParametar(_:)), userInfo: nextTimerIndexToBeSearched, repeats: false)
                    NSLog("func checkIfDeviceDidGetParameter \(nextTimerIndexToBeSearched)")
                    sendCommandForFindingParameterWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
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
                sendCommandForFindingParameterWithTimerAddress(nextTimerIndexToBeSearched, addressOne: addressOne, addressTwo: addressTwo, addressThree: addressThree)
                print("Command sent for parameter from timerParameterReceivedFromPLC: next parameter")
            }else{
                shouldFindCardParameters = false
                dismissScaningControls()
            }
        }
    }
    // Sends byteArray to PLC
    func sendCommandForFindingParameterWithTimerAddress(timerId: Int, addressOne: Int, addressTwo: Int, addressThree: Int) {
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
        progressBarScreenTimerNames!.dissmissProgressBar()
        
        arrayOfNamesToBeSearched = [Int]()
        indexOfNamesToBeSearched = 0
        arrayOfParametersToBeSearched = [Int]()
        indexOfParametersToBeSearched = 0
        reloadCards()
        if !shouldFindCardParameters {
            UIApplication.sharedApplication().idleTimerDisabled = false
        } else {
            _ = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(ScanCardsViewController.findParametarsForCard), userInfo: nil, repeats: false)
        }
    }
    func alertController (title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            // ...
        }
        alertController!.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            // ...
        }
        alertController!.addAction(OKAction)
        
        self.presentViewController(alertController!, animated: true) {
            // ...
        }
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
