//
//  PCControlViewController.swift
//  e-Homegreen
//
//  Created by Vladimir Zivanov on 3/9/16.
//  Copyright © 2016 Teodor Stevic. All rights reserved.
//

import UIKit

class PCControlViewController: CommonViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionViewCellSize = CGSize(width: 150, height: 180)
    private var sectionInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
    
    @IBOutlet weak var pccontrolCollectionView: UICollectionView!
    var pcs:[Device] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        pcs = CoreDataController().fetchPCController("", parentZone: 1, zone: 1, category: 1)
        pccontrolCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pccontrolCell", forIndexPath: indexPath) as? PCControlCell{
            cell.setItem(pcs[indexPath.row], tag: indexPath.row)
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("collectionCell", forIndexPath: indexPath)
        return cell
    }
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pcs.count
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return collectionViewCellSize
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        showPCInterface(pcs[indexPath.row])
    }
    
    @IBAction func changeSliderValue(sender: AnyObject) {
        guard let slider = sender as? UISlider else {
            return
        }
        guard let tag = sender.tag else {
            return
        }
        let address = [Byte(Int(pcs[tag].gateway.addressOne)), Byte(Int(pcs[tag].gateway.addressTwo)), Byte(Int(pcs[tag].address))]
        let value = Byte(Int(slider.value * 100))
        if value == 0x00 {
            SendingHandler.sendCommand(byteArray: Function.setPCVolume(address, volume: pcs[tag].pcVolume, mute: 0x01), gateway: pcs[tag].gateway)
        } else {
            SendingHandler.sendCommand(byteArray: Function.setPCVolume(address, volume: value), gateway: pcs[tag].gateway)
            pcs[tag].pcVolume = value
        }
    }

}
