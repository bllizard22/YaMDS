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

    func configureTableView() {
        self.separatorStyle = .none
        self.register(UINib(nibName: "StockCell", bundle: nil), forCellReuseIdentifier: "stockCell")
    }
    
    func autolayoutWidth() {
        for constraint in self.constraints {
            if constraint.identifier == "leadingTableConstraint" {
               constraint.constant = 20
            }
            if constraint.identifier == "trailingTableConstraint" {
               constraint.constant = 20
            }
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

        let resource = ImageResource(downloadURL: card.logo)
        cell.logoImage.kf.setImage(with: resource) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(_):
                print("Failed to load company logo")
            }
        }
        
        return cell
    }
}
