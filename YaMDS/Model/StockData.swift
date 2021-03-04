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
    ]
    let session = URLSession.shared
    
    func getStockInfo(stockSymbol symbol: String) {
        
        let request = NSMutableURLRequest(
            //            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=AAPL,FB")! as URL,
            url: NSURL(string: "https://finnhub.io/api/v1/stock/profile2?symbol=\(symbol)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                //        print(httpResponse)
                let dataString = String(data: data!, encoding: .utf8)!
                //                print(dataString.count)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    //                    print("JSON size \(json.count)")
                    print(json)
                    //                    for stock in json {
                    ////                        print(json[0])
                    print(json["name"]!)
                    print(json["ticker"]!)
                    print(json["finnhubIndustry"]!)
                    print(json["currency"]!)
                    print(json["logo"]!)
                    //                        print(type(of: json))
                    //                    }
                } catch let error {
                    print(error)
                }
                
            }
        })
        dataTask.resume()
    }
    
    func getPrice(stockSymbol symbol: String) {
        
        let request = NSMutableURLRequest(
            //            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=AAPL,FB")! as URL,
            url: NSURL(string: "https://finnhub.io/api/v1/quote?symbol=\(symbol)")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        //        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                //        print(httpResponse)
                let dataString = String(data: data!, encoding: .utf8)!
                //                print(dataString.count)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                    //                    print("JSON size \(json.count)")
                    
                    print("Current: \(json["c"]!)")
                    //                    print("Previous: \(json["pc"]!)")
                    let current = json["c"] as! NSNumber.FloatLiteralType
                    let previous = json["pc"] as! NSNumber.FloatLiteralType
                    let format = NumberFormatter()
                    format.numberStyle = .percent
                    format.minimumIntegerDigits = 1
                    format.minimumFractionDigits = 2
                    format.maximumFractionDigits = 2
                    
                    let change = format.string(from: NSNumber(value: ( current / previous - 1)))
                    print("Change 24h: \(change!)")
                    print(json)
                    
                } catch let error {
                    print(error)
                }
                
            }
        })
        
        dataTask.resume()
    }
    
    func getMetric(stockSymbol symbol: String) {
        
        let request = NSMutableURLRequest(
            //            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=AAPL,FB")! as URL,
            url: NSURL(string: "https://finnhub.io/api/v1/stock/metric?symbol=\(symbol)&metric=all")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                let httpResponse = response as? HTTPURLResponse
                //        print(httpResponse)
                let dataString = String(data: data!, encoding: .utf8)!
                //                print(dataString.count)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! [String: Any]
                    
                    print(type(of: json))
                    print(type(of: json["metric"]!))
                    //                    print(type(of: json["metric"]!["peNormalizedAnnual"]))
                    let metric = json["metric"] as! Dictionary<String,Any>
                    print(metric)
                    print(metric["peNormalizedAnnual"])
                    
                } catch let error {
                    print(error)
                }
                
            }
        })
        
        dataTask.resume()
    }
    
}
