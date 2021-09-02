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

/// FIXME: ну этот класс точно будем дробить, обсудим лично как
class ViewController: UIViewController, PriceSocketDelegate {

    // Stock Data
    var stockCards = [String: StockTableCard]() // Dict for all Cards
    var stockTickerList = [String]()   // List of tickers for Cards
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

	/// FIXME: пока не понял хачем, видимо от старого кода осталось
    // DispatchGroup
    let dispatchGroup = DispatchGroup()

    // WebSockets
	let priceSocket: PriceSocket = {
		let priceSocket = PriceSocket()
		return priceSocket
	}()

    // IBOutlets
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var favouriteButton: UIButton!
    @IBOutlet weak var searchBar: CustomSearchBar!
    @IBOutlet weak var cancelSearchButton: UIButton!
    @IBOutlet weak var stockTableView: StockTableView!
    @IBOutlet weak var activityIndicator: CustomActivityIndicator!
    
    var indexPathForLastSelectedRow = IndexPath()
    
    // SearchController
    var filteredStockTickerList = [String]()
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
    var isDataLoaded = false {
        didSet {
            view.isUserInteractionEnabled = isDataLoaded
            activityIndicator.isHidden = isDataLoaded
            searchBar.isHidden = !isDataLoaded
            if isDataLoaded {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
        }
    }

    // MARK: - PriceSocketDelegate

    func currentPriceDidChange(value: Float, ticker: String) {
        self.stockCards[ticker]?.currentPrice = value
        self.stockTableView.reloadData()
    }
    
    // MARK: - View Load Actions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isDataLoaded = false
        priceSocket.delegate = self
        loadStocksInView()
    }

    func loadStocksInView() {
        let defaults = UserDefaults()
        if defaults.bool(forKey: "isAppAlreadyLaunchedOnce") {
            print("Launched not first time")
            
            loadCardsFromCoreData()
            setDelegates()
            isDataLoaded = true
            priceSocket.startWebSocket(tickerArray: stockTickerList)
            
        } else {
            stockAPIData.loadAllCards(rootVC: self)
        }
    }
    
    func finishTableViewLoad() {
        stockCards = stockAPIData.stockCards
        stockTickerList = Array(stockCards.keys).sorted()
        
        setDelegates()
        stockTableView.reloadData()
        
        saveCardsToCoreData()
        print("Loaded model with \(stockAPIData.stockCards.count)")
        print("Loaded VC with \(stockCards.count)")
        priceSocket.startWebSocket(tickerArray: stockTickerList)
        isDataLoaded = true
    }
    
    func setDelegates() {
        searchBar.delegate = self
        stockTableView.dataSource = self
        stockTableView.delegate = self
        stockTableView.autolayoutWidth(forView: view)
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
            guard let button = sender as? StarButton else { return }
            button.animateDislikeTap()
            favourites.deleteTicker(withTicker: key)
            stockCards[key]!.isFavourite = false
        } else {
            guard let button = sender as? StarButton else { return }
            button.animateLikeTap()
            favourites.saveTicker(withTicker: key)
            stockCards[key]!.isFavourite = true
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
        stockTickerList = StockList().stockList
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(20)
        favouriteButton.setTitleColor(UIColor(named: "SecondaryFontColor"), for: .normal)
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(32)
        stocksButton.setTitleColor(UIColor(named: "PrimaryFontColor"), for: .normal)
        
        favouriteIsSelected = false
    }
    
    @IBAction func favouriteButtonDidPressed(_ sender: UIButton) {
        stockTickerList = favourites.liked
        
        favouriteButton.titleLabel?.font = favouriteButton.titleLabel?.font.withSize(32)
        favouriteButton.setTitleColor(UIColor(named: "PrimaryFontColor"), for: .normal)
        stocksButton.titleLabel?.font = stocksButton.titleLabel?.font.withSize(20)
        stocksButton.setTitleColor(UIColor(named: "SecondaryFontColor"), for: .normal)

        favouriteIsSelected = true
    }
    
    // MARK: - Segue to DetailView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            let key = isFiltering ? filteredStockTickerList[indexPathForLastSelectedRow.row] : stockTickerList[indexPathForLastSelectedRow.row]
            guard let cardForDetailVC = stockCards[key] else { return }
            let detailViewController = segue.destination as? DetailViewController
            detailViewController?.detailCard = cardForDetailVC
            detailViewController?.presentingVC = self
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
            guard let card = stockCards[ticker]?.name else {
                return ticker.lowercased().contains(searchText.lowercased())
            }
            let result = ticker.lowercased().contains(searchText.lowercased()) || card.lowercased().contains(searchText.lowercased())
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
