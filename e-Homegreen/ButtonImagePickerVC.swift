//
//  ButtonImagePickerVC.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 11/29/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class ButtonImagePickerVC: CommonXIBTransitionVC {
    
    let cellId = "imageCell"
    
    var availableImages: [UIImage] = []
    
    var customImagesMO: [Image] = []
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    // Toolbar buttons
    var setButton: UIButton!
    var cancelButton: UIButton!
    var importButton: UIButton!
    var editButton: UIButton!
    //
    
    var isCustom: Bool = false
    
    var scBottomLine: CALayer = {
        let layer = CALayer()
        layer.borderColor = UIColor.eHome.turquoiseBlue.cgColor
        layer.borderWidth = 2
        return layer
    }()
    
    var button: RemoteButton! {
        didSet {
            if let image = button.image {
                selectedImage = UIImage(data: image as Data)
                // TODO: cuvati i image string zbog prikazivanja indikatora po ponovnom ulasku na ekran
            }
        }
    }
    
    var selectedImage: UIImage?

    @IBOutlet weak var backgroundView: CustomGradientBackground!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        scTapped(sender)
    }


    
    override func viewDidLoad() {
        setupViews()
        
        addObservers()
    }

    fileprivate func setupViews() {
        imageCollectionView.delegate   = self
        imageCollectionView.dataSource = self
        imageCollectionView.register(UINib(nibName: String(describing: ButtonImageCell.self), bundle: nil), forCellWithReuseIdentifier: cellId)
        imageCollectionView.backgroundColor = .clear
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        backgroundView.layer.borderColor   = Colors.MediumGray
        backgroundView.layer.borderWidth   = 1
        backgroundView.layer.cornerRadius  = 15
        backgroundView.layer.masksToBounds = true             
        
        segmentedControl.setTitle("DEFAULT LIBRARY", forSegmentAt: 0)
        segmentedControl.setTitle("CUSTOM LIBRARY", forSegmentAt: 1)
        let attributes: [String: AnyObject] = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "Tahoma", size: 15.0)!
        ]
        segmentedControl.setTitleTextAttributes(attributes, for: UIControlState())
        
        scBottomLine.frame = CGRect(x: segmentedControl.frame.minX, y: segmentedControl.frame.height - 2, width: segmentedControl.frame.width / 2, height: 2)
        segmentedControl.layer.addSublayer(scBottomLine)
        
        bottomToolbar.backgroundColor = .clear
        
        let toolbarSeparator = UIView()
        toolbarSeparator.frame           = CGRect(x: 8, y: 0, width: bottomToolbar.frame.width - 16, height: 1)
        toolbarSeparator.backgroundColor = UIColor(cgColor: Colors.MediumGray).withAlphaComponent(0.5)
        bottomToolbar.addSubview(toolbarSeparator)
        
        setButton    = UIButton()
        cancelButton = UIButton()
        cancelButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        setButton.addTarget(self, action: #selector(chooseImage), for: .touchUpInside)
        set(button: setButton, tag: 3)
        set(button: cancelButton, tag: 2)
        
        loadDefaultImages()
    }
    
    fileprivate func scTapped(_ sender: UISegmentedControl) {
        scBottomLine.removeFromSuperlayer()
        
        let barWidth = sender.frame.size.width / 2
        let x        = CGFloat(sender.selectedSegmentIndex) * barWidth
        let y        = sender.frame.height - 2
        
        scBottomLine.frame = CGRect(x: x, y: y, width: barWidth, height: 2)
        segmentedControl.layer.addSublayer(scBottomLine)
        
        switch sender.selectedSegmentIndex {
            case 0  : setToolbarForDefaultLibrary(); loadDefaultImages()
            case 1  : setToolbarForCustomLibrary(); loadCustomImages()
            default : break
        }
        
        imageCollectionView.reloadData()
    }
    
    fileprivate func setToolbarForDefaultLibrary() {
        importButton.removeFromSuperview()
        editButton.removeFromSuperview()
    }

    fileprivate func setToolbarForCustomLibrary() {
        importButton = UIButton()
        editButton   = UIButton()
        editButton.addTarget(self, action: #selector(editImage), for: .touchUpInside)
        importButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        set(button: importButton, tag: 1)
        set(button: editButton, tag: 0)
    }
    
    fileprivate func loadDefaultImages() {
        availableImages = []
        let defaultImages = [
            "04 Climate Control - Air Freshener - 00",
            "04 Climate Control - Air Freshener - 01",
            "04 Climate Control - HVAC - 00",
            "04 Climate Control - HVAC - 01",
            "11 Lighting - Bulb - 00",
            "11 Lighting - Bulb - 01",
            "11 Lighting - Bulb - 02",
            "11 Lighting - Bulb - 03",
            "11 Lighting - Bulb - 04",
            "11 Lighting - Bulb - 05",
            "11 Lighting - Bulb - 06",
            "11 Lighting - Bulb - 07",
            "11 Lighting - Bulb - 08",
            "11 Lighting - Bulb - 09",
            "11 Lighting - Bulb - 10",
            "11 Lighting - Flood Light - 00",
            "11 Lighting - Flood Light - 01",
            "12 Appliance - Bell - 00",
            "12 Appliance - Bell - 01",
            "12 Appliance - Big Bell - 00.png",
            "12 Appliance - Big Bell - 01",
            "12 Appliance - Fountain - 00",
            "12 Appliance - Fountain - 01",
            "12 Appliance - Hood - 00",
            "12 Appliance - Hood - 01",
            "12 Appliance - Power - 00",
            "12 Appliance - Power - 01",
            "12 Appliance - Power - 02",
            "12 Appliance - Socket - 00",
            "12 Appliance - Socket - 01",
            "12 Appliance - Sprinkler - 00",
            "12 Appliance - Sprinkler - 01",
            "12 Appliance - Switch - 00",
            "12 Appliance - Switch - 01",
            "12 Appliance - Washing Machine - 00",
            "12 Appliance - Washing Machine - 01",
            "12 Appliance - Water Heater - 00",
            "12 Appliance - Water Heater - 01",
            "13 Curtain - Curtain - 00",
            "13 Curtain - Curtain - 01",
            "13 Curtain - Curtain - 02",
            "13 Curtain - Curtain - 03",
            "13 Curtain - Curtain - 04",
            "14 Security - Camcorder - 00",
            "14 Security - Camera - 00",
            "14 Security - Door - 00",
            "14 Security - Door - 01",
            "14 Security - Gate - 00",
            "14 Security - Gate - 01",
            "14 Security - Lock - 00",
            "14 Security - Lock - 01",
            "14 Security - Motion Sensor - 00",
            "14 Security - Motion Sensor - 01",
            "14 Security - Motion Sensor - 02",
            "14 Security - Reader - 00",
            "14 Security - Reader - 01",
            "14 Security - Reader - 02",
            "14 Security - Smoke Heat - 00",
            "14 Security - Smoke Heat - 01",
            "14 Security - Surveillance - 00",
            "14 Security - Window - 00",
            "14 Security - Window - 01",
            "15 Timer - CLock - 00",
            "15 Timer - CLock - 01",
            "16 Flag - Flag - 00",
            "16 Flag - Flag - 01",
            "17 Event - Alarm - 00",
            "17 Event - Alarm - 01",
            "17 Event - Away - 00",
            "17 Event - Away - 01",
            "17 Event - Baby - 00",
            "17 Event - Baby - 01",
            "17 Event - Baby Sleep - 00",
            "17 Event - Baby Sleep - 01",
            "17 Event - Bye - 00",
            "17 Event - Bye - 01",
            "17 Event - Chill - 00",
            "17 Event - Chill - 01",
            "17 Event - Daytime - 00",
            "17 Event - Daytime - 01",
            "17 Event - Dining - 00",
            "17 Event - Dining - 01",
            "17 Event - Earth - 00",
            "17 Event - Earth - 01",
            "17 Event - Follow Me - 00",
            "17 Event - Follow Me - 01",
            "17 Event - Guest - 00",
            "17 Event - Guest - 01",
            "17 Event - Home - 00",
            "17 Event - Home - 01",
            "17 Event - Late Night - 00",
            "17 Event - Late Night - 01",
            "17 Event - Movie - 00",
            "17 Event - Movie - 01",
            "17 Event - Night - 00",
            "17 Event - Night - 01",
            "17 Event - Ramp Down - 00",
            "17 Event - Ramp Down - 01",
            "17 Event - Ramp Up - 00",
            "17 Event - Ramp Up - 01",
            "17 Event - Relax - 00",
            "17 Event - Relax - 01",
            "17 Event - Up Down - 00",
            "17 Event - Up Down - 01",
            "17 Event - Vacation - 00",
            "17 Event - Vacation - 01",
            "18 Media - 5.1 Speakers - 00",
            "18 Media - CD - 00",
            "18 Media - Ceiling Speaker - 00",
            "18 Media - Ceiling Speaker - 01",
            "18 Media - Chat - 00",
            "18 Media - Fax - 00",
            "18 Media - Game Pad - 00",
            "18 Media - Handset - 00.png",
            "18 Media - Hi Fi - 00",
            "18 Media - LCD Screen - 00",
            "18 Media - LCD TV - 00",
            "18 Media - LCD TV - 01",
            "18 Media - Mail - 00",
            "18 Media - Microphone - 00",
            "18 Media - Mobile - 00.png",
            "18 Media - Music Note - 00",
            "18 Media - PC - 00",
            "18 Media - Photo - 00.png",
            "18 Media - Projector - 00",
            "18 Media - Projector - 01",
            "18 Media - Projector Lift - 00",
            "18 Media - Projector Lift - 01",
            "18 Media - Projector Screen - 00",
            "18 Media - Projector Screen - 01",
            "18 Media - Radio - 00",
            "18 Media - Remote - 00",
            "18 Media - SMS - 00",
            "18 Media - Setup Box - 00",
            "18 Media - Speaker - 00",
            "18 Media - Speaker - 01",
            "18 Media - Telephone - 00",
            "18 Media - iPod - 00",
            "19 Blind - Blind - 00",
            "19 Blind - Blind - 01",
            "19 Blind - Blind - 02",
            "19 Blind - Blind - 03",
            "19 Blind - Blind - 04",
            "19 Blind - Blind - 05",
            "19 Blind - Blind - 06",
            "19 Blind - Blind - Down",
            "19 Blind - Blind - Stop",
            "19 Blind - Blind - Up",
            "19 Blind - Venitian Blind - 00",
            "19 Blind - Venitian Blind - 01",
            "Others - Admin - 00",
            "Others - Arab - 00",
            "Others - Boy - 00",
            "Others - Employee - 00",
            "Others - Info - 00",
            "Others - Pi Chart - 00",
            "Others - Question - 00",
            "Others - Receptionest - 00",
            "Others - Refresh - 00",
            "Others - Setting - 00",
            "Others - Windows - 00",
            "Others - Wireless - 00.png",
            "Others - Young Arab - 00",
            "Others - e-Home - 00",
            "Others - e-Homegreen - 00",
            "Scene - All High - 00",
            "Scene - All High - 01",
            "Scene - All Low - 00",
            "Scene - All Low - 01",
            "Scene - All Medium - 00",
            "Scene - All Medium - 01",
            "Scene - All Off - 00",
            "Scene - All Off - 01",
            "Scene - All On - 00",
            "Scene - All On - 01",
            "Scene - Movie - 00",
            "Scene - Movie - 01"
        ]
        
        defaultImages.forEach { (string) in
            if let image = UIImage(named: string) { availableImages.append(image) }
        }
        isCustom = false
        imageCollectionView.reloadData()
    }
    
    @objc fileprivate func openImagePicker() {
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
    
    @objc fileprivate func loadCustomImages() {
        availableImages = []
        
        customImagesMO = []
        customImagesMO = DatabaseRemoteButtonController.sharedInstance.loadCustomImages()
        
        customImagesMO.forEach { (image) in
            if let data = image.imageData {
                if let image = UIImage(data: data) { availableImages.append(image) }
            }
        }
        
        isCustom = true
        imageCollectionView.reloadData()
    }
    
    @objc fileprivate func chooseImage() {
        if let selectedImage = selectedImage {
            button.image = UIImagePNGRepresentation(selectedImage)! as NSData
            NotificationCenter.default.post(name: .ButtonImageChosen, object: nil)
            dismissModal()
        } else {
            view.makeToast(message: "You didn't select any image.")
        }
    }
    
    @objc fileprivate func editImage() {
        if let image = selectedImage {
            showButtonImageEditorVC(image: image)
        } else {
            view.makeToast(message: "You didn't select any image.")
        }
    }
    
    fileprivate func set(button: UIButton, tag: CGFloat) {
        switch tag {
            case 0  : button.setTitle("EDIT", for: UIControlState())
            case 1  : button.setTitle("IMPORT", for: UIControlState())
            case 2  : button.setTitle("CANCEL", for: UIControlState())
            case 3  : button.setTitle("SET", for: UIControlState())
            default : break
        }
        
        button.setTitleColor(.white, for: UIControlState())
        button.titleLabel?.font = .tahoma(size: 15)
        
        let width = bottomToolbar.frame.width / 4
        
        button.frame.size       = CGSize(width: width, height: bottomToolbar.frame.height)
        button.frame.origin.x   = tag * width
        button.frame.origin.y   = 0
        
        button.backgroundColor  = .clear
        
        bottomToolbar.addSubview(button)
    }
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadCustomImages), name: .CustomButtonImageEdited, object: nil)
    }
    
}

extension ButtonImagePickerVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var pickedImage: UIImage!
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            pickedImage = image
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            pickedImage = image
        }
                
        if let moc = managedContext {
            let moImage = Image(context: moc, image: UIImagePNGRepresentation(pickedImage)!, id: "buttonImage")
            
            if let user = DatabaseUserController.shared.loggedUserOrAdmin() {
                user.addImagesObject(moImage)
                CoreDataController.sharedInstance.saveChanges()
                NotificationCenter.default.post(name: .CustomButtonImageEdited, object: nil)
            }
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissModal()
    }
}

extension ButtonImagePickerVC: UINavigationControllerDelegate {
    
}

// MARK: - Collection View Data Source
extension ButtonImagePickerVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ButtonImageCell {
            
            cell.image = availableImages[indexPath.item]
            if isCustom { cell.customImageMO = customImagesMO[indexPath.item] }
            
            let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(showDeleteButtonImageVC(_:)))
            lpgr.minimumPressDuration = 0.5
            
            cell.addGestureRecognizer(lpgr)
            
            return cell
        }
        return UICollectionViewCell()
    }

    @objc fileprivate func showDeleteButtonImageVC(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if isCustom {
            if let cell = gestureRecognizer.view as? ButtonImageCell {
                if let image = cell.customImageMO {
                    showDeleteButtonImageVC(image: image)
                }
            }
        }
    }
    
}

// MARK: - Collection View Delegate
extension ButtonImagePickerVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem(indexPath: indexPath)
        
        checkSelectedBorder()
    }
    
    fileprivate func didSelectItem(indexPath: IndexPath) {
        selectedImage = availableImages[indexPath.item]
        
        if let cell = imageCollectionView.cellForItem(at: indexPath) as? ButtonImageCell {
            cell.isTapped = true
        }
    }
    
    fileprivate func checkSelectedBorder() {
        for cell in imageCollectionView.visibleCells {
            if let cell = cell as? ButtonImageCell {
                if cell.image == selectedImage {
                    cell.isTapped = true
                } else {
                    cell.isTapped = false
                }
            }
        }
    }
}

// MARK: - Scroll View Delegate
extension ButtonImagePickerVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkSelectedBorder()
    }
}

// MARK: - Collection View Layout
extension ButtonImagePickerVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let wh  : CGFloat = (imageCollectionView.frame.width - 2 * 16 - 2 * 5) / 3
        
        return CGSize(width: wh, height: wh)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
}

extension UIViewController {
    func showButtonImagePickerVC(button: RemoteButton) {
        let vc = ButtonImagePickerVC()
        vc.button = button
        present(vc, animated: true, completion: nil)
    }
}
