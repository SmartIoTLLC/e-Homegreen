//
//  SequencesViewController.swift
//  e-Homegreen
//
//  Created by Teodor Stevic on 6/24/15.
//  Copyright (c) 2015 Teodor Stevic. All rights reserved.
//

import UIKit
import CoreData

class SequencesViewController: CommonViewController, UITextFieldDelegate {

    @IBOutlet weak var sequenceCollectionView: UICollectionView!
    @IBOutlet weak var broadcastSwitch: UISwitch!
    @IBOutlet weak var cyclesTextField: UITextField!
    
    var appDel:AppDelegate!
    var sequences:[Sequence] = []
    var error:NSError? = nil
    
    private var sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    private let reuseIdentifier = "SequenceCell"
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cyclesTextField.delegate = self
        
        if self.view.frame.size.width == 414 || self.view.frame.size.height == 414 {
            collectionViewCellSize = CGSize(width: 128, height: 156)
        }else if self.view.frame.size.width == 375 || self.view.frame.size.height == 375 {
            collectionViewCellSize = CGSize(width: 118, height: 144)
        }

        appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        updateSequencesList()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshSequenceList", name: "refreshSequenceListNotification", object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight {
            if self.view.frame.size.width == 568{
                sectionInsets = UIEdgeInsets(top: 5, left: 25, bottom: 5, right: 25)
            }else if self.view.frame.size.width == 667{
                sectionInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
            }
        }else{
            if self.view.frame.size.width == 320{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }else if self.view.frame.size.width == 375{
                sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }else{
                sectionInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func refreshSequenceList () {
        updateSequencesList()
        sequenceCollectionView.reloadData()
    }
    func updateSequencesList () {
        var fetchRequest = NSFetchRequest(entityName: "Sequence")
        var sortDescriptorOne = NSSortDescriptor(key: "gateway.name", ascending: true)
        var sortDescriptorTwo = NSSortDescriptor(key: "sequenceId", ascending: true)
        var sortDescriptorThree = NSSortDescriptor(key: "sequenceName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorOne, sortDescriptorTwo, sortDescriptorThree]
        let predicate = NSPredicate(format: "gateway.turnedOn == %@", NSNumber(bool: true))
        fetchRequest.predicate = predicate
        let fetResults = appDel.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? [Sequence]
        if let results = fetResults {
            sequences = results
        } else {
            
        }
    }
    func saveChanges() {
        if !appDel.managedObjectContext!.save(&error) {
            println("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
    }
}

extension SequencesViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var address:[UInt8] = []
        if broadcastSwitch.on {
            address = [0xFF, 0xFF, 0xFF]
        } else {
            address = [UInt8(Int(sequences[indexPath.row].gateway.addressOne)), UInt8(Int(sequences[indexPath.row].gateway.addressTwo)), UInt8(Int(sequences[indexPath.row].address))]
        }
        if let cycles = cyclesTextField.text.toInt() {
            if cycles >= 0 && cycles <= 255 {
                SendingHandler(byteArray: Function.setSequence(address, id: Int(sequences[indexPath.row].sequenceId), cycle: UInt8(cycles)), gateway: sequences[indexPath.row].gateway)
            }
        } else {
            SendingHandler(byteArray: Function.setSequence(address, id: Int(sequences[indexPath.row].sequenceId), cycle: 0x00), gateway: sequences[indexPath.row].gateway)
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        
        return collectionViewCellSize
        
    }
}

extension SequencesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sequences.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SequenceCollectionViewCell
        //2
        //        let flickrPhoto = photoForIndexPath(indexPath)
        var gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, 150, 150)
        gradient.colors = [UIColor(red: 13/255, green: 76/255, blue: 102/255, alpha: 1.0).colorWithAlphaComponent(0.95).CGColor, UIColor(red: 82/255, green: 181/255, blue: 219/255, alpha: 1.0).colorWithAlphaComponent(1.0).CGColor]
        cell.layer.insertSublayer(gradient, atIndex: 0)
        //        cell.backgroundColor = UIColor.lightGrayColor()
        //3
        cell.sequenceTitle.text = "\(sequences[indexPath.row].sequenceName)"
        if let sceneImage = UIImage(data: sequences[indexPath.row].sequenceImageOne) {
            cell.sequenceImageView.image = sceneImage
        }
//        if let sceneImage = UIImage(data: scenes[indexPath.row].sceneImage) {
//            cell.sceneCellImageView.image = sceneImage
//        }
        //        cell.sceneCellLabel.image = "\()"
        cell.layer.cornerRadius = 5
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}


class SequenceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sequenceTitle: UILabel!
    @IBOutlet weak var sequenceImageView: UIImageView!
    @IBOutlet weak var sequenceButton: UIButton!
    
    
}