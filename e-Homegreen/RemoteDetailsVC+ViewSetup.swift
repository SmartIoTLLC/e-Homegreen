//
//  RemoteDetailsVC+ViewSetup.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 12/4/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import Foundation

// MARK: - Collection View Data Source
extension RemoteDetailsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return chunksOfButtons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chunksOfButtons[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = buttonsCollectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? ButtonCell {
            
            cell.button = chunksOfButtons[indexPath.section][indexPath.item]
            cell.tag = indexPath.item            
            
            return cell
        }
        return UICollectionViewCell()
    }
    
}

// MARK: - Collection View Delegate Flow Layout
extension RemoteDetailsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if sectionInsetsDict[section] != nil {
            return sectionInsetsDict[section]!
        } else {
            return sectionInsets
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let button = chunksOfButtons[indexPath.section][indexPath.item]
        let columns = CGFloat(remote.columns!)
        
        let width = ( buttonsCollectionView.frame.width - (2 * 8) - ((columns - 1) * 5) ) / columns
        let height = CGFloat(button.buttonHeight!) + 4
 
        return CGSize(width: width, height: height)
    }
    
}
