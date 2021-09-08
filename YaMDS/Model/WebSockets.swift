//
//  WebSockets.swift
//  YaMDS
//
//  Created by nick on 3/16/21.
//

import Foundation
import Starscream
import SwiftyJSON

protocol PriceSocketDelegate: AnyObject {
    func currentPriceDidChange(value: Float, ticker: String)
}

class PriceSocket: WebSocketDelegate {

	/// Задача на тестирование. Доделай штуку с делегатом, убрав KVO и оттестируй э класс PriceSocket. (все что можешь, но как минимум методы didReceive и вызов методов делегаты при изменении currentPrice + мб startWebSocket)
	weak var delegate: PriceSocketDelegate?

    var isConnected = false
    var webSocket: WebSocket

    init() {
        var request = URLRequest(url: URL(string: "wss://ws.finnhub.io?token=c0vhf5748v6pqdk9hmq0")!)
        request.timeoutInterval = 5
        self.webSocket = WebSocket(request: request)
        self.webSocket.delegate = self
    }

    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                isConnected = true
                print("websocket is connected: \(headers["Alt-Svc"] ?? "--")")
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
            }
    }

    func startWebSocket(tickerArray: [String]) {
        webSocket.connect()
		/// OPINION: что за магическая задержка 2 секунды
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) { [self] in
            subscribeOnAllStocks(tickerArray: tickerArray)
        }
    }

    // MARK: - Private Methods

    private func parseSocketData(string: String) {
        let dataEncoded = Data(string.utf8)
        /// OPINION: почему так а не через decodable
        let json = try! JSON(data: dataEncoded, options: .allowFragments)
        if json["type"] == "trade", json["data"].count > 0{
            let last = json["data"].count-1
            let data = json["data"][last]
            let price = data["p"]
            let ticker = data["s"]
            delegate?.currentPriceDidChange(value: Float(price.doubleValue),
                                            ticker: ticker.stringValue)
        }
    }

    private func subscribeOnAllStocks(tickerArray: Array<String>) {
        for ticker in tickerArray {
            subscribe(symbol: ticker)
        }
    }
    
    private func subscribe(symbol: String) {
        let json = ["type": "subscribe", "symbol": symbol]
		/// OPINION: почему force unwrap, а что если упадет запрос, возможно тогда надо обрабатывать ошибку и сообщать пользователю
        let data = try! JSONEncoder().encode(json)
        print("Subscribed at \(symbol)")
        webSocket.write(data: data)
    }
}
