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
    ]
    let session = URLSession.shared

	/// OPINION: точно необходимо столько свойств?
    var dataStockInfo = [Data]()
    var dataStockPrice = [(String, Data)]()
    var dataMetricCard = Data()
    
    var stockCards = [String: StockTableCard]()   // Dict for all Cards
    var stockTickerList = [String]()   // List of tickers for Cards
    
    var remainingRequests = 60
    var isAlert = false
    
    // MARK: - Price change for label
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
    
    // MARK: - Flag for first launch
    private func setFlagOfFirstLaunch() {
        let defaults = UserDefaults()
        print("First launch flag set!")
        defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
    }
      
    // MARK: - Batch load from API
    
    func loadAllCards(rootVC: ViewController) {
        let innerDispatchGroup = DispatchGroup()
        innerDispatchGroup.enter()
        loadCardsFromAPI { (stockCards, error) in
            if let error = error {
                DispatchQueue.main.async {
                    rootVC.showAlert(request: error)
                }
                return
            }
            self.stockTickerList = Array(stockCards!.keys).sorted()
            self.stockCards = stockCards!
            
            if self.stockCards.count == StockList().stockList.count {
                print("\n\nLeave! \(self.stockCards.count)\n\n")
                innerDispatchGroup.leave()
            }
        }
        
        innerDispatchGroup.notify(queue: .global(qos: .userInitiated)) {
            self.loadPricesFromAPI { (stockCards, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        rootVC.showAlert(request: error)
                    }
                    return
                }
                self.stockTickerList = Array(stockCards!.keys).sorted()
                self.stockCards = stockCards!
                let isAllPricesLoaded = self.stockCards.filter{ $0.value.previousClosePrice == 0 }.count == 0
                if isAllPricesLoaded {
                    self.setFlagOfFirstLaunch()
                    DispatchQueue.main.async {
                        rootVC.finishTableViewLoad()     
                    }
                }
            }
        }
    }
    
    private func loadCardsFromAPI(completion: @escaping (Dictionary<String, StockTableCard>?, AlertMessage?) -> ()) {
        self.isAlert = false
        for company in StockList().stockList {
            if !self.isAlert, remainingRequests > 0, stockCards[company] == nil {
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
            if !self.isAlert, remainingRequests > 0, stockCards[company]?.previousClosePrice == 0 {
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
    
    func loadMetricFromAPI(card: StockTableCard, completion: @escaping (StockTableCard?, AlertMessage?) -> ()) {
        if !isAlert {
            self.getMetric(stockSymbol: card.ticker) { (ticker, dataIn, error) -> () in
                if let error = error {
                    completion(nil, error)
                    return
                }
                self.dataMetricCard.append(dataIn!)
                let newCard = self.parseMetricDataJSON(forCard: card)
                completion(newCard, nil)
            }
        }
    }
    
    // MARK: - Send one specific HTTP-request
    
    private func getStockInfo(stockSymbol symbol: String, completion: @escaping (Data?, AlertMessage?) -> ()) {
        
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
            if let remainingHeaderField = response.value(forHTTPHeaderField: "x-ratelimit-remaining"), let remainingValue = Int(remainingHeaderField) {
                self.remainingRequests = remainingValue
            }
            print("Remaining requests: \(self.remainingRequests) (in \(#function))")
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
    
    private func getPrice(stockSymbol symbol: String, completion: @escaping (String?, Data?, AlertMessage?) -> ()) {
        
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
            if let remainingHeaderField = response.value(forHTTPHeaderField: "x-ratelimit-remaining"), let remainingValue = Int(remainingHeaderField) {
                self.remainingRequests = remainingValue
            }
            print("Remaining requests: \(self.remainingRequests) (in \(#function))")
            guard response.statusCode == 200 else {
                let errorType: AlertMessage = response.statusCode == 429 ? .apiLimit : .unknown
                completion(nil, nil, errorType)
                return
            }
            completion(symbol, data!, nil)
            
        })
        dataTask.resume()
    }
    
    private func getMetric(stockSymbol symbol: String, completion: @escaping (String?, Data?, AlertMessage?) -> ()) {
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/stock/metric?symbol=\(symbol)&metric=all")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, rawResponse, error) -> Void in
            if let error = error as NSError? {
                if error.code == NSURLErrorNotConnectedToInternet {
                    completion(nil, nil, .connectionDetailVC)
                } else {
                    completion(nil, nil, .unknown)
                }
                return
            }
            let response = rawResponse as! HTTPURLResponse
//            print(response)
            if let remainingHeaderField = response.value(forHTTPHeaderField: "x-ratelimit-remaining"), let remainingValue = Int(remainingHeaderField) {
                self.remainingRequests = remainingValue
            }
            print("Remaining requests: \(self.remainingRequests) (in \(#function))")
            guard response.statusCode == 200 else {
                let errorType: AlertMessage = response.statusCode == 429 ? .apiLimit : .unknown
                completion(nil, nil, errorType)
                return
            }
                completion(symbol, data!, nil)
        })
        dataTask.resume()
    }
    
    // MARK: - JSON Data parsing
    
    private func parseCardsDataJSON () {
        for data in dataStockInfo {
            do {
                let json = try JSON(data: data, options: .allowFragments)
                if json["error"].string != nil {
                    print("\n\nInfo Alert!\n\n")
                    print(json)
                    return
                }
                
                var weburl = String()
                if let rawWeburl = json["weburl"].string {
                    let weburlComponents = rawWeburl.dropLast(1).components(separatedBy: "://").last!
                    var domains = weburlComponents.components(separatedBy: "/")[0].components(separatedBy: ".")
                    if let secondDomain = domains.popLast(), let firstDomain = domains.popLast() {
                        weburl = firstDomain + "." + secondDomain
                    }
                } else {
                    weburl = ""
                }
                
                let card = StockTableCard(name: json["name"].stringValue,
                                          logo: json["logo"].url,
                                          ticker: json["ticker"].stringValue,
                                          weburl: weburl,
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
    
    private func parsePricesDataJSON () {
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
    
    private func parseMetricDataJSON (forCard card: StockTableCard) -> StockTableCard? {
        do {
            let json = try JSON(data: dataMetricCard, options: .allowFragments)
            guard json["metric"].dictionary != nil else {
                print("Error")
                return nil
            }
            var newCard = card
            let metric = json["metric"]
            newCard.peValue = metric["peNormalizedAnnual"].floatValue
            newCard.psValue = metric["psTTM"].floatValue
            newCard.ebitda = metric["ebitdPerShareTTM"].floatValue
            return newCard
        } catch let error {
            print(error)
            return nil
        }
    }
    
}
