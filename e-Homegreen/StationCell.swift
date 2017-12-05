//
//  StationCell.swift
//  e-Homegreen
//
//  Created by Vladimir Tuchek on 9/14/17.
//  Copyright © 2017 Teodor Stevic. All rights reserved.
//

import UIKit

class StationCell: UITableViewCell {
    
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var area: UILabel!
    @IBOutlet weak var city: UILabel!
    
    var station: Radio! {
        didSet {
            stationName.text = station.stationName
            genre.text       = station.genre
            area.text        = station.area
            city.text        = station.city
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateViews()
    }
    
    func updateViews() {
        backgroundColor       = .clear
        stationName.textColor = .white
        genre.textColor       = .white
        area.textColor        = .white
        city.textColor        = .white
        
        let bg = UIView()
        bg.backgroundColor     = UIColor.white.withAlphaComponent(0.4)
        selectedBackgroundView = bg
        
        stationName.font = .tahoma(size: 20)
        genre.font = .tahoma(size: 15)
        area.font = .tahoma(size: 13)
        city.font = .tahoma(size: 13)
    }

    
}
