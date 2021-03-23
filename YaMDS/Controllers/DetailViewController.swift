//
//  DetailViewController.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 10.03.2021.
//

import UIKit

class DetailViewController: UIViewController {

    var detailCard: StockTableCard?
    
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var industryLabel: UILabel!
    
    @IBOutlet weak var marketCapLabel: UILabel!
    
    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var peValueLabel: UILabel!
    @IBOutlet weak var psValueLabel: UILabel!
    @IBOutlet weak var ebitdaLabel: UILabel!
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var starImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard detailCard != nil else { return }
        tickerLabel.text = detailCard!.ticker
        companyNameLabel.text = detailCard!.name
        industryLabel.text = detailCard!.industry
        marketCapLabel.text = String(detailCard!.marketCap)
        sharesLabel.text = String(detailCard!.sharesOutstanding)
        peValueLabel.text = String(detailCard!.peValue)
        psValueLabel.text = String(detailCard!.psValue)
        ebitdaLabel.text = String(detailCard!.ebitda)
        starImage.image = detailCard!.isFavourite ? UIImage(named: "StarGold") : UIImage(named: "StarGray")
        
        summaryLabel.text = detailCard!.summary
    }
    
    @IBAction func backButtonDidPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func likeButtonDidPressed(_ sender: UIButton) {
        
        if let presenter = presentingViewController as? ViewController {
            guard let key = detailCard?.ticker else { return }
            print(presenter.stockCards[key]!)
            presenter.stockCards[key] = detailCard
            print(presenter.stockCards[key]!)
            
            guard let isFavourite = detailCard?.isFavourite else { return }
            if isFavourite {
                starImage.image = UIImage(named: "StarGray")
                detailCard?.isFavourite = false
                presenter.favourites.deleteTicker(withTicker: key)
            } else {
                starImage.image = UIImage(named: "StarGold")
                detailCard?.isFavourite = true
                presenter.favourites.saveTicker(withTicker: key)
            }
        }
        
    }
}
