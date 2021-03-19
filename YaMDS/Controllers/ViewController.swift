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

class ViewController: UIViewController {
    
    // Stock Data
    var dataStockMetric = Array<(String, Data)>()
    var stockCards = Dictionary<String, StockTableCard>() // Dict for all Cards
    var stockTickerList = Array<String>()   // List of tickers for Cards
    var favouriteIsSelected =  false {
        didSet {
            stockTableView.reloadData()
            searchBar(searchBar, textDidChange: searchBar.text ?? "")
        }
    }
    var favourites = Favourites()
    var modelCD = ModelCD()
    var stockData = StockData()
    
    // WebSockets
    @objc let priceSocket = PriceSocket()
    var priceObservation: NSKeyValueObservation?
    var tickerObservation: NSKeyValueObservation?
    var tickerKVO: String?
    
    // IBOutlets
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var stockTableView: StockTableView!
    @IBOutlet weak var cancelSearchButton: UIButton!
    
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
    var searchBarIsClicked = false {
        didSet {
            let image = searchBarIsClicked ? UIImage(named: "Back") : UIImage(named: "Search_24")
            cancelSearchButton.setImage(image, for: .normal)
        }
    }
    var isFiltering: Bool {
        return !searchBarIsEmpty
    }
    
    // MARK: - Load Actions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden = true
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
            loadCardsFromCoreData()
            cardsIsLoaded = true
//            loadPricesFromAPI()
            self.loadStocksInView()
            
            //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in

                saveCoreData()

                priceSocket.startWebSocket(tickerArray: stockTickerList)
            //}
        } else {
            print("First launch!")
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            loadCardsFromAPI()
            
            self.loadStocksInView()
            // TODO: - Add loading indicator/animation
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
                loadPricesFromAPI()
                favouriteIsSelected = false
                print(stockCards.count)
                
                cardsIsLoaded = true
                saveCoreData()
                
                priceSocket.startWebSocket(tickerArray: stockTickerList)
            }
        }
    }

    // Create TableView for Cards
    func loadStocksInView() {
        
        print("stockCards count at \(#line) = ",stockCards.count)
        stockTableView.dataSource = self
        stockTableView.delegate = self
        
        searchBar.delegate = self        
        searchBar.isHidden = false
    }
    
    func showAlert(request: AlertMessage) {
        let alert = UIAlertController(title: "Error", message: "Please, try reload app", preferredStyle: .alert)
        if request == .connection {
            alert.title = "No connection"
            alert.message = "Cannot connect to server.\nPlease check your WiFi/Cellular and tap \"Reload\""
            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
                    self.loadCardsFromAPI()
//                        self.loadPricesFromAPI()
                    
                }
            }))
        } else if request == .apiLimit {
            alert.title = "API Error"
            alert.message = "Out of API requests (1 min to reset limit). Try again?"
            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
                guard action.style == .default else { return }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+50) {
                        self.loadCardsFromAPI()
//                        self.loadPricesFromAPI()
                }
            }))
        } else {
            alert.title = "Error"
            alert.message = "Unknown error occured.\nPlease restart the app."
//            alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
//                guard action.style == .default else { return }
////                        self.loadCardsFromAPI()
////                        self.loadPricesFromAPI()
//            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            guard action.style == .cancel else { return }
            print("Cancel")
            self.stocksButton.isEnabled = false
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func likeButtonDidPressed(_ sender: UIButton) {
        let key = isFiltering ? filteredStockTickerList[sender.tag] : stockTickerList[sender.tag]
        
        let cardIsFav = stockCards[key]!.isFavourite
        if cardIsFav {
            UIView.animate(withDuration: 0.35, delay: 0.2, options: [.curveEaseInOut]) {
                UIView.transition(with: sender.imageView!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    sender.setImage(UIImage(named: "StarGray"), for: .normal)
                }, completion: nil)
                sender.imageView?.transform = (sender.imageView?.transform.scaledBy(x: 1.25, y: 1.25))!
            }
            favourites.deleteTicker(withTicker: key)
            stockCards[key]!.isFavourite = false
            print("\(key) did disliked")
        } else {
            UIView.animate(withDuration: 0.35, delay: 0.2, options: [.curveEaseInOut]) {
                UIView.transition(with: sender.imageView!, duration: 0.5, options: [.transitionCrossDissolve], animations: {
                    sender.setImage(UIImage(named: "StarGold"), for: .normal)
                }, completion: nil)
                sender.imageView?.transform = (sender.imageView?.transform.scaledBy(x: 0.8, y: 0.8))!
            }
            favourites.saveTicker(withTicker: key)
            stockCards[key]!.isFavourite = true
            print("\(key) did liked")
        }
        if favouriteIsSelected {
            stockTickerList = favourites.liked
            searchBar(searchBar, textDidChange: searchBar.text ?? "")
            stockTableView.reloadData()
        }
    }
    
    @IBAction func cancelSearchBarDidPressed(_ sender: UIButton) {
        searchBarIsClicked = false
        searchBar.resignFirstResponder()
    }
    
    @IBAction func stocksButtonDidPressed(_ sender: UIButton) {
        if !cardsIsLoaded { return }
        stockTickerList = StockList().stockList
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(20)
        favouriteButton.setTitleColor(UIColor(named: "SecondaryFontColor"), for: .normal)
        
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(32)
        stocksButton.setTitleColor(UIColor(named: "PrimaryFontColor"), for: .normal)
        
        favouriteIsSelected = false
    }
    
    @IBAction func favouriteButtonDidPressed(_ sender: UIButton) {
        if !cardsIsLoaded { return }
        stockTickerList = favourites.liked
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(32)
        favouriteButton.setTitleColor(UIColor(named: "PrimaryFontColor"), for: .normal)
        
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(20)
        stocksButton.setTitleColor(UIColor(named: "SecondaryFontColor"), for: .normal)

        favouriteIsSelected = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            if let indexPath = stockTableView.indexPathForSelectedRow {
                let key = isFiltering ? filteredStockTickerList[indexPath.row] : stockTickerList[indexPath.row]
                
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.detailCard = stockCards[key]
            }
        }
    }
    
    // MARK: - API load funcs
    
    // API request for company profile data
    func loadCardsFromAPI() {
        stockData.loadCardsFromAPI { (stockCards, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(request: error)
                }
                return
            }
            self.stockTickerList = Array(stockCards!.keys).sorted()
            self.stockCards = stockCards!
            DispatchQueue.main.async {
                self.stockTableView.reloadData()
            }
        }
    }
    
    // API request for prices data of Cards
    func loadPricesFromAPI() {
        stockData.loadPricesFromAPI { (stockCards, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(request: error)
                }
                return
            }
            self.stockTickerList = Array(stockCards!.keys).sorted()
            self.stockCards = stockCards!
            DispatchQueue.main.async {
                self.stockTableView.reloadData()
            }
        }
    }
    
    // MARK: - CoreData Load Cards
    
    // Reload data from CoreData
    func loadCardsFromCoreData() {
        stockCards = modelCD.loadCardsFromCoreData()
        stockTickerList = StockList().stockList
    }
    
    // Save all cards to CoreData as dictionary
    func saveCoreData() {
        print("\n\n\nSaved!\n\n\n")
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
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "stockCell",
                                                 for: indexPath as IndexPath) as! StockTableViewCell
        let key = isFiltering ? filteredStockTickerList[indexPath.row] : stockTickerList[indexPath.row]
        
        if stockCards[key] != nil {
            cell = stockTableView.loadCardIntoTableViewCell(card: stockCards[key]!, cell: cell)
        }
        
        // TODO: -
        cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "EvenCell") : .white
        if (indexPath.row % 2 == 0) {
            cell.contentView.backgroundColor = UIColor(named: "EvenCell")
        } else {
            cell.contentView.backgroundColor = UIColor(named: "BackgroundColor")
        }
        stockTableView.rowHeight = cell.rawHeight
        cell.layer.cornerRadius = 24

        //TODO: - Replace with single func
        if favourites.contains(ticker: key) {
            cell.favouriteButton.setImage(UIImage(named: "StarGold"), for: .normal)
            stockCards[key]!.isFavourite = true
        } else {
            cell.favouriteButton.setImage(UIImage(named: "StarGray"), for: .normal)
            stockCards[key]!.isFavourite = false
        }
        cell.favouriteButton.tag = indexPath.row
        
        return cell
    }
    
//    func swapLikeOnCard()
    
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
        let summary = mboum.getCompanySummary(company: ticker)
        
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
        let list = favouriteIsSelected ? favourites.liked : stockTickerList
        filteredStockTickerList = list.filter({ (ticker: String) -> Bool in
            let card = stockCards[ticker]?.name
            let result = ticker.lowercased().contains(searchText.lowercased()) || card!.lowercased().contains(searchText.lowercased())
            return result
        })
        
        stockTableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBarIsClicked = true
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBarIsClicked = false
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
//        let searchBarHeight = searchBar.frame.height
//        if scrollView.contentOffset.y > 50 {
//            view.layoutIfNeeded()
//            //headerViewHeightConstraint.constant = -100
////            headerViewHeight = -100
//            if self.view.frame.origin.y == 0 {
//                self.view.frame.origin.y -= searchBarHeight
//            }
//            UIView.animate(withDuration: 1.0, delay: 0, options: [.allowUserInteraction], animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//            searchBar.isHidden = true
//
//        } else {
//            // Return header
//            view.layoutIfNeeded()
//            // Initial header view height
////            headerViewHeight = 0
//            self.view.frame.origin.y = 0
//            UIView.animate(withDuration: 1.0, delay: 0, options: [.allowUserInteraction], animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
//            searchBar.isHidden = false
//        }
//    }
//}
