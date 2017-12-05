//
//  DatabaseRemoteController.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 10/27/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import CoreData

public class DatabaseRemoteController: NSObject {
    
    open static let sharedInstance = DatabaseRemoteController()
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    func getRemotes(from location: Location) -> [Remote] {
        if let remotesSet = location.remotes {
            var remotes: [Remote] = []
            for remote in remotesSet { remotes.append(remote as! Remote) }
            return remotes
        }
        return []
    }
    
    func saveRemote(remote: Remote, to location: Location) {
        let rmt = remote
        
        for i in 1...(Int(rmt.rows!) * Int(rmt.columns!)) {
            let button = RemoteButton(context: managedContext!)
            button.name               = String(i)
            button.buttonId           = NSNumber(value: i)
            button.buttonShape        = remote.buttonShape
            button.buttonState        = ButtonState.visible
            button.buttonColor        = remote.buttonColor
            button.buttonWidth        = remote.buttonWidth
            button.buttonHeight       = remote.buttonHeight
            button.remote             = remote
            button.addressOne         = remote.addressOne
            button.addressTwo         = remote.addressTwo
            button.addressThree       = remote.addressThree
            button.buttonInternalType = ButtonInternalType.regular
            button.buttonType         = ButtonType.irButton
            button.imageScaleX        = 1.0
            button.imageScaleY        = 1.0
            button.marginTop          = remote.marginTop
                        
            rmt.addToButtons(button)
        }
        location.addToRemotes(rmt)

        saveManagedContext()
    }
    
    func cloneRemote(remote: Remote, on location: Location) {
        let remoteInfo = RemoteInformation(
            addressOne   : Int(remote.addressOne!),
            addressTwo   : Int(remote.addressTwo!),
            addressThree : Int(remote.addressThree!),
            buttonColor  : remote.buttonColor!,
            buttonShape  : remote.buttonShape!,
            buttonWidth  : Int(remote.buttonWidth!),
            buttonHeight : Int(remote.buttonHeight!),
            channel      : Int(remote.channel!),
            columns      : Int(remote.columns!),
            marginBottom : Int(remote.marginBottom!),
            marginTop    : Int(remote.marginTop!),
            name         : remote.name! + " Clone",
            rows         : Int(remote.rows!),
            location     : location
        )
        
        let clonedRemote = Remote(context: managedContext!, remoteInformation: remoteInfo)
        for btn in remote.buttons! {
            if let button = btn as? RemoteButton {
                let b = RemoteButton(context: managedContext!)
                b.name               = button.name
                b.buttonId           = button.buttonId
                b.buttonShape        = button.buttonShape
                b.buttonState        = button.buttonState
                b.buttonColor        = button.buttonColor
                b.buttonWidth        = button.buttonWidth
                b.buttonHeight       = button.buttonHeight
                b.remote             = clonedRemote
                b.addressOne         = button.addressOne
                b.addressTwo         = button.addressTwo
                b.addressThree       = button.addressThree
                b.buttonInternalType = button.buttonInternalType
                b.buttonType         = button.buttonType
                b.imageScaleX        = button.imageScaleX
                b.imageScaleY        = button.imageScaleY
                b.marginTop          = button.marginTop
                
                clonedRemote.addToButtons(b)
            }
        }
        
        location.addToRemotes(clonedRemote)
        saveManagedContext()
    }
    
    func deleteRemote(remote: Remote, from location: Location) {
        location.removeFromRemotes(remote)
        saveManagedContext()
    }
    
    func saveManagedContext() {
        do { try managedContext?.save() } catch { print("Failed saving managed context") }
    }
    
}

public class DatabaseRemoteButtonController: NSObject {
    
    open static let sharedInstance = DatabaseRemoteButtonController()
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    func saveButton(_ button: RemoteButton, to remote: Remote) {
        remote.addToButtons(button)
    }
    
    func editButton(_ button: RemoteButton) {
        if let storedButton = managedContext?.object(with: button.objectID) {
            storedButton.setValue(button.name, forKey: "name")
            storedButton.setValue(button.addressOne, forKey: "addressOne")
            storedButton.setValue(button.addressTwo, forKey: "addressTwo")
            storedButton.setValue(button.addressThree, forKey: "addressThree")
            storedButton.setValue(button.buttonColor, forKey: "buttonColor")
            storedButton.setValue(button.buttonShape, forKey: "buttonShape")
            storedButton.setValue(button.buttonHeight, forKey: "buttonHeight")
            storedButton.setValue(button.buttonWidth, forKey: "buttonWidth")
            storedButton.setValue(button.buttonState, forKey: "buttonState")
            storedButton.setValue(button.buttonType, forKey: "buttonType")
            storedButton.setValue(button.channel, forKey: "channel")
            storedButton.setValue(button.hexString, forKey: "hexString")
            storedButton.setValue(button.image, forKey: "image")
            storedButton.setValue(button.imageScaleX, forKey: "imageScaleX")
            storedButton.setValue(button.imageScaleY, forKey: "imageScaleY")
            storedButton.setValue(button.marginTop, forKey: "marginTop")
            storedButton.setValue(button.imageState, forKey: "imageState")
            storedButton.setValue(button.sceneId, forKey: "sceneId")
            
            CoreDataController.sharedInstance.saveChanges()
        }
    }
    
    func rollback() {
        if let ad = UIApplication.shared.delegate as? AppDelegate {
            if let moc = ad.managedObjectContext {
                moc.rollback()
            }
        }
    }
    
    func loadCustomImages() -> [Image] {
        var imageList: [Image] = []
        
        if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
            if let images = user.images {
                images.forEach({ (image) in
                    if let image = image as? Image { imageList.append(image) } })
            }
        }
        
        return imageList
    }
}