//
//  StockTableView.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 04.03.2021.
//

import UIKit
import Kingfisher

class StockTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configureTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTableView()
    }

    private func configureTableView() {
        self.separatorStyle = .none
        self.register(UINib(nibName: "StockCell", bundle: nil), forCellReuseIdentifier: "stockCell")
    }
    
    func autolayoutWidth(forView view: UIView) {
        let screenWidth = UIScreen.main.bounds.width
        if screenWidth <= 375 {
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        } else {
            self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
            self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -24).isActive = true
        }
        self.layoutIfNeeded()
    }
    
    func loadCardIntoTableViewCell(card: StockTableCard, cell: StockTableViewCell) -> StockTableViewCell {
        
        cell.companyLabel.text = card.name
        cell.tickerLabel.text = card.ticker
        let price = NSNumber(value: card.currentPrice)
        cell.priceLabel.text = cell.priceFormatter.string(from: price)
        let (priceChange, isPositive) = StockAPIData().calcPriceChange(card: card)
        cell.priceChangeLabel.text = priceChange
        cell.priceChangeLabel.textColor = isPositive ? UIColor(named: "PriceGreen") : UIColor(named: "PriceRed")

        if let logo = card.logo, logo.absoluteString != ""{
            let resource = ImageResource(downloadURL: logo)
            cell.logoImage.kf.setImage(with: resource) { (result) in
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    print("Failed to load company logo")
                }
            }
        } else {
            let logoURL = URL(string: "https://logo.uplead.com/" + card.weburl)!
            print(logoURL)
            let resource = ImageResource(downloadURL: logoURL)
            cell.logoImage.kf.setImage(with: resource) { (result) in
                switch result {
                case .success(_):
                    break
                case .failure(_):
                    print("Failed to load company logo")
                }
            }
        }
//        }
        
        return cell
    }
}
