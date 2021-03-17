//
//  ViewController.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 03.03.2021.
//

import UIKit
import Foundation
import CoreData
import Kingfisher

//struct quoteData: Decodable {
//    let ask: Int
////    let symbol: String
////    let shortName: String
////    let postMarketPrice: Int
//}

class ViewController: UIViewController {
    
    // Stock Data
    var dataStockInfo = Array<Data>()
    var dataStockPrice = Array<(String, Data)>()
    var dataStockMetric = Array<(String, Data)>()
    var stockCards = Dictionary<String, StockTableCard>()   // Dict for all Cards
    var stockTickerList = Array<String>()   // List of tickers for Cards
    var favouriteIsSelected =  false
    var favourites = Favourites()
    var modelCD = ModelCD()
    
    // WebSockets
    @objc let priceSocket = PriceSocket()
    var priceObservation: NSKeyValueObservation?
    var tickerObservation: NSKeyValueObservation?
    var tickerKVO: String?
    
    // IBOutlets
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var stockTableView: UITableView!
    var cardsIsLoaded = false
    var headerViewHeight = 0
    var rowHeight = 0
    
    // SearchController
    var filteredStockTickerList = Array<String>()
    var searchBarIsEmpty: Bool {
        guard let text = searchBar.text else {
            return false
        }
        return text.isEmpty
    }
    var searchBarIsClicked = false
    var isFiltering: Bool {
        return !searchBarIsEmpty
//        return searchBarIsClicked && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults()
        
        priceObservation = observe(\ViewController.priceSocket.currentPrice, options: [.new], changeHandler: { (vc, change) in
            guard let updatedPrice = change.newValue else { return }
            print("New price \(updatedPrice)")
            self.stockCards[self.tickerKVO!]?.currentPrice = Float(updatedPrice)
            self.stockTableView.reloadData()
//            self.priceLabel.text = "\(self.tickerKVO!) \(String(updatedPrice))"
        })
        tickerObservation = observe(\ViewController.priceSocket.currentTicker, options: [.new], changeHandler: { (vc, change) in
            guard let updatedTicker = change.newValue as? String else { return }
            print("New ticker \(updatedTicker)")
            self.tickerKVO = updatedTicker
        })
        
        if defaults.bool(forKey: "isAppAlreadyLaunchedOnce") {
            print("Launched not first time")
            defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
            print(defaults.bool(forKey: "isAppAlreadyLaunchedOnce"))
            loadCardsFromCoreData()
            cardsIsLoaded = true
            
            loadPricesFromAPI()
            self.loadStocksInView()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
                if dataStockInfo.count > 0, dataStockInfo[0].count == 0 {
                    dataStockInfo.removeFirst()
                }
                parsePricesDataJSON()
                saveCoreData()

//                priceSocket.startWebSocket(tickerArray: ["AAPL", "TSLA", "YNDX"]) //"BINANCE:BTCUSDT"
//                priceSocket.startWebSocket(tickerArray: stockTickerList)
            }
        } else {
            loadCardsFromAPI()
            print("First launch!")
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            
            loadPricesFromAPI()
            
            // TODO: - Add loading indicator/animation
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
                if dataStockInfo.count > 0, dataStockInfo[0].count == 0 {
                    dataStockInfo.removeFirst()
                }
                parseCardsDataJSON()
                parsePricesDataJSON()
                self.loadStocksInView()
                saveCoreData()
                cardsIsLoaded = true
                
//                priceSocket.createConnection()
                priceSocket.startWebSocket(tickerArray: stockTickerList) //"BINANCE:BTCUSDT"
            }
        }
    }

    // Create TableView for Cards
    func loadStocksInView() {
        
        // TODO: - Constraint to anchors instead of height
        stockTableView = UITableView(frame: CGRect(x: 12, y: 200,
                                                   width: view.bounds.width-12*2, height: view.bounds.height-200))
//        stockTableView.rowHeight = 96
        stockTableView.separatorStyle = .none
        stockTableView.register(UINib(nibName: "StockCell", bundle: nil), forCellReuseIdentifier: "stockCell")
        stockTableView.dataSource = self
        stockTableView.delegate = self
        view.addSubview(stockTableView)
        
        searchBar.delegate = self
    }
    
    // MARK: - IBActions
    
    @IBAction func likeButtonDidPressed(_ sender: UIButton) {
//        let key = stockCardsList[sender.tag]
        var key: String
        if isFiltering {
            key = filteredStockTickerList[sender.tag]
        } else {
            key = stockTickerList[sender.tag]
        }
        
        let cardIsFav = stockCards[key]!.isFavourite
        if cardIsFav {
            sender.setImage(UIImage(named: "StarGray"), for: .normal)
//            UIView.animate(withDuration: 2.0, delay: 2.0, options: [.allowUserInteraction], animations: {
//                sender.layoutIfNeeded()
//            }, completion: nil)
            favourites.deleteTicker(withTicker: key)
            stockCards[key]!.isFavourite = false
            print("\(key) did disliked")
        } else {
            sender.setImage(UIImage(named: "StarGold"), for: .normal)
            favourites.saveTicker(withTicker: key)
            stockCards[key]!.isFavourite = true
            print("\(key) did liked")
        }
        if favouriteIsSelected {
            stockTickerList = favourites.liked
            stockTableView.reloadData()
        }
    }
    
    @IBAction func stocksButtonDidPressed(_ sender: UIButton) {
        if !cardsIsLoaded { return }
        stockTickerList = StockList().stockList
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(20)
        favouriteButton.setTitleColor(.systemGray2, for: .normal)
        
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(32)
        stocksButton.setTitleColor(.black, for: .normal)
        
        favouriteIsSelected = false
        
        stockTableView.reloadData()
    }
    
    @IBAction func favouriteButtonDidPressed(_ sender: UIButton) {
        if !cardsIsLoaded { return }
        stockTickerList = favourites.liked
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(32)
        favouriteButton.setTitleColor(.black, for: .normal)
        
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(20)
        stocksButton.setTitleColor(.systemGray2, for: .normal)

        favouriteIsSelected = true
                
        stockTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            if let indexPath = stockTableView.indexPathForSelectedRow {
                let key = isFiltering ? filteredStockTickerList[indexPath.row] : stockTickerList[indexPath.row]
//                if isFiltering {
//                    key = filteredStockTickerList[indexPath.row]
//                } else {
//                    key = stockTickerList[indexPath.row]
//                }
                
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.detailCard = stockCards[key]
            }
        }
    }
    
    // MARK: - API load funcs
    
    // API request for company profile data
    func loadCardsFromAPI() {
        let stockData = StockData()
        for company in StockList().stockList {
            stockData.getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dataStockInfo.append(dataIn)
            }
        }
    }
    
    // API request for prices data of Cards
    func loadPricesFromAPI() {
        let stockData = StockData()
        for company in StockList().stockList {
            stockData.getPrice(stockSymbol: company) { (company, dataIn) in
                self.dataStockPrice.append((company, dataIn))
            }
        }
        print("loaded prices")
    }
    
    func parseCardsDataJSON () {
        print(dataStockInfo.count)
        print("data for JSON", dataStockInfo)
//        var json: [String: Any]
        for data in dataStockInfo {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                print(json)
                var stringLogoURL = json["logo"] as? String
                if stringLogoURL == "" {
                    stringLogoURL = "https://finnhub.io/api/logo?symbol=AAPL"
                }
                let card = StockTableCard(name: json["name"] as! String,
                                          logo: (URL.init(string: stringLogoURL!)!),
                                          ticker: json["ticker"] as! String,
                                          industry: json["finnhubIndustry"] as! String,
                                          marketCap: Float(truncating: json["marketCapitalization"] as! NSNumber),
                                          sharesOutstanding: Float(truncating: json["shareOutstanding"] as! NSNumber),
                                          peValue: 0.0,
                                          psValue: 0.0,
                                          ebitda: 0.0,
                                          summary: "---",
                                          currentPrice: 0.0,
                                          previousClosePrice: 0.0,
                                          isFavourite: false)
                stockCards[card.ticker] = card
                stockTickerList.append(card.ticker)
            } catch let error {
                print(error)
            }
        }
    }
    
    func parsePricesDataJSON () {
        print(dataStockInfo.count)
        print("data for JSON", dataStockInfo)
        for (key, data) in dataStockPrice {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                print(key, json)
                stockCards[key]?.currentPrice = Float(truncating: json["c"] as! NSNumber)
                stockCards[key]?.previousClosePrice = Float(truncating: json["pc"] as! NSNumber)
            } catch let error {
                print(error)
            }
        }
    }
    
    // MARK: - CoreData Load Cards
    
    // Reload data from CoreData
    private func loadCardsFromCoreData() {
        stockCards = modelCD.loadCardsFromCoreData()
//        print(stockCards.count)
//        print(stockCards)
        stockTickerList = StockList().stockList
    }
    
    // Save all cards to CoreData as dictionary
    private func saveCoreData() {
//        print("Saving Cards to CoreData")
        modelCD.saveCoreData(cards: stockCards)
    }
}

// MARK: - TableView extension

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredStockTickerList.count
        }
        return stockTickerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell",
                                                 for: indexPath as IndexPath) as! StockTableViewCell
        var key: String
        if isFiltering {
            key = filteredStockTickerList[indexPath.row]
        } else {
            key = stockTickerList[indexPath.row]
        }
        
        cell.companyLabel.text = stockCards[key]!.name
        cell.tickerLabel.text = stockCards[key]!.ticker
//        cell.priceLabel.text = "$" + String(stockCards[key]!.currentPrice)
        let price = NSNumber(value: stockCards[key]!.currentPrice)
        cell.priceLabel.text = cell.priceFormatter.string(from: price)
        let (priceChange, isPositive) = StockData().calcPriceChange(card: stockCards[key]!)
        cell.priceChangeLabel.text = priceChange
        cell.priceChangeLabel.textColor = isPositive ? UIColor(named: "PriceGreen") : UIColor(named: "PriceRed")

        let resource = ImageResource(downloadURL: stockCards[key]!.logo)
        cell.logoImage.kf.setImage(with: resource) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(_):
                print("fail")
            }
        }
        
        print("cell with \(stockCards[key]!.ticker) is at \(indexPath.row)")
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(named: "EvenCell")
        } else {
            cell.backgroundColor = .white
        }
        stockTableView.rowHeight = cell.rawHeight
        cell.layer.cornerRadius = 24
        
        //TODO: - Replace with single func
        if favourites.contains(ticker: key) {
            cell.favouriteButton.setImage(UIImage(named: "StarGold"), for: .normal)
            stockCards[key]!.isFavourite = true
//            print("\(key) is liked")
        } else {
            cell.favouriteButton.setImage(UIImage(named: "StarGray"), for: .normal)
            stockCards[key]!.isFavourite = false
//            print("\(key) is not liked")
        }
        cell.favouriteButton.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        let ticker = stockTickerList[indexPath.row]
        loadDetailViewData(ticker: ticker)
    }
    
    func loadDetailViewData(ticker: String) {
        StockData().getMetric(stockSymbol: ticker) { (company, dataIn) in
            self.dataStockMetric.append((company, dataIn))
        }
        let mboum = MBOUMStockData()
        let summary = mboum.getCompanySummary(company: "AAPL")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) { [self] in
            for (key, data) in dataStockMetric {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                    print(key, json)
                    let metric = json["metric"] as! Dictionary<String, Any>
                    stockCards[key]?.peValue = Float(truncating: metric["peNormalizedAnnual"] as! NSNumber)
                    stockCards[key]?.psValue = Float(truncating: metric["psTTM"] as! NSNumber)
                    stockCards[key]?.ebitda = Float(truncating: metric["ebitdPerShareTTM"] as! NSNumber)
                } catch let error {
                    print(error)
                }
            }
            stockCards[ticker]?.summary = summary
            performSegue(withIdentifier: "showDetailView", sender: nil)
        }
    }
}


// MARK: - SearchBar Delegate

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var list: Array<String>
        if favouriteIsSelected {
            list = favourites.liked
        } else {
            list = stockTickerList
        }
        filteredStockTickerList = list.filter({ (ticker: String) -> Bool in
            let card = stockCards[ticker]?.name
            let result = ticker.lowercased().contains(searchText.lowercased()) || card!.lowercased().contains(searchText.lowercased())
            return result
        })
        
        stockTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Animate Button

//extension ViewController {
//    func showAnimation(_ completionBlock: @escaping () -> Void) {
////        self.isUserInteractionEnabled = false
//        UIView.animate(withDuration: 0.1,
//                       delay: 0,
//                       options: .curveLinear,
//                       animations: { [weak self] in
//                        self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
//                       }) {  (done) in
//            UIView.animate(withDuration: 0.1,
//                           delay: 0,
//                           options: .curveLinear,
//                           animations: { [weak self] in
//                            self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//                           }) { [weak self] (_) in
////                self?.isUserInteractionEnabled = true
//                completionBlock()
//            }
//       }
//    }
//}

// MARK: - Hide SearchBar onScroll

//extension ViewController {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // Value when headerview will hide
//        if scrollView.contentOffset.y > 50 {
//            view.layoutIfNeeded()
//            //headerViewHeightConstraint.constant = -100
//            headerViewHeight = -100
//            if self.view.frame.origin.y == 0 {
//                self.view.frame.origin.y -= 100
//            }
//            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//            searchBar.isHidden = true
//
//        }else {
//            // Return header
//            view.layoutIfNeeded()
//            // Initial header view height
//            headerViewHeight = 0
//            self.view.frame.origin.y = 0
//            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction], animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//            searchBar.isHidden = false
//        }
//    }
//}
