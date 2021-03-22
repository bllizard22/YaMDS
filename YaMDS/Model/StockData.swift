//
//  StockData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 04.03.2021.
//

import Foundation

enum AlertMessage {
    case connection, apiLimit, unknown
}

class StockData {
    
    let headers = [
        "X-Finnhub-Token": "c0vhf5748v6pqdk9hmq0"
//        "X-Finnhub-Token": "sandbox_c0vhf5748v6pqdk9hmqg"
    ]
    let session = URLSession.shared
    
//    var dadta = [Data()]
    
    var dataStockInfo = Array<Data>()
    var dataStockPrice = Array<(String, Data)>()
    var dataStockMetric = Array<(String, Data)>()
    
    var stockCards = Dictionary<String, StockTableCard>()   // Dict for all Cards
    var stockTickerList = Array<String>()   // List of tickers for Cards
    
    func loadCardsFromAPI(completion: @escaping (Dictionary<String, StockTableCard>?, AlertMessage?) -> ()) {
        for company in StockList().stockList {
            self.getStockInfo(stockSymbol: company) { (dataIn, error) -> () in
                if let error = error {
//                    print("Error \(error.code) on connection\n\n")
                    completion(nil, error)
                    return
                }
                self.dataStockInfo.append(dataIn!)
                self.parseCardsDataJSON()
                completion(self.stockCards, nil)
            }
        }
    }
    
    // API request for prices data of Cards
    func loadPricesFromAPI(completion: @escaping (Dictionary<String, StockTableCard>?, AlertMessage?) -> ()) {
        for company in StockList().stockList {
            self.getPrice(stockSymbol: company) { (ticker, dataIn, error) -> () in
                if let error = error {
//                    print("Error \(error.code) on connection\n\n")
                    completion(nil, error)
                    return
                }
                self.dataStockPrice.append((ticker!, dataIn!))
                self.parsePricesDataJSON()
                completion(self.stockCards, nil)
            }
        }
    }
    
    func getStockInfo(stockSymbol symbol: String, completion: @escaping (Data?, AlertMessage?) -> ()) {
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
            let dataTask = session.dataTask(with: request as URLRequest,completionHandler: { (data, response, error) -> Void in
                if let error = error as NSError? {
                    if error.code == NSURLErrorNotConnectedToInternet {
                        completion(nil, .connection)
                    } else if error.code == 429 {
                        completion(nil, .apiLimit)
                    } else {
                        completion(nil, .unknown)
                    }
                } else {
                    completion(data!, nil)
                }
            }
            )
            dataTask.resume()
    }
    
    func getPrice(stockSymbol symbol: String, completion: @escaping (String?, Data?, AlertMessage?) -> ()) {
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/quote?symbol=\(symbol)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        //        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error = error as NSError? {
                if error.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, nil, .connection)
                } else if error.code == 429 {
                    completion(nil, nil, .apiLimit)
                } else {
                    completion(nil, nil, .unknown)
                }
            } else {
                completion(symbol, data!, nil)
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
    
    func parseCardsDataJSON () {
        print(dataStockInfo.count)
        print("data for JSON", dataStockInfo)
//        var json: [String: Any]
        for data in dataStockInfo {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                print(json)
                if json["error"] != nil {
//                    showAlert(request: "getStockInfo")
                    print("\n\nInfo Alert!\n\n")
                    return
                }
                var stringLogoURL = json["logo"] as? String
                if stringLogoURL == "" {
                    stringLogoURL = "https://finnhub.io/api/logo?symbol=AAPL"
                }
                let card = StockTableCard(name: json["name"] as! String,
                                          logo: (URL.init(string: stringLogoURL!)!),
                                          ticker: json["ticker"] as! String,
                                          industry: json["finnhubIndustry"] as! String,
                                          marketCap: Float(truncating: json["marketCapitalization"] as! NSNumber),
                                          sharesOutstanding: Float(truncating: json["shareOutstanding"] as! NSNumber),
                                          peValue: 0.0,
                                          psValue: 0.0,
                                          ebitda: 0.0,
                                          summary: "---",
                                          currentPrice: 0.0,
                                          previousClosePrice: 0.0,
                                          isFavourite: false)
                stockCards[card.ticker] = card
                stockTickerList.append(card.ticker)
            } catch let error {
                print(error)
            }
        }
        stockTickerList.sort()
    }
    
    func parsePricesDataJSON () {
        print(dataStockInfo.count)
        print("data for JSON", dataStockInfo)
        for (key, data) in dataStockPrice {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                print(key, json)
                if json["error"] != nil {
//                    showAlert(request: "getPrice")
                    print("\n\nPrice Alert!\n\n")
                    return

                }
                stockCards[key]?.currentPrice = Float(truncating: json["c"] as! NSNumber)
                stockCards[key]?.previousClosePrice = Float(truncating: json["pc"] as! NSNumber)
            } catch let error {
                print(error)
            }
        }
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
