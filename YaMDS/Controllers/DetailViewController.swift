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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tickerLabel.text = detailCard!.ticker
        companyNameLabel.text = detailCard!.name
        industryLabel.text = detailCard!.industry
        marketCapLabel.text = String(detailCard!.marketCap)
        sharesLabel.text = String(detailCard!.sharesOutstanding)
        peValueLabel.text = String(detailCard!.peValue)
        psValueLabel.text = String(detailCard!.psValue)
        ebitdaLabel.text = String(detailCard!.ebitda)
        
        summaryLabel.text = detailCard!.summary
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonDidPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}
