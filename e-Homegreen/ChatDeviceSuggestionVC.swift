//
//  ChatDeviceSuggestionVC.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 10/12/15.
//  Copyright © 2015 Teodor Stevic. All rights reserved.
//

import UIKit

protocol ChatDeviceDelegate{
    func choosedDevice(_ device: AnyObject, message:String)
}

class ChatDeviceSuggestionVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var height: NSLayoutConstraint!
    var isPresenting: Bool = true
    @IBOutlet weak var sugestionTableView: UITableView!
    
    var listOfDevice:[String] = []
    
    var delegate:ChatDeviceDelegate?
    var objects:[AnyObject] = []
    var message:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        height.constant = sugestionTableView.contentSize.height
        
        sugestionTableView.register(UINib(nibName: "VoiceControllerTableViewCell", bundle: nil), forCellReuseIdentifier: "sugestionCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(sugestionTableView.contentSize.height)
        height.constant = sugestionTableView.contentSize.height
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: sugestionTableView) { return false }
        return true
    }
    
    @objc func handleTap(_ gesture:UITapGestureRecognizer){
        self.dismiss(animated: true, completion: nil)
    }
    
    init(){
        super.init(nibName: "ChatDeviceSuggestionVC", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfDevice.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "sugestionCell", for: indexPath) as? VoiceControllerTableViewCell {
            cell.deviceLbl.text = listOfDevice[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.choosedDevice(objects[indexPath.row], message: message)
        self.dismiss(animated: true, completion: nil)
    }

}

extension ChatDeviceSuggestionVC : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5 //Add your own duration here
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //Add presentation and dismiss animation transition here.
        animateTransitioning(isPresenting: &isPresenting, scaleOneX: 1.05, scaleOneY: 1.05, scaleTwoX: 1.1, scaleTwoY: 1.1, using: transitionContext)
    }
}



extension ChatDeviceSuggestionVC : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self { return self } else { return nil }
    }
    
}

extension UIViewController {
    func showSuggestion(_ objects:[AnyObject], message:String) -> ChatDeviceSuggestionVC{
        let suggVC = ChatDeviceSuggestionVC()
        suggVC.message = message
        suggVC.objects = objects
        if let anyObjects = objects as? [Device] {
            for anyObject in anyObjects {
                let address = "\(returnThreeCharactersForByte(anyObject.gateway.addressOne.intValue)):\(returnThreeCharactersForByte(anyObject.gateway.addressTwo.intValue)):\(returnThreeCharactersForByte(anyObject.address.intValue))"
                suggVC.listOfDevice.append("Device: \(anyObject.name) Location: \(anyObject.gateway.name) Address: \(address) Channel:\(anyObject.channel)")
            }
        }
        if let anyObjects = objects as? [Scene] {
            for anyObject in anyObjects {
                let address = "\(returnThreeCharactersForByte(anyObject.gateway.addressOne.intValue)):\(returnThreeCharactersForByte(anyObject.gateway.addressTwo.intValue)):\(returnThreeCharactersForByte(anyObject.address.intValue))"
                suggVC.listOfDevice.append("Scene: \(anyObject.sceneName) Location: \(anyObject.gateway.name) Address: \(address)")
            }
        }
        if let anyObjects = objects as? [Sequence] {
            for anyObject in anyObjects {
                let address = "\(returnThreeCharactersForByte(anyObject.gateway.addressOne.intValue)):\(returnThreeCharactersForByte(anyObject.gateway.addressTwo.intValue)):\(returnThreeCharactersForByte(anyObject.address.intValue))"
                suggVC.listOfDevice.append("Sequence: \(anyObject.sequenceName) Location: \(anyObject.gateway.name) Address: \(address)")
            }
        }
        if let anyObjects = objects as? [Event] {
            for anyObject in anyObjects {
                let address = "\(returnThreeCharactersForByte(anyObject.gateway.addressOne.intValue)):\(returnThreeCharactersForByte(anyObject.gateway.addressTwo.intValue)):\(returnThreeCharactersForByte(anyObject.address.intValue))"
                suggVC.listOfDevice.append("Event: \(anyObject.eventName) Location: \(anyObject.gateway.name) Address: \(address)")
            }
        }
        self.present(suggVC, animated: true, completion: nil)
        return suggVC
    }
}
extension NSObject {
    
    func returnThreeCharactersForByte (_ number:Int) -> String {
        return String(format: "%03d",number)
    }
}
