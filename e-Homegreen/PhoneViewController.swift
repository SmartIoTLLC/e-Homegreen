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

private struct LocalConstants {
    static let micViewSize: CGSize = CGSize(width: 340, height: 200)
    static let micLabelHeight: CGFloat = 30
    static let micImageSize: CGFloat = 100
    static let makeCallButtonSize: CGSize = CGSize(width: 120, height: 40)
}

class PhoneViewController: UIViewController {
    
    fileprivate let titleView = NavigationTitleViewNF(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: 44))
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var recognizedSpeechString: String?
    var recognizedSpeechStringsSeparated: [String]?
    
    var speechRecognitionTimeout: Foundation.Timer?
    var speechTimeoutInterval: TimeInterval = 2 {
        didSet { restartSpeechTimeout() }
    }
    
    let usersContactStorage = CNContactStore()
    var contactsList = [CNContact]()
    
    var dismissGesture: UITapGestureRecognizer!
    
    private let infoButton: UIButton = UIButton()
    
    private let backgroundImageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "Background"))
    
    private let microphoneView: UIView = UIView()
    private let micLabel: UILabel = UILabel()
    private let micImage: UIImageView = UIImageView(image: #imageLiteral(resourceName: "siri_mic"))
    
    private var menuButton: UIBarButtonItem {
        return self.makeMenuBarButton()
    }
    
    private var fullscreenButton: UIButton {
        return self.makeFullscreenButton()
    }
    
    private let makeCallButton: CustomGradientButton = CustomGradientButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissGesture = UITapGestureRecognizer(target: self, action: #selector(micBackgroundTapped(_:)))
        
        setupBarButtonItems()
        requestSpeechAuthorization()
        
        addBackgroundImageView()
        addTitleView()
        addMakeCallButton()
        addMicrophoneView()
        addMicLabel()
        addMicImageView()
        
        addInfoButton()
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeFullscreenImage(fullscreenButton: fullscreenButton)
    }
    
    // MARK: - Setup views
    func addTitleView() {
        navigationItem.titleView = titleView
        titleView.setTitle("Phone")
        navigationController?.navigationBar.setBackgroundImage(imageLayerForGradientBackground(), for: .default)
    }
    
    private func setupBarButtonItems() {
        navigationItem.leftBarButtonItem = menuButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: fullscreenButton)
    }
    
    private func addBackgroundImageView() {
        backgroundImageView.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageView)
    }
    
    private func addMicrophoneView() {
        microphoneView.layer.cornerRadius = 5
        microphoneView.backgroundColor    = .googleMicBackgroundWhite
        microphoneView.alpha              = 0.0
        microphoneView.addShadows()
        
        view.addSubview(microphoneView)
    }
    
    private func addMicLabel() {
        micLabel.text                      = "Speak to search"
        micLabel.textColor                 = .googleMicTextGreen
        micLabel.font                      = .tahoma(size: 15)
        micLabel.textAlignment             = .center
        
        microphoneView.addSubview(micLabel)
    }
    
    private func addMicImageView() {
        micImage.contentMode         = .scaleAspectFit
        micImage.layer.cornerRadius  = LocalConstants.micImageSize / 2
        micImage.layer.masksToBounds = true
        
        microphoneView.addSubview(micImage)
    }
    
    private func addMakeCallButton() {
        makeCallButton.setTitleColor(.white, for: UIControlState())
        makeCallButton.setTitle("MAKE A CALL", for: UIControlState())
        makeCallButton.addTap {
            self.toggleMic(off: false)
            self.recordAndRecognizeSpeech()
        }
        
        view.addSubview(makeCallButton)
    }
    
    private func addInfoButton() {
        infoButton.setImage(#imageLiteral(resourceName: "info_3-512").withRenderingMode(.alwaysTemplate), for: UIControlState())
        infoButton.imageView?.tintColor = .white
        infoButton.addTap {
            let infoViewController: PhoneInstructionsViewController = PhoneInstructionsViewController()
            infoViewController.modalTransitionStyle = .crossDissolve
            infoViewController.modalPresentationStyle = .overCurrentContext
            self.present(infoViewController, animated: true, completion: nil)
        }
        
        view.addSubview(infoButton)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        
        microphoneView.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.width.equalTo(LocalConstants.micViewSize.width)
            make.height.equalTo(LocalConstants.micViewSize.height)
        }
        
        micLabel.snp.makeConstraints { (make) in
            make.height.equalTo(LocalConstants.micLabelHeight)
            make.leading.equalToSuperview().offset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.top.equalToSuperview()
        }
        
        micImage.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(LocalConstants.micImageSize)
        }
        
        makeCallButton.snp.makeConstraints { (make) in
            make.centerY.centerX.equalToSuperview()
            make.width.equalTo(LocalConstants.makeCallButtonSize.width)
            make.height.equalTo(LocalConstants.makeCallButtonSize.height)
        }
        
        infoButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.trailing.equalToSuperview().inset(GlobalConstants.sidePadding)
            make.width.height.equalTo(35)
        }
    }
    
    // MARK: - Logic
    // AUDIO
    func toggleMic(off: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.microphoneView.alpha = off ? 0.0 : 1.0
            } )
        }
        
        off ? view.removeGestureRecognizer(dismissGesture) : view.addGestureRecognizer(dismissGesture)
    }
    
    func toggleButtonOnMainThread(button: UIButton, enabled: Bool) {
        DispatchQueue.main.async { button.isEnabled = enabled }
    }
    
    func micBackgroundTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        toggleMic(off: true)
        stopRecording()
    }
    
    func restartSpeechTimeout() {
        speechRecognitionTimeout?.invalidate()
        speechRecognitionTimeout = Foundation.Timer.scheduledTimer(timeInterval: speechTimeoutInterval, target: self, selector: #selector(timedOut), userInfo: nil, repeats: false)
    }
    
    func forceRemoveMic() {
        DispatchQueue.main.async { self.microphoneView.alpha = 0.0 }
        view.removeGestureRecognizer(dismissGesture)
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
    
    func recordAndRecognizeSpeech() {
        
        guard let node = audioEngine.inputNode else {
            hideToastActivityOnMainThread()
            self.forceRemoveMic()
            self.makeToastOnMainThread(message: "Audio engine failed.")
            return
        }
        
        let recordingFormat = node.inputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, tamper) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch let error as NSError {
            hideToastActivityOnMainThread()
            self.forceRemoveMic()
            makeToastOnMainThread(message: "Audio engine failed.")
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            hideToastActivityOnMainThread()
            self.forceRemoveMic()
            makeToastOnMainThread(message: "Speech recognition failed.")
            node.removeTap(onBus: 0)
            return
        }
        
        if !myRecognizer.isAvailable {
            hideToastActivityOnMainThread()
            self.forceRemoveMic()
            makeToastOnMainThread(message: "Speech recognition failed.")
            node.removeTap(onBus: 0)
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            var isFinal: Bool = false
            
            if let result = result { isFinal = result.isFinal }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                node.removeTap(onBus: 0)
                self.recognitionTask = nil
                self.hideToastActivityOnMainThread()
            }
            
            if isFinal {
                self.stopRecording()
                let recognizedContact = result?.bestTranscription.formattedString
                self.hideToastActivityOnMainThread()
                self.toggleMic(off: true)
                self.fetchContacts(recognizedContact: recognizedContact!)
            } else {
                if error == nil { self.restartSpeechTimeout() } else { self.toggleMic(off: true) }
            }
            
        })
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized    : self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: true); self.requestContactsAuthorization()
            case .denied        : self.makeToastOnMainThread(message: "Please go to your Privacy Settings and provide us access to Speech Recognition."); self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: false)
            case .notDetermined : self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: false)
            case .restricted    : self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: false)
            }
        }
    }
    
    func makeToastOnMainThread(message: String) {
        DispatchQueue.main.async { self.view.makeToast(message: message) }
    }
    
    func makeToastActivityOnMainThread() {
        DispatchQueue.main.async { self.view.makeToastActivity() }
    }
    
    func hideToastActivityOnMainThread() {
        DispatchQueue.main.async { self.view.hideToastActivity() }
    }
    
    
    // CONTACTS
    func requestContactsAuthorization() {
        
        let authStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authStatus {
        case .authorized    : self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: true)
        case .denied        : self.makeToastOnMainThread(message: "Please go to your Privacy Settings and provide us access to Contacts."); self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: false)
        case .notDetermined : break //self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: false)
        case .restricted    : self.toggleButtonOnMainThread(button: self.makeCallButton, enabled: false)
        }
    }
    
    func fetchContacts(recognizedContact: String) {
        
        let keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey as CNKeyDescriptor]
        let request: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: keys)
        
        let predicate = CNContact.predicateForContacts(matchingName: recognizedContact.removeUnwantedKeywords())
        
        do {
            let containerResults = try usersContactStorage.unifiedContacts(matching: predicate, keysToFetch: keys)
            
            var contactName: String = ""
            
            if let firstName = containerResults.first?.givenName {
                contactName += firstName
            }
            if let middleName = containerResults.first?.middleName {
                contactName += middleName
            }
            if let familyName = containerResults.first?.familyName {
                contactName += familyName
            }
            
            //let contactName = (containerResults.first?.givenName ?? "") + (containerResults.first?.middleName ?? "") + (containerResults.first?.familyName ?? "")
            /* TODO: use CONTAINS + remove whitespace
             add information button with a tutorial on how to use the feature
             */
            
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
                    } else { self.makeToastOnMainThread(message: "Didn't find contacts matching that name.") }
                    
                } catch { self.makeToastOnMainThread(message: "Failed fetching contacts.") }
            }
        } catch { self.makeToastOnMainThread(message: "Failed fetching contacts.") }
    }
    
    func callContact(number: String) {
        var formattedNumber = ""
        for c in number {
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(c) { formattedNumber += String(describing: c) }
        }
        
        if let num = URL(string: "tel:\(formattedNumber)") {
            UIApplication.shared.open(num, options: [:], completionHandler: nil)
        }
    }
}

// MARK : - Utility
extension String {
    
    func cutToThreeCharachters() -> String {
        var newString = ""
        for c in self {
            if newString.count < 4 { newString.append(c) }
        }
        return newString
    }
    
    fileprivate func removeUnwantedKeywords() -> String {
        return self.replacingOccurrences(of: "call", with: "").replacingOccurrences(of: "dial", with: "").replacingOccurrences(of: "please", with: "")
    }
    
}
