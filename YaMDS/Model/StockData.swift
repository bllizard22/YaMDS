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
        
        //
        for company in StockList().stockList {
            getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dadta.append(dataIn)
                print(self.dadta.count)
            }
        }
//        print("get \(dadta.count) elements")
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
            
//            DispatchQueue.global(qos: .background).async {
                
                if (error != nil) {
                    print(error!)
                } else {
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//                            as! [String: Any]
                        completion(data!)
//                        DispatchQueue.main.async {
//                            self.dadta.append(data!)
//                            print("append")
//                        }

//                    } catch let error {
//                        print(error)
//                    }
                }
//            }
        }
        )
        dataTask.resume()
    }
    
    //https://finnhub.io/api/v1/stock/profile?symbol=AAPL
    
    func getStockProfile(stockSymbol symbol: String, completion: @escaping (Data) -> ()) {
        
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://finnhub.io/api/v1/stock/profile?symbol=\(symbol)")! as URL,
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
        })
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
//                let httpResponse = response as? HTTPURLResponse
                //        print(httpResponse)
//                let dataString = String(data: data!, encoding: .utf8)!
                //                print(dataString.count)
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
//                    let current = json["c"] as! NSNumber.FloatLiteralType
//                    let previous = json["pc"] as! NSNumber.FloatLiteralType
//                    let format = NumberFormatter()
//                    format.numberStyle = .percent
//                    format.minimumIntegerDigits = 1
//                    format.minimumFractionDigits = 2
//                    format.maximumFractionDigits = 2
//
//                    let change = format.string(from: NSNumber(value: ( current / previous - 1)))
//                    print("Change 24h: \(change!)")
//                    print(json)
//
//                } catch let error {
//                    print(error)
//                }
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
//                let httpResponse = response as? HTTPURLResponse
                //        print(httpResponse)
//                let dataString = String(data: data!, encoding: .utf8)!
                //                print(dataString.count)
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
//
//                    print(type(of: json))
//                    print(type(of: json["metric"]!))
//                    //                    print(type(of: json["metric"]!["peNormalizedAnnual"]))
//                    let metric = json["metric"] as! Dictionary<String,Any>
//                    print(metric)
//                    print(metric["peNormalizedAnnual"]!)
//
//                } catch let error {
//                    print(error)
//                }
                
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
        let changeValue = formatRatio
        
        // TODO: - Refactor +/- formatting
        let changeString = "\(formatValue.string(from: NSNumber(value: current-previous))!) (\(formatRatio.string(from: NSNumber(value: changeRatio))!))"
        
        return (changeString, changeRatio >= 0)
    }
}
