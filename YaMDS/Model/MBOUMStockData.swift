//
//  mboumStockData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 11.03.2021.
//

import Foundation

class MBOUMStockData {
    
    let headers = [
        "X-Mboum-Secret": "demo"
    ]
    let session = URLSession.shared
    
    var dadta = [Data()]
    var dataStockInfo = Array<Data>()
    var stockCards = Dictionary<String, StockTableCard>()
    var stockTickerList = Array<String>()
    var companySummary = ""

    func getCompanySummary(company: String) -> String {
        readData(company: company)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) { [self] in
            parseStocksDataToJSON { (summary) in
                companySummary = summary
            }
        }
        return company
    }
    
    func readData(company: String) {
            getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dataStockInfo.append(dataIn)
            }
    }

    func parseStocksDataToJSON (completion: @escaping (String) -> ()) {
        print(dataStockInfo.count)
        print("data for JSON", dataStockInfo)
        for data in dataStockInfo {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
                
                print(json["longBusinessSummary"]!)
                let summary = json["longBusinessSummary"] as! String
                completion(summary)
            } catch let error {
                print(error)
            }
        }
    }

    func getStockInfo(stockSymbol symbol: String, completion: @escaping (Data) -> ()) {

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/profile/?symbol=AAPL")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                self.dataStockInfo.append(data!)
            }
        })

        dataTask.resume()
    }

}
