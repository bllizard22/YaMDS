//
//  StockData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 04.03.2021.
//

import Foundation
import SwiftyJSON

class StockAPIData {
    
    let headers = [
        "X-Finnhub-Token": "c0vhf5748v6pqdk9hmq0"
//        "X-Finnhub-Token": "sandbox_c0vhf5748v6pqdk9hmqg"
    ]
    let session = URLSession.shared
        
    var dataStockInfo = Array<Data>()
    var dataStockPrice = Array<(String, Data)>()
    var dataMetricCard = Data()
    
    var stockCards = Dictionary<String, StockTableCard>()   // Dict for all Cards
    var stockTickerList = Array<String>()   // List of tickers for Cards
    
    var remainingRequests = 60
    var isAlert = false
    
    func loadCardsFromAPI(completion: @escaping (Dictionary<String, StockTableCard>?, AlertMessage?) -> ()) {
        self.isAlert = false
        for company in StockList().stockList {
            if !self.isAlert, remainingRequests > 0 {
                self.getStockInfo(stockSymbol: company) { (dataIn, error) -> () in
                    if let error = error {
                        self.isAlert = true
                        completion(nil, error)
                        return
                    }
                    self.dataStockInfo.append(dataIn!)
                    self.parseCardsDataJSON()
                    completion(self.stockCards, nil)
                }
            }
        }
    }
    
    func loadPricesFromAPI(completion: @escaping (Dictionary<String, StockTableCard>?, AlertMessage?) -> ()) {
        for company in StockList().stockList {
            if !self.isAlert, remainingRequests > 0 {
                self.getPrice(stockSymbol: company) { (ticker, dataIn, error) -> () in
                    if let error = error {
                        self.isAlert = true
                        completion(nil, error)
                        return
                    }
                    self.dataStockPrice.append((ticker!, dataIn!))
                    self.parsePricesDataJSON()
                    completion(self.stockCards, nil)
                }
            }
        }
    }
    
    func loadMetricFromAPI(ticker company: String, completion: @escaping (StockTableCard?, AlertMessage?) -> ()) {
        if !isAlert {
            self.getMetric(stockSymbol: company) { (ticker, dataIn, error) -> () in
                if let error = error {
                    completion(nil, error)
                    return
                }
                self.dataMetricCard.append(dataIn!)
                self.parseMetricDataJSON(ticker: company)
                completion(self.stockCards[company], nil)
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
        
        let dataTask = session.dataTask(with: request as URLRequest,completionHandler: { (data, rawResponse, error) -> Void in
            if let error = error as NSError? {
                if error.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, .connection)
                } else {
                    completion(nil, .unknown)
                }
                return
            }
            let response = rawResponse as! HTTPURLResponse
//            print(response)
            self.remainingRequests = Int(response.value(forHTTPHeaderField: "x-ratelimit-remaining")!)!
            print(self.remainingRequests)
            guard response.statusCode == 200 else {
                let errorType: AlertMessage = response.statusCode == 429 ? .apiLimit : .unknown
                completion(nil, errorType)
                return
            }
            completion(data!, nil)
            
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
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, rawResponse, error) -> Void in
            if let error = error as NSError? {
                if error.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, nil, .connection)
                } else {
                    completion(nil, nil, .unknown)
                }
                return
            }
            let response = rawResponse as! HTTPURLResponse
            self.remainingRequests = Int(response.value(forHTTPHeaderField: "x-ratelimit-remaining")!)!
            print(self.remainingRequests)
            guard response.statusCode == 200 else {
                let errorType: AlertMessage = response.statusCode == 429 ? .apiLimit : .unknown
                completion(nil, nil, errorType)
                return
            }
            completion(symbol, data!, nil)
        })
        dataTask.resume()
    }
    
    func getMetric(stockSymbol symbol: String, completion: @escaping (String?, Data?, AlertMessage?) -> ()) {
        let request = NSMutableURLRequest(
            //            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=AAPL,FB")! as URL,
            url: NSURL(string: "https://finnhub.io/api/v1/stock/metric?symbol=\(symbol)&metric=all")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                completion(nil, nil, .unknown)
            } else {
                completion(symbol, data!, nil)
            }
        })
        dataTask.resume()
    }
    
    func parseCardsDataJSON () {
        for data in dataStockInfo {
            do {
                let json = try JSON(data: data, options: .allowFragments)
                if json["error"].string != nil {
                    print("\n\nInfo Alert!\n\n")
                    print(json)
                    return
                }
//                var stringLogoURL = json["logo"].string
//                if stringLogoURL == "" {
//                    stringLogoURL = "https://finnhub.io/api/logo?symbol=AAPL"
//                }
                let card = StockTableCard(name: json["name"].stringValue,
                                          logo: json["logo"].url!,
                                          ticker: json["ticker"].stringValue,
                                          industry: json["finnhubIndustry"].stringValue,
                                          marketCap: json["marketCapitalization"].floatValue,
                                          sharesOutstanding: json["shareOutstanding"].floatValue,
                                          peValue: 0.0,
                                          psValue: 0.0,
                                          ebitda: 0.0,
                                          summary: "",
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
        for (key, data) in dataStockPrice {
            do {
                let json = try JSON(data: data, options: .allowFragments)
                if json["error"].string != nil {
                    print("\n\nPrice Alert!\n\n")
                    return
                }
                stockCards[key]?.currentPrice = json["c"].floatValue
                stockCards[key]?.previousClosePrice = json["pc"].floatValue
            } catch let error {
                print(error)
            }
        }
    }
    
    func parseMetricDataJSON (ticker key: String) {
        do {
            let json = try JSON(data: dataMetricCard, options: .allowFragments)
            guard json["metric"].dictionary != nil else {
                print("Error")
                return
            }
            let metric = json["metric"]
            stockCards[key]?.peValue = metric["peNormalizedAnnual"].floatValue
            stockCards[key]?.psValue = metric["psTTM"].floatValue
            stockCards[key]?.ebitda = metric["ebitdPerShareTTM"].floatValue
        } catch let error {
            print(error)
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
