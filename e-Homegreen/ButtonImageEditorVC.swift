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
    var image: UIImage?
    
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cropView: AKImageCropperView!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var casiButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        setupViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateViews()
    }
    
}

// MARK: - Setup views
extension ButtonImageEditorVC {
    fileprivate func setupViews() {
        cropView.backgroundColor  = Colors.AndroidGrayColor
        view.backgroundColor      = Colors.AndroidGrayColor
        
        if let image = image {
            cropView.image = image
        }
        
        if let titleLabel = casiButton.titleLabel {
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = .center
            casiButton.setTitle("CROP AND\nSAVE IMAGE", for: UIControl.State())
        }
        
        loadButton.addTarget(self, action: #selector(loadImage), for: .touchUpInside)
        casiButton.addTarget(self, action: #selector(cropAndSaveImage), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
    }
    
    fileprivate func updateViews() {
        let width  = backView.frame.width / 3
        let height = backView.frame.height
        let size   = CGSize(width: width, height: height)
        
        loadButton.frame.size   = size
        loadButton.frame.origin = CGPoint.zero
        
        casiButton.frame.size   = size
        casiButton.frame.origin = CGPoint(x: loadButton.frame.maxX, y: 0)
        
        saveButton.frame.size   = size
        saveButton.frame.origin = CGPoint(x: casiButton.frame.maxX, y: 0)
        
        upperView.setGradientBackground()
        upperView.bringSubviewToFront(backButton)
    }
}

// MARK: - Logic
extension ButtonImageEditorVC {
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
            moImage.imageData = image.pngData()
            if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
                user.addImagesObject(moImage)
                CoreDataController.sharedInstance.saveChanges()
                NotificationCenter.default.post(name: .CustomButtonImageEdited, object: nil)
            }
        }
    }
}

// MARK: - Image Picker Delegate
extension ButtonImageEditorVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var pickedImage: UIImage!
     
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            pickedImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
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
