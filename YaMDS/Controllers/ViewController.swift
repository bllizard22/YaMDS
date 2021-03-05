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
    var dataGet = [Data()]
    var jsonName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let stockData = StockData()
//        stockData.getStockList()
        stockData.getStockInfo(stockSymbol: "AAPL")
        stockData.getStockInfo(stockSymbol: "TSLA")
        stockData.getStockInfo(stockSymbol: "YNDX")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+4) { [self] in [self]
            self.loadStocksInView()
        }
        
//        let stockData = StockData()
//        print(dataGet)
//        print("Here!\(stockData.dadta)")
//
//        stockTableView = UITableView(frame: CGRect(x: 0, y: 200,
//                                                   width: view.bounds.width, height: view.bounds.height-200))
//        stockTableView.rowHeight = 68
//        stockTableView.separatorStyle = .none
//        stockTableView.register(UINib(nibName: "StockCell", bundle: nil), forCellReuseIdentifier: "stockCell")
//        stockTableView.dataSource = self
//        stockTableView.delegate = self
//
//        view.addSubview(stockTableView)
        
    }
    
    func loadStocksInView() {
        let stockData = StockData()
        print(stockData.dadta.count)
        dataGet = stockData.dadta
        
        print(dataGet)
        print("Here!\(stockData.dadta)")
        
        stockTableView = UITableView(frame: CGRect(x: 0, y: 200,
                                                   width: view.bounds.width, height: view.bounds.height-200))
        stockTableView.rowHeight = 68
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
        do {
            print("in tabledelegate \(dataGet.count)")
            let json = try JSONSerialization.jsonObject(with: dataGet[indexPath.row], options: .allowFragments) as! [String: Any]
            self.jsonName = json["name"] as! String
        } catch let error {
            print(error)
        }
        cell.companyLabel.text = jsonName
        
        return cell
    }
    
    
}

