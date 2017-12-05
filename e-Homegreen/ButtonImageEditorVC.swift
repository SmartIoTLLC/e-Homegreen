//
//  ButtonImageEditorVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/1/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit
import AKImageCropperView

class ButtonImageEditorVC: CommonXIBTransitionVC {
    
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var cropView: AKImageCropperView!
    
    var image: UIImage?
    
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var casiButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
       // super.viewDidLoad()

        setupViews()
    }
    
    fileprivate func setupViews() {
        if let image = image {
            cropView.image = image
        }
        
        casiButton.addTarget(self, action: #selector(cropAndSaveImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
    }
    
    @objc fileprivate func cropAndSaveImage() {
        guard let image = cropView.croppedImage else { return }
        save(image: image)
        dismissModal()
    }
    
    @objc fileprivate func saveImage() {
        guard let image = image else { return }
        save(image: image)
        dismissModal()
    }
    
    fileprivate func save(image: UIImage) {
        if let moc = managedContext {
            let moImage       = Image(context: moc)
            moImage.imageId   = "buttonImage"
            moImage.imageData = UIImagePNGRepresentation(image)
            if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
                user.addImagesObject(moImage)
                CoreDataController.sharedInstance.saveChanges()
                NotificationCenter.default.post(name: .CustomButtonImageEdited, object: nil)
            }
        }
    }
}



extension UIViewController {
    func showButtonImageEditorVC(image: UIImage) {
        let vc = ButtonImageEditorVC()
        vc.image = image
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(vc, animated: true, completion: nil)
        //present(vc, animated: true, completion: nil)
    }
}
