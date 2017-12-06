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
        setupViews()
    }
    
    fileprivate func setupViews() {
        cropView.backgroundColor = Colors.AndroidGrayColor
        view.backgroundColor     = Colors.AndroidGrayColor
        
        
        if let image = image {
            cropView.image = image
        }
        
        loadButton.addTarget(self, action: #selector(loadImage), for: .touchUpInside)
        casiButton.addTarget(self, action: #selector(cropAndSaveImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
    }
    
    @objc fileprivate func loadImage() {
        let handler = ImagePickerHandler(delegate: self)
        let optionMenu = UIAlertController(title: "", message: "", preferredStyle: .alert)
        optionMenu.popoverPresentationController?.sourceView = view
        
        let photoGallery = UIAlertAction(title: "Photo gallery", style: .default) { (_) in
            handler.openPhotoLibrary(on: self, allowsEditing: true, mediaType: .photoLibrary)
        }
        
        let savedPhotosAlbum = UIAlertAction(title: "Saved Photos Album", style: .default) { (_) in
            handler.openPhotoLibrary(on: self, allowsEditing: true, mediaType: .savedPhotosAlbum)
        }
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (_) in
            handler.openCamera(on: self, allowsEditing: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(photoGallery)
        optionMenu.addAction(savedPhotosAlbum)
        optionMenu.addAction(camera)
        optionMenu.addAction(cancel)
        present(optionMenu, animated: true, completion: nil)
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

extension ButtonImageEditorVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var pickedImage: UIImage!
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            pickedImage = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            pickedImage = image
        }
        
        image = pickedImage
        cropView.image = pickedImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ButtonImageEditorVC: UINavigationControllerDelegate {}

extension UIViewController {
    func showButtonImageEditorVC(image: UIImage) {
        let vc = ButtonImageEditorVC()
        vc.image = image
        present(vc, animated: true, completion: nil)
    }
}
