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
    
    var stockTableView: UITableView!
    
    var dataStockInfo = Array<Data>()
    var dataStockPrice = Array<(String, Data)>()
    var dataStockMetric = Array<(String, Data)>()
    var stockCards = Dictionary<String, StockTableCard>()
    
    var stockList = StockList().stockList
    var stockTickerList = Array<String>()
    var favouriteIsSelected =  false
    var favourites = Favourites()
    
    var jsonName = ""
    
    // IBOutlets
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    var headerViewHeight = 0
    
    // SearchController
//    let searchController = UISearchController(searchResultsController: nil)
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
        
        loadAllStocksData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
            if dataStockInfo[0].count == 0 {
                dataStockInfo.removeFirst()
            }
            self.loadStocksInView()
            
            parseStocksDataToJSON()
        }
    }
    
    func loadStocksInView() {
        
        stockTableView = UITableView(frame: CGRect(x: 12, y: 200,
                                                   width: view.bounds.width-12*2, height: view.bounds.height-200))
        stockTableView.rowHeight = 96
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
            sender.setImage(UIImage(systemName: "star"), for: .normal)
            favourites.deleteTicker(withTicker: key)
            stockCards[key]!.isFavourite = false
            print("\(key) did disliked")
        } else {
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
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
        stockTickerList = StockList().stockList
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(20)
        favouriteButton.setTitleColor(.systemGray2, for: .normal)
        
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(32)
        stocksButton.setTitleColor(.black, for: .normal)
        
        favouriteIsSelected = false
        
        stockTableView.reloadData()
    }
    
    @IBAction func favouriteButtonDidPressed(_ sender: UIButton) {
        stockTickerList = favourites.liked
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(32)
        favouriteButton.setTitleColor(.black, for: .normal)
        
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(20)
        stocksButton.setTitleColor(.systemGray2, for: .normal)

        favouriteIsSelected = true
        
//        favourites.clearAllLikes()
        
        stockTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            if let indexPath = stockTableView.indexPathForSelectedRow {
                let key: String
                if isFiltering {
                    key = filteredStockTickerList[indexPath.row]
                } else {
                    key = stockTickerList[indexPath.row]
                }
                
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.detailCard = stockCards[key]
                
            }
        }
    }
    
    // MARK: - API load funcs
    
    func loadAllStocksData() {
        let stockData = StockData()
        for company in stockList {
            stockData.getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dataStockInfo.append(dataIn)
            }
            
            stockData.getPrice(stockSymbol: company) { (company, dataIn) in
                self.dataStockPrice.append((company, dataIn))
            }
        }
    }
    
    func parseStocksDataToJSON () {
        print(dataStockInfo.count)
        print("data for JSON", dataStockInfo)
//        var json: [String: Any]
        for data in dataStockInfo {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]

                print(json)
                // TODO: - Set price and logo URL
                var stringLogoURL = json["logo"] as? String
                if stringLogoURL == "" {
                    stringLogoURL = "https://finnhub.io/api/logo?symbol=AAPL"
                }
//                print(stringLogoURL!)
                let card = StockTableCard(name: json["name"] as! String,
                                          logo: (URL.init(string: stringLogoURL!)!),
                                          ticker: json["ticker"] as! String,
                                          industry: json["finnhubIndustry"] as! String,
                                          marketCap: Float(truncating: json["marketCapitalization"] as! NSNumber),
                                          sharesOutstanding: Float(truncating: json["shareOutstanding"] as! NSNumber),
                                          peValue: 0.0,
                                          psValue: 0.0,
                                          ebitda: 0.0,
                                          currentPrice: 0.0,
                                          previousClosePrice: 0.0,
                                          isFavourite: false)
                stockCards[card.ticker] = card
                stockTickerList.append(card.ticker)
            } catch let error {
                print(error)
            }
        }
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
    
}

// MARK: - TableView extension

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return StockList().stockList.count
        if isFiltering {
            return filteredStockTickerList.count
        }
        return stockTickerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell",
                                                 for: indexPath as IndexPath) as! StockTableViewCell
        
//        let key = stockCardsList[indexPath.row]
        var key: String
        if isFiltering {
            key = filteredStockTickerList[indexPath.row]
        } else {
            key = stockTickerList[indexPath.row]
        }
        
        cell.companyLabel.text = stockCards[key]!.name
        cell.tickerLabel.text = stockCards[key]!.ticker
        cell.priceLabel.text = "$" + String(stockCards[key]!.currentPrice)
        cell.priceChangeLabel.text = StockData().calcPriceChange(card: stockCards[key]!)
        
        let resource = ImageResource(downloadURL: stockCards[key]!.logo)
        cell.logoImage.kf.setImage(with: resource) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(_):
                print("fail")
            }
        }
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(named: "AccentColor")
        }
        cell.layer.cornerRadius = 16
        
        //TODO: - Replace with single func
        if favourites.contains(ticker: key) {
            cell.favouriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            stockCards[key]!.isFavourite = true
            print("\(key) is liked")
        } else {
            cell.favouriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            stockCards[key]!.isFavourite = false
            print("\(key) is not liked")
        }
        cell.favouriteButton.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ticker = stockTickerList[indexPath.row]
        StockData().getMetric(stockSymbol: ticker) { (company, dataIn) in
            self.dataStockMetric.append((company, dataIn))
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0) { [self] in
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
    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        isEditing
//    }
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBarIsClicked = true
//    }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchBarIsClicked = false
//    }
}

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


