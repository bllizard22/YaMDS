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
    let priceFormatter = NumberFormatter()
    let priceChangeFormatter = NumberFormatter()
    var rawHeight = CGFloat()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceFormatter.numberStyle = .currency
        priceFormatter.locale = Locale(identifier: "en_US")
        priceFormatter.minimumIntegerDigits = 1
        priceFormatter.minimumFractionDigits = 2
        priceFormatter.maximumFractionDigits = 2
        priceChangeFormatter.numberStyle = .percent
        priceChangeFormatter.minimumIntegerDigits = 1
        priceChangeFormatter.minimumFractionDigits = 2
        priceChangeFormatter.maximumFractionDigits = 2
        
        let screenWidth = UIScreen.main.bounds.width
        print(screenWidth)
        //if UIDevice().name == "iPhone 8" {
        if screenWidth <= 375 {
            primaryFont = UIFont(name: "Montserrat-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
            secondaryFont = UIFont(name: "Montserrat-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
            rawHeight = 96
        } else {
            primaryFont = UIFont(name: "Montserrat-Bold", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .bold)
            secondaryFont = UIFont(name: "Montserrat-SemiBold", size: 14) ?? UIFont.systemFont(ofSize: 14, weight: .semibold)
            rawHeight = 110
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
