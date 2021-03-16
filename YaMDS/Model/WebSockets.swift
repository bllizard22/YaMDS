//
//  WebSockets.swift
//  YaMDS
//
//  Created by nick on 3/16/21.
//

import Foundation
import Starscream
import SwiftyJSON

class PriceSocket: NSObject, WebSocketDelegate {
    
    var isConnected = false
    var webSocket: WebSocket!
    
    @objc dynamic var currentTicker: String!
    @objc dynamic var currentPrice = 0.0
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                isConnected = true
                print("websocket is connected: \(headers)")
            case .disconnected(let reason, let code):
                isConnected = false
                print("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                parseSocketData(string: string)
            case .binary(let data):
                print("Received data: \(data.count)")
            case .ping(_):
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                print("websocket diconnected")
                isConnected = false
            case .error(let error):
                isConnected = false
                print(error!)
//                handleError(error)
            }
    }
    
    private func parseSocketData(string: String) {
        let dataEncoded = Data(string.utf8)
        let json = try! JSON(data: dataEncoded, options: .allowFragments)
        if json["type"] == "trade", json["data"].count > 0{
            let last = json["data"].count-1
            let data = json["data"][last]
            let price = data["p"]
            let ticker = data["s"]
            currentTicker = ticker.stringValue
            currentPrice = price.doubleValue
            print("Trade with \(ticker) at $\(price)")
//            completion(ticker, price)
        }
    }
    
    func startWebSocket(tickerArray: Array<String>) {
        createConnection()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
            subscribeOnAllStocks(tickerArray: tickerArray)
        }
    }
    
    func createConnection() {
        var request = URLRequest(url: URL(string: "wss://ws.finnhub.io?token=c0vhf5748v6pqdk9hmq0")!)
        request.timeoutInterval = 5
        
        webSocket = WebSocket(request: request)
        webSocket.delegate = self
        webSocket.connect()

//        NotificationCenter.default.addObserver(SocketViewController.self, selector: #selector(SocketViewController().updatePriceLabel), name: .none, object: nil)
    }
    
    func subscribeOnAllStocks(tickerArray: Array<String>) {
        for ticker in tickerArray {
            subscribe(symbol: ticker)
        }
    }
    
    func subscribe(symbol: String) {
        let json = ["type": "subscribe", "symbol": symbol]
        let data = try! JSONEncoder().encode(json)
        print("Subscribed at \(symbol)")
        webSocket.write(data: data)
    }
}
