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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let stockData = StockData()
//        stockData.getPrice(stockSymbol: "AAPL")
//        stockData.getStockInfo(stockSymbol: "AAPL")
//        stockData.getStockList()
        for company in StockList().stockList {
            stockData.getStockInfo(stockSymbol: company) { (data_1) in
    //                print(data_1)
                self.dataGet.append(data_1)
    //                print(self.dadta.count)
            }
        }
        
        print(dataGet.count)
        
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
//        print(indexPath.row)
        cell.companyLabel.text = "stock"
        
        return cell
    }
    
    
}

