//
//  StockTableViewCell.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 04.03.2021.
//

import UIKit

class StockTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var primaryFont = UIFont()
    var secondaryFont = UIFont()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if UIDevice().name == "iPhone 8" {
            primaryFont = UIFont(name: "Montserrat-Bold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
            secondaryFont = UIFont(name: "Montserrat-SemiBold", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .semibold)
        } else {
            primaryFont = UIFont(name: "Montserrat-Bold", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .bold)
            secondaryFont = UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
        
        tickerLabel.font = primaryFont
        companyLabel.font = secondaryFont
        priceLabel.font = primaryFont
        priceChangeLabel.font = secondaryFont
        
        logoImage.layer.cornerRadius = 18
//        tickerLabel.font = tickerLabel.font.withSize(14)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
