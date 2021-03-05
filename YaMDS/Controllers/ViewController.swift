//
//  ViewController.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 03.03.2021.
//

import UIKit
import Foundation

struct quoteData: Decodable {
    let ask: Int
//    let symbol: String
//    let shortName: String
//    let postMarketPrice: Int
}

class ViewController: UIViewController {

    var stockTableView: UITableView!
    var dataGet = Array<Data>()
    var stockCards = Array<StockTableCard>()
    var jsonName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadAllStocksData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
            if dataGet[0].count == 0 {
                dataGet.removeFirst()
            }
            self.loadStocksInView()
            
            parseStocksDataToJSON()
        }
    }
    
    func loadAllStocksData() {
        let stockData = StockData()
        for company in StockList().stockList {
            stockData.getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dataGet.append(dataIn)
            }
        }
    }
    
    func parseStocksDataToJSON () {
        print(dataGet.count)
        var json: [String: Any]
        for data in dataGet {
            do {
                let _json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                json = _json
                // TODO: - Set price and logo URL
                let card = StockTableCard(name: json["name"] as! String,
                                          logo: json["logo"] as! String,
                                          ticker: json["ticker"] as! String,
                                          currentPrice: 1.2,
                                          previousClosePrice: 1.3,
                                          isFavourite: false)
                stockCards.append(card)
            } catch let error {
                print(error)
            }
        }
        stockCards.sort(by: { $0.ticker < $1.ticker })
    }
    
    func loadStocksInView() {
        
        stockTableView = UITableView(frame: CGRect(x: 0, y: 200,
                                                   width: view.bounds.width, height: view.bounds.height-200))
        stockTableView.rowHeight = 86
        stockTableView.separatorStyle = .none
        stockTableView.register(UINib(nibName: "StockCell", bundle: nil), forCellReuseIdentifier: "stockCell")
        stockTableView.dataSource = self
        stockTableView.delegate = self
        
        view.addSubview(stockTableView)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StockList().stockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "stockCell",
                                                 for: indexPath as IndexPath) as! StockTableViewCell
        cell.companyLabel.text = stockCards[indexPath.row].name
        cell.tickerLabel.text = stockCards[indexPath.row].ticker
        cell.priceLabel.text = "$" + String(stockCards[indexPath.row].currentPrice)
        // TODO: -  insert setting of logo via Kingfisher
        
        return cell
    }
    
    
}

