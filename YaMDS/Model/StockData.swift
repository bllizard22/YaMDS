//
//  StockData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 04.03.2021.
//

import Foundation

class StockData {
    
    let headers = [
        "X-Finnhub-Token": "c0vhf5748v6pqdk9hmq0"
//        "X-Finnhub-Token": "sandbox_c0vhf5748v6pqdk9hmqg"
    ]
    let session = URLSession.shared
    
    var dadta = [Data()]
    
    func getStockList(completion: @escaping ([Data]) -> ()) {
        for company in StockList().stockList {
            getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dadta.append(dataIn)
                print(self.dadta.count)
            }
        }
        dadta.removeFirst()
        completion(dadta)
    }
    
    func getStockInfo(stockSymbol symbol: String, completion: @escaping (Data) -> ()) {
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let dataTask = session.dataTask(with: request as URLRequest,completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                completion(data!)
            }
        }
        )
        dataTask.resume()
    }
    
    func getPrice(stockSymbol symbol: String, completion: @escaping (String, Data) -> ()) {
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/quote?symbol=\(symbol)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        //        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                completion(symbol, data!)
            }
        })
        dataTask.resume()
    }
    
    func getMetric(stockSymbol symbol: String, completion: @escaping (String, Data) -> ()) {
        
        let request = NSMutableURLRequest(
            //            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=AAPL,FB")! as URL,
            url: NSURL(string: "https://finnhub.io/api/v1/stock/metric?symbol=\(symbol)&metric=all")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                completion(symbol, data!)
            }
        })
        dataTask.resume()
    }
    
    func calcPriceChange(card: StockTableCard) -> (String, Bool) {
        let current = card.currentPrice
        let previous = card.previousClosePrice
        let changeRatio = current/previous - 1
        
        let formatRatio = NumberFormatter()
        formatRatio.numberStyle = .percent
        formatRatio.minimumIntegerDigits = 1
        formatRatio.minimumFractionDigits = 2
        formatRatio.maximumFractionDigits = 2
        
        let formatValue = NumberFormatter()
        formatValue.numberStyle = .currency
        formatValue.locale = Locale(identifier: "en_US")
        formatValue.minimumIntegerDigits = 1
        formatValue.minimumFractionDigits = 2
        formatValue.maximumFractionDigits = 2
        
        // TODO: - Refactor +/- formatting
        let changeString = "\(formatValue.string(from: NSNumber(value: current-previous))!) (\(formatRatio.string(from: NSNumber(value: changeRatio))!))"
        
        return (changeString, changeRatio >= 0)
    }
}
