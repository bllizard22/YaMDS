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
import SwiftyJSON

class ViewController: UIViewController {
    
    // Stock Data
    var stockCards = Dictionary<String, StockTableCard>() // Dict for all Cards
    var stockTickerList = Array<String>()   // List of tickers for Cards
    var favouriteIsSelected =  false {
        didSet {
            stockTableView.reloadData()
            searchBar(searchBar, textDidChange: searchBar.text ?? "")
        }
    }
    
    // Data Models
    var favourites = Favourites()
    var modelCoreData = ModelCD()
    var stockAPIData = StockAPIData()
        
    // WebSockets
    @objc let priceSocket = PriceSocket()
    var priceObservation: NSKeyValueObservation?
    var tickerObservation: NSKeyValueObservation?
    var tickerKVO: String?
    
    // IBOutlets
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var cancelSearchButton: UIButton!
    @IBOutlet weak var stockTableView: StockTableView!
    
    var cardsIsLoaded = false
    var indexPathForLastSelectedRow: IndexPath?
    
    // SearchController
    var filteredStockTickerList = Array<String>()
    var isFiltering: Bool {
        guard let text = searchBar.text else { return false }
        return !text.isEmpty
    }
    var searchBarIsClicked = false {
        didSet {
            let image = searchBarIsClicked ? UIImage(named: "Back") : UIImage(named: "Search_24")
            cancelSearchButton.setImage(image, for: .normal)
        }
    }
    
    // MARK: - View Load Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden = true
        let defaults = UserDefaults()
        
        priceObservation = observe(\ViewController.priceSocket.currentPrice, options: [.new], changeHandler: { [self] (vc, change) in
            guard let updatedPrice = change.newValue else { return }
            self.stockCards[self.tickerKVO!]?.currentPrice = Float(updatedPrice)
            self.stockTableView.reloadData()
        })
        tickerObservation = observe(\ViewController.priceSocket.currentTicker, options: [.new], changeHandler: { (vc, change) in
            guard let updatedTicker = change.newValue as? String else { return }
            self.tickerKVO = updatedTicker
        })
        
        if defaults.bool(forKey: "isAppAlreadyLaunchedOnce") {
            print("Launched not first time")
//            defaults.set(false, forKey: "isAppAlreadyLaunchedOnce")
            
            loadCardsFromCoreData()
            cardsIsLoaded = true
            self.loadStocksInView()
            priceSocket.startWebSocket(tickerArray: stockTickerList)
            
        } else {
            print("First launch!")
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            
            loadCardsFromAPI()
            self.loadStocksInView()
        // TODO: - Add loading indicator/animation
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
                stockTableView.autolayoutWidth()
                loadPricesFromAPI()
                
//                favouriteIsSelected = false
                cardsIsLoaded = true
                
                priceSocket.startWebSocket(tickerArray: stockTickerList)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Exiting")
    }

    func loadStocksInView() {
        stockTableView.dataSource = self
        stockTableView.delegate = self
        searchBar.delegate = self        
        searchBar.isHidden = false
    }
    
    // MARK: - AlertController
    
    func showAlert(request: AlertMessage) {
        let alert = AlertViewController().configureAlertVC(request: request)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func likeButtonDidPressed(_ sender: UIButton) {
        let key = isFiltering ? filteredStockTickerList[sender.tag] : stockTickerList[sender.tag]

        if favourites.contains(ticker: key) {
            UIView.animate(withDuration: 0.35, delay: 0.2, options: [.curveEaseInOut]) {
                UIView.transition(with: sender.imageView!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    sender.setImage(UIImage(named: "StarGray"), for: .normal)
                }, completion: nil)
                sender.imageView?.transform = (sender.imageView?.transform.scaledBy(x: 0.8, y: 0.8))!
            }
            favourites.deleteTicker(withTicker: key)
            stockCards[key]!.isFavourite = false
            print(key, stockCards[key]!.isFavourite)
        } else {
            UIView.animate(withDuration: 0.35, delay: 0.2, options: [.curveEaseInOut]) {
                UIView.transition(with: sender.imageView!, duration: 0.5, options: [.transitionCrossDissolve], animations: {
                    sender.setImage(UIImage(named: "StarGold"), for: .normal)
                }, completion: nil)
                sender.imageView?.transform = (sender.imageView?.transform.scaledBy(x: 0.8, y: 0.8))!
            }
            favourites.saveTicker(withTicker: key)
            stockCards[key]!.isFavourite = true
            print(key, stockCards[key]!.isFavourite)
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
    
    // MARK: - API load funcs
    
    // API request for company profile data
    func loadCardsFromAPI() {
        stockAPIData.loadCardsFromAPI { (stockCards, error) in
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
                self.saveCardsToCoreData()
            }
        }
    }
    
    // API request for prices data of Cards
    func loadPricesFromAPI() {
        stockAPIData.loadPricesFromAPI { (stockCards, error) in
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
                self.saveCardsToCoreData()
            }
        }
    }
    
    // MARK: - Segue to DetailView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            guard let indexPath = indexPathForLastSelectedRow else {
                print("IndexPath error")
                return
            }
            let key = isFiltering ? filteredStockTickerList[indexPath.row] : stockTickerList[indexPath.row]
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.detailCard = stockCards[key]
        }
    }
    
    // MARK: - CoreData Load Cards
    
    // Reload data from CoreData
    func loadCardsFromCoreData() {
        stockCards = modelCoreData.loadCardsFromCoreData()
        stockTickerList = StockList().stockList
    }
    
    // Save all cards to CoreData as dictionary
    func saveCardsToCoreData() {
        modelCoreData.saveCoreData(cards: stockCards)
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
        
        cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "EvenCell") : UIColor(named: "BackgroundColor")
        stockTableView.rowHeight = cell.rawHeight
        cell.layer.cornerRadius = 24

        let image = favourites.contains(ticker: key) ? UIImage(named: "StarGold") : UIImage(named: "StarGray")
        cell.favouriteButton.setImage(image, for: .normal)

        cell.favouriteButton.tag = indexPath.row
        
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.selectionStyle = .none
        indexPathForLastSelectedRow = indexPath
        performSegue(withIdentifier: "showDetailView", sender: nil)
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
