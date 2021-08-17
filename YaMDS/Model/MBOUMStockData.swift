//
//  mboumStockData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 11.03.2021.
//

import Foundation
import SwiftyJSON

class MBOUMStockData {

	/// OPINION: возможно лучше статически это хранить
    let headers = [
        "X-Mboum-Secret": "demo"
    ]
    let session = URLSession.shared

	/// OPINION: лишние свойства
    var dadta = [Data()]
    var dataStockInfo = Array<Data>()
    var stockCards = Dictionary<String, StockTableCard>()
    var stockTickerList = Array<String>()
	/// OPINION: точно надо хранить?
    var companySummary = ""

    func getCompanySummary(company: String, completion: @escaping (String) -> ()){
        readData(company: company)
		/// OPINION: почему делей 1 секунда
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) { [self] in
            parseStocksDataToJSON { (summary) in
                companySummary = summary
            }
            completion(companySummary)
        }
    }
    
    func readData(company: String) {
		/// OPINION: code style отступов
            getStockInfo(stockSymbol: company) { (dataIn) -> () in
                self.dataStockInfo.append(dataIn)
            }
    }

	/// OPINION: почему escaping + обработку ошибок для клиента
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
		/// OPINION: почему не сразу URLRequest. + Гарантия что force unwrap не упадет
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
				/// OPINION: что будет если параллельно писать и читать в массив?
                self.dataStockInfo.append(data!)
            }
        })

        dataTask.resume()
    }

}
