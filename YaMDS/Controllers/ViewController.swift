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
    var dataStockInfo = Array<Data>()
    var dataStockPrice = Array<(String, Data)>()
//    var stockCards = Array<StockTableCard>()
    var stockCards = Dictionary<String, StockTableCard>()
    var jsonName = ""
    var stockList = StockList().stockList
    
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
        var json: [String: Any]
        for data in dataStockInfo {
            do {
                let _json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                json = _json
                // TODO: - Set price and logo URL
                let card = StockTableCard(name: json["name"] as! String,
                                          logo: json["logo"] as! String,
                                          ticker: json["ticker"] as! String,
                                          currentPrice: 0.0,
                                          previousClosePrice: 0.0,
                                          isFavourite: false)
                stockCards[card.ticker] = card
            } catch let error {
                print(error)
            }
        }
        print("stockCards:", stockCards)
        for (key, data) in dataStockPrice {
//            print(data)
            do {
                let _json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                print(key, _json)
                stockCards[key]?.currentPrice = Float(_json["c"] as! NSNumber)
                stockCards[key]?.previousClosePrice = Float(_json["pc"] as! NSNumber)
            } catch let error {
                print(error)
            }
        }
//        stockCards.values.sort(by: { $0.ticker < $1.ticker })
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
        let key = stockList[indexPath.row]
        cell.companyLabel.text = stockCards[key]!.name
        cell.tickerLabel.text = stockCards[key]!.ticker
        cell.priceLabel.text = "$" + String(stockCards[key]!.currentPrice)
        cell.priceChangeLabel.text = StockData().calcPriceChange(card: stockCards[key]!)
        // TODO: -  insert setting of logo via Kingfisher
        
        return cell
    }
    
    
}

