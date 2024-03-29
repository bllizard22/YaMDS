//
//  mboumStockData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 11.03.2021.
//

import Foundation
import SwiftyJSON

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

    func getCompanySummary(company: String, completion: @escaping (String) -> ()){
        readData(company: company)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) { [self] in
            parseStocksDataToJSON { (summary) in
                companySummary = summary
            }
            completion(companySummary)
        }
    }
    
    func readData(company: String) {
            getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dataStockInfo.append(dataIn)
            }
    }

    private func parseStocksDataToJSON (completion: @escaping (String) -> ()) {
//        print(dataStockInfo.count)
//        print("data for JSON", dataStockInfo)
        for data in dataStockInfo {
            do {
                let json = try JSON(data: data, options: .allowFragments)
                
                print(json["longBusinessSummary"].stringValue)
                let summary = json["longBusinessSummary"].stringValue
                completion(summary)
            } catch let error {
                print(error)
            }
        }
    }

    private func getStockInfo(stockSymbol symbol: String, completion: @escaping (Data) -> ()) {

        print(#function, symbol)
        let request = NSMutableURLRequest(
            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/profile/?symbol=\(symbol)")! as URL,
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
