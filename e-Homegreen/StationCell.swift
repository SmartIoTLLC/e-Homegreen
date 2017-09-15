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
            genre.text = station.genre
            area.text = station.area
            city.text = station.city
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateViews()
    }
    
    func updateViews() {
        backgroundColor = .clear
        stationName.textColor = UIColor.white
        genre.textColor = UIColor.white
        area.textColor = UIColor.white
        city.textColor = UIColor.white
        let bg = UIView()
        bg.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        selectedBackgroundView = bg
        
        stationName.font = UIFont(name: "Tahoma", size: 20)
        genre.font = UIFont(name: "Tahoma", size: 17)
        area.font = UIFont(name: "Tahoma", size: 13)
        city.font = UIFont(name: "Tahoma", size: 13)
    }

    
}
