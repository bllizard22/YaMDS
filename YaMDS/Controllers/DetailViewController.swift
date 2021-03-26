//
//  DetailViewController.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 10.03.2021.
//

import UIKit

class DetailViewController: UIViewController {

    var detailCard: StockTableCard?
    var stockAPIData = StockAPIData()
    
    let stringFormatter = NumberFormatter()
    let currencyFormatter = NumberFormatter()
    let sharesFormatter = NumberFormatter()
    
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
        
//        loadDetailView()
        guard let ticker = detailCard?.ticker else { return }
        loadDetailViewData(ticker: ticker)
    }
    
    @IBAction func backButtonDidPressed(_ sender: UIButton) {
        if let presenter = presentingViewController as? ViewController {
            presenter.stockTableView.reloadData()
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func likeButtonDidPressed(_ sender: UIButton) {
        
        if let presenter = presentingViewController as? ViewController {
            guard let key = detailCard?.ticker else { return }
            
            guard let isFavourite = detailCard?.isFavourite else { return }
            if isFavourite {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn]) {
                    UIView.transition(with: sender.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.starImage.image = UIImage(named: "StarGray")
                    }, completion: nil)
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 1.25, y: 1.25))!
                }
                UIView.animate(withDuration: 0.25, delay: 0.3, options: [.curveEaseOut]) {
                    UIView.transition(with: sender.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    }, completion: nil)
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 0.8, y: 0.8))!
                }
                detailCard?.isFavourite = false
                presenter.favourites.deleteTicker(withTicker: key)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) {
                    UIView.transition(with: sender.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.starImage.image = UIImage(named: "StarGold")
                    }, completion: nil)
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 1.2, y: 1.2))!
                }
                UIView.animate(withDuration: 0.25, delay: 0.3, options: [.curveEaseOut]) {
                    UIView.transition(with: sender.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    }, completion: nil)
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 0.8, y: 0.8))!
                }
                detailCard?.isFavourite = true
                presenter.favourites.saveTicker(withTicker: key)
            }
            print(presenter.stockCards[key]!)
            presenter.stockCards[key] = detailCard
            print(presenter.stockCards[key]!)
        }
        
    }
    
    func loadDetailView() {
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale(identifier: "en_US")
        currencyFormatter.minimumIntegerDigits = 1
        currencyFormatter.minimumFractionDigits = 0
        currencyFormatter.maximumFractionDigits = 0
        
        stringFormatter.numberStyle = .decimal
        stringFormatter.minimumIntegerDigits = 1
        stringFormatter.minimumFractionDigits = 2
        stringFormatter.maximumFractionDigits = 2
        
        sharesFormatter.numberStyle = .decimal
        sharesFormatter.minimumIntegerDigits = 1
        sharesFormatter.minimumFractionDigits = 0
        sharesFormatter.maximumFractionDigits = 0
        
        guard detailCard != nil else { return }
        tickerLabel.text = detailCard!.ticker
        companyNameLabel.text = detailCard!.name
        industryLabel.text = detailCard!.industry
        marketCapLabel.text = currencyFormatter.string(from: NSNumber(value: detailCard!.marketCap))! + "M"
        sharesLabel.text = sharesFormatter.string(from: NSNumber(value: detailCard!.sharesOutstanding))! + "M"
        peValueLabel.text = stringFormatter.string(from: NSNumber(value: detailCard!.peValue))
        psValueLabel.text = stringFormatter.string(from: NSNumber(value: detailCard!.psValue))
        
        let ebitda = detailCard!.ebitda * detailCard!.sharesOutstanding
        ebitdaLabel.text = currencyFormatter.string(from: NSNumber(value: ebitda))! + "M"
        
        print(detailCard!.isFavourite)
        starImage.image = detailCard!.isFavourite ? UIImage(named: "StarGold") : UIImage(named: "StarGray")
        
        summaryLabel.text = detailCard!.summary
    }
    
    func loadDetailViewData(ticker: String) {
        stockAPIData.loadMetricFromAPI(ticker: ticker) { (card, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(request: error)
                }
                return
            }
//            self.detailCard?.summary = card!.summary
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            self.loadDetailView()
        }
    }
    
    func showAlert(request: AlertMessage) {
        let alert = UIAlertController(title: "Error", message: "Please, try reload app", preferredStyle: .alert)
        if request == .connection {
            alert.title = "No connection"
            alert.message = "Cannot connect to server.\nPlease check your Internet\nand tap \"Reload\""
            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                self.loadDetailViewData(ticker: self.detailCard!.ticker)
            }))
        } else if request == .apiLimit {
            alert.title = "API Error"
            alert.message = "Too many API requests\n(~2 min to reset limit).\nPlease try later."
            alert.addAction(UIAlertAction(title: "Go Back", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                if let presenter = self.presentingViewController as? ViewController {
                    presenter.stockTableView.reloadData()
                    self.dismiss(animated: true, completion: nil)
                }
            }))
        } else {
            alert.title = "Error"
            alert.message = "Unknown error occured.\nPlease restart the app."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            guard action.style == .cancel else { return }
            print("Cancel")
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
