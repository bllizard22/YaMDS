//
//  AlertMessageVC.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 19.03.2021.
//

import UIKit

class AlertMessageVC: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func showAlert(request: String) {
        let alert = UIAlertController(title: "API Error", message: "Out of API requests.\n Try again in 1 min?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { (action) in
            guard action.style == .default else { return }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+60) {
                if request == "getStockInfo" {
                    let stockData = StockData()
                    for company in StockList().stockList {
                        stockData.getStockInfo(stockSymbol: company) { (dataIn) -> () in
                            self.dataStockInfo.append(dataIn)
                        }
                    }
                }
                if request == "getPrice" {
                    let stockData = StockData()
                    for company in StockList().stockList {
                        stockData.getPrice(stockSymbol: company) { (company, dataIn) in
                            self.dataStockPrice.append((company, dataIn))
                        }
                    }
                    print("loaded prices")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            guard action.style == .cancel else { return }
            print("Cancel")
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
