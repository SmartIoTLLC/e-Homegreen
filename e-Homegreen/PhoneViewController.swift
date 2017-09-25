//
//  PhoneViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/18/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import Speech
import Contacts

class PhoneViewController: UIViewController {
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var recognizedSpeechString: String?
    var recognizedSpeechStringsSeparated: [String]?
    
    let usersContactStorage = CNContactStore()
    var contactsList = [CNContact]()
    
    var microphoneView: UIView!
    
    var speechRecognitionTimeout: Foundation.Timer?
    var speechTimeoutInterval: TimeInterval = 2 {
        didSet {
            restartSpeechTimeout()
        }
    }
    
    func setupMicrophoneView() {
        microphoneView = UIView()
        microphoneView.frame.origin = CGPoint(x: UIScreen.main.bounds.width / 2 - 60, y: UIScreen.main.bounds.height / 2 - 200)
        microphoneView.frame.size = CGSize(width: 200, height: 200)
        microphoneView.layer.cornerRadius = 5
        microphoneView.backgroundColor = UIColor(cgColor: Colors.DarkGray)
        
        let micLogo = UIImageView()
        micLogo.frame = CGRect(x: 0, y: 30, width: microphoneView.frame.width, height: 170)
        micLogo.frame.size = CGSize(width: 110, height: 110)
        micLogo.image = #imageLiteral(resourceName: "18 Media - Microphone - 00")
        micLogo.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.frame = CGRect(x: 6, y: 0, width: microphoneView.frame.width - 12, height: 30)
        label.text = "Speak a contact's name"
        label.textColor = .white
        label.font = UIFont(name: "Tahoma", size: 15)
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        microphoneView.addSubview(micLogo)
        microphoneView.addSubview(label)
    }
    
    func restartSpeechTimeout() {
        speechRecognitionTimeout?.invalidate()
        speechRecognitionTimeout = Foundation.Timer.scheduledTimer(timeInterval: speechTimeoutInterval, target: self, selector: #selector(timedOut), userInfo: nil, repeats: false)
    }
    
    func timedOut() {
        stopRecording()
    }
    
    func stopRecording() {
        audioEngine.stop()
        request.endAudio()
        
        speechRecognitionTimeout?.invalidate()
        speechRecognitionTimeout = nil
    }
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var fullscreenButton: UIButton!
    @IBAction func fullscreenButton(_ sender: UIButton) {
        sender.collapseInReturnToNormal(1)
        if UIApplication.shared.isStatusBarHidden {
            UIApplication.shared.isStatusBarHidden = false
            sender.setImage(UIImage(named: "full screen"), for: UIControlState())
        } else {
            UIApplication.shared.isStatusBarHidden = true
            sender.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        }
    }
    
    @IBOutlet weak var makeCallButton: CustomGradientButton!
    @IBAction func makeCallButton(_ sender: CustomGradientButton) {
        recordAndRecognizeSpeech()
    }
    
    
    func changeFullScreeenImage(){
        if UIApplication.shared.isStatusBarHidden {
            fullscreenButton.setImage(UIImage(named: "full screen exit"), for: UIControlState())
        } else {
            fullscreenButton.setImage(UIImage(named: "full screen"), for: UIControlState())
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.revealViewController() != nil {
            
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            //self.revealViewController().panGestureRecognizer().delegate = self
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            revealViewController().toggleAnimationDuration = 0.5
            
            revealViewController().rearViewRevealWidth = 200
        }
        
        changeFullScreeenImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer?.delegate = self
        requestSpeechAuthorization()
        updateViews()
    }
    
    func updateViews() {
        navigationItem.title = "Phone"
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
        
        setupMicrophoneView()
    }

    func recordAndRecognizeSpeech() {
        
        guard let node = audioEngine.inputNode else {
            hideToastActivityOnMainThread()
            self.makeToastOnMainThread(message: "Audio engine failed.")
            return
        }
        
        let recordingFormat = node.inputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, tamper) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        
        hideToastActivityOnMainThread()
        do {
            try audioEngine.start()
        } catch let error as NSError {
            hideToastActivityOnMainThread()
            makeToastOnMainThread(message: "Audio engine failed.")
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            hideToastActivityOnMainThread()
            makeToastOnMainThread(message: "Speech recognition failed.")
            return }
        
        if !myRecognizer.isAvailable {
            hideToastActivityOnMainThread()
            makeToastOnMainThread(message: "Speech recognition failed.")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            var isFinal: Bool = false
            
            if let result = result {
                print("Speech recognition result: ", result.bestTranscription.formattedString)                
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                node.removeTap(onBus: 0)
                self.recognitionTask = nil
                self.hideToastActivityOnMainThread()
                print("Error in recognition task")
            }
            
            if isFinal {
                self.stopRecording()
                let recognizedContact = result?.bestTranscription.formattedString
                self.hideToastActivityOnMainThread()
                self.fetchContacts(recognizedContact: recognizedContact!)
            } else {
                if error == nil {
                    self.restartSpeechTimeout()
                } else {
                    self.makeToastOnMainThread(message: "Something went wrong. Please try again.")
                }
            }
            
        })
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                self.makeCallButton.isEnabled = true
                self.requestContactsAuthorization()
            case .denied:
                self.makeToastOnMainThread(message: "Please go to your Privacy Settings and provide us access to Speech Recognition.")
                self.makeCallButton.isEnabled = false
            case .notDetermined:
                self.makeCallButton.isEnabled = false
            case .restricted:
                self.makeCallButton.isEnabled = false
            }
        }
    }
    
    func makeToastOnMainThread(message: String) {
        DispatchQueue.main.async {
            self.view.makeToast(message: message)
        }
    }
    
    func makeToastActivityOnMainThread() {
        DispatchQueue.main.async {
            self.view.makeToastActivity()
        }
    }
    
    func hideToastActivityOnMainThread() {
        DispatchQueue.main.async {
            self.view.hideToastActivity()
        }
    }
    
    func requestContactsAuthorization() {
        
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authStatus {
        case .authorized:
            self.makeCallButton.isEnabled = true
        case .denied:
            self.makeToastOnMainThread(message: "Please go to your Privacy Settings and provide us access to Contacts.")
            self.makeCallButton.isEnabled = false
        case .notDetermined:
            self.makeCallButton.isEnabled = false
        case .restricted:
            self.makeCallButton.isEnabled = false
        }
    }
    
    func fetchContacts(recognizedContact: String) {
        
        let keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)
        
        let predicate = CNContact.predicateForContacts(matchingName: recognizedContact)
        
        do {
            let containerResults = try usersContactStorage.unifiedContacts(matching: predicate, keysToFetch: keys)
            
            let contactName = (containerResults.first?.givenName ?? "") + (containerResults.first?.middleName ?? "") + (containerResults.first?.familyName ?? "")
            
            if containerResults.count == 1 && recognizedContact.replacingOccurrences(of: " ", with: "") == contactName {
                if let phoneNumber = containerResults.first?.phoneNumbers.first?.value.stringValue {
                    callContact(number: phoneNumber)
                } else { self.makeToastOnMainThread(message: "Contact doesn't have a phone number.") }
                
            } else {
                
                do {
                    self.contactsList = []
                    try usersContactStorage.enumerateContacts(with: request, usingBlock: { (contact, stop) in
                        
                        if contact.givenName.lowercased().hasPrefix(recognizedContact.cutToThreeCharachters().lowercased()) {
                            self.contactsList.append(contact)
                        }
                    })
                    if self.contactsList.count != 0 {
                        self.showContactList(contacts: self.contactsList)
                    } else { self.makeToastOnMainThread(message: "Didn't found contacts matching that name.") }
                    
                } catch { self.makeToastOnMainThread(message: "Failed fetching contacts.") }
            }
        } catch { self.makeToastOnMainThread(message: "Failed fetching contacts.") }
    }

    
    func callContact(number: String) {
        var formattedNumber = ""
        for c in number.characters {
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(c) {
                formattedNumber += String(describing: c)
            }
        }
        if let num = URL(string: "tel:\(formattedNumber)") {
            UIApplication.shared.open(num, options: [:], completionHandler: nil)
        }
    }

}

extension PhoneViewController: SFSpeechRecognizerDelegate, SFSpeechRecognitionTaskDelegate {
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        
    }
    
}

extension String {
    
    func cutToThreeCharachters() -> String {
        var newString = ""
        for c in self.characters {
            if newString.characters.count < 4 {
                newString.append(c)
            }
        }
        return newString
    }
    
}
