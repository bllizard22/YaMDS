//
//  DetailViewController.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 10.03.2021.
//

import UIKit

class DetailViewController: UIViewController {

	/// OPINION: странно что он optional, думаю лучше в инит
    var detailCard: StockTableCard?
    private var stockAPIData = StockAPIData()
    
    private let stringFormatter = NumberFormatter()
    private let currencyFormatter = NumberFormatter()
    private let sharesFormatter = NumberFormatter()
    
    private var isDataLoaded = false {
        didSet {
            view.isUserInteractionEnabled = isDataLoaded
            activityIndicator.isHidden = isDataLoaded
            if isDataLoaded {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
                activityIndicator.backgroundColor = UIColor(named: "BackgroundColor")
            }
        }
    }
    
    // MARK: - IBOutlets
    
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
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let ticker = detailCard?.ticker else { return }
        loadDetailViewData(ticker: ticker)
    }
    
    // MARK: - IBActions
    
    @IBAction func backButtonDidPressed(_ sender: UIButton) {
		/// FIXME: не лучший способ получать контроллер
        if let presenter = presentingViewController as? ViewController {
            if let key = detailCard?.ticker {
                presenter.stockCards[key] = detailCard
                presenter.saveCardsToCoreData()
                presenter.stockTableView.reloadData()
            }
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func likeButtonDidPressed(_ sender: UIButton) {
        
        if let presenter = presentingViewController as? ViewController {
            guard let key = detailCard?.ticker else { return }
            
            guard let isFavourite = detailCard?.isFavourite else { return }
            if isFavourite {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
                    UIView.transition(with: sender.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.starImage.image = UIImage(named: "StarGray")
                    }, completion: nil)
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 0.8, y: 0.8))!
                }
                UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseOut]) {
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 1.0, y: 1.0))!
                }
                detailCard?.isFavourite = false
                presenter.favourites.deleteTicker(withTicker: key)
            } else {
                UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn]) {
                    UIView.transition(with: sender.imageView!, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.starImage.image = UIImage(named: "StarGold")
                    }, completion: nil)
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 1.25, y: 1.25))!
                }
                UIView.animate(withDuration: 0.2, delay: 0.2, options: [.curveEaseOut]) {
                    self.starImage.transform = (sender.imageView?.transform.scaledBy(x: 1.0, y: 1.0))!
                }
                detailCard?.isFavourite = true
                presenter.favourites.saveTicker(withTicker: key)
            }
            presenter.stockCards[key] = detailCard
        }
        
    }
    
    // MARK: - Load Views in VC
    
    private func loadDetailViewBlank() {
		/// OPINION: не лучшее решение показываь так думаю, просто лоадера достаточно, а если не скачалось то ошибка и обратно на главную
        guard detailCard != nil else { return }
        tickerLabel.text = detailCard!.ticker
        companyNameLabel.text = detailCard!.name
        industryLabel.text = detailCard!.industry
        marketCapLabel.text = "0M"
        sharesLabel.text = "0M"
        peValueLabel.text = "0.00"
        psValueLabel.text = "0.00"
        ebitdaLabel.text = "0M"
        starImage.image = detailCard!.isFavourite ? UIImage(named: "StarGold") : UIImage(named: "StarGray")
        
        isDataLoaded = false
    }
    
    private func loadDetailViewFromCard() {
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
        
        starImage.image = detailCard!.isFavourite ? UIImage(named: "StarGold") : UIImage(named: "StarGray")
        summaryLabel.text = detailCard!.summary
        
        isDataLoaded = true
    }
    
    func loadDetailViewData(ticker: String) {
        if detailCard?.psValue != 0.0 || detailCard?.peValue != 0.0 {
            loadDetailViewFromCard()
        } else {
            loadDetailViewBlank()
            stockAPIData.loadMetricFromAPI(card: detailCard!) { (card, error) in
                if let error = error, card == nil {
                    DispatchQueue.main.async {
                        self.showAlert(request: error)
                        self.view.isUserInteractionEnabled = true
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.detailCard = card
                    self.loadDetailViewFromCard()
                }
            }
        }
    }
    
    // MARK: - Push AlertVC with error
    
    private func showAlert(request: AlertMessage) {
        let alert = AlertViewController().configureAlertVC(request: request)
        self.present(alert, animated: true, completion: nil)
    }
}
