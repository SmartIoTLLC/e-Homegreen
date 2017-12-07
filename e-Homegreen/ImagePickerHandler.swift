//
//  ImagePickerHandler.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/1/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation
import MobileCoreServices

class ImagePickerHandler: NSObject {
    
    private let imagePicker = UIImagePickerController()
    private let isPhotoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    private let isSavedPhotoAlbumAvailable = UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
    private let isCameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
    
    var delegate: UINavigationControllerDelegate & UIImagePickerControllerDelegate
    
    init(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        self.delegate = delegate
    }
    
    func openPhotoLibrary(on vc: UIViewController, allowsEditing: Bool, mediaType: UIImagePickerControllerSourceType) {
        
        guard isPhotoLibraryAvailable && isSavedPhotoAlbumAvailable else { return }
        let type = kUTTypeImage as String
        
        imagePicker.sourceType = mediaType
        
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: mediaType) {
            if availableTypes.contains(type) {
                imagePicker.mediaTypes = [type]
            }
        }
        
        imagePicker.allowsEditing = allowsEditing
        imagePicker.delegate = delegate
        vc.present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera(on vc: UIViewController, allowsEditing: Bool) {
        
        guard isCameraAvailable else { return }
        let type = kUTTypeImage as String
        
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if availableTypes.contains(type) {
                imagePicker.mediaTypes = [type]
                imagePicker.sourceType = .camera
                imagePicker.cameraDevice = .rear
            }
        }
        
        imagePicker.allowsEditing = allowsEditing
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        vc.present(imagePicker, animated: true, completion: nil)
    }
    

}
