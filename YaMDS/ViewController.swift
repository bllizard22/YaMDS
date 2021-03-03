//
//  ViewController.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 03.03.2021.
//

import UIKit
import Foundation

struct quoteData: Decodable {
    let ask: Int
//    let symbol: String
//    let shortName: String
//    let postMarketPrice: Int
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let headers = [
            "X-Mboum-Secret": "demo"
        ]

        let request = NSMutableURLRequest(
            url: NSURL(string: "https://mboum.com/api/v1/qu/quote/?symbol=AAPL")! as URL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
//                let httpResponse = response as? HTTPURLResponse
//                print(httpResponse)
//                let quoteString = String(data: data!, encoding: .utf8)!
//                let index = quoteString.index(quoteString.startIndex, offsetBy: 20)
//                let substr = String(quoteString[...index])
//                print(substr)
//                print(type(of: data!))
                print(data!)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    print(json)
//                    let askSize = json["askSize"] as? Int
//                    print(askSize)
                } catch let error {
                    print(error)
                }
            }
        })

        dataTask.resume()
        
    }


}

