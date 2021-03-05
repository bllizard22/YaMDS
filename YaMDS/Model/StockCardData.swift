//
//  StockCardData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 05.03.2021.
//

import Foundation

struct StockTableCard {
    // Data from Company Profile 2 request
    let name: String
    let logo: String
    let ticker: String
    
    // Data from request
    var currentPrice: Float
    var previousClosePrice: Float
    
    var isFavourite: Bool
    
}

// MARK: -API Requests (Finnhub)

/*
 Company Profile 2 - https://finnhub.io/api/v1/stock/profile2?symbol=AAPL
 
 {
   "country": "US",
   "currency": "USD",
   "exchange": "NASDAQ/NMS (GLOBAL MARKET)",
   "ipo": "1980-12-12",
   "marketCapitalization": 1415993,
   "name": "Apple Inc",
   "phone": "14089961010",
   "shareOutstanding": 4375.47998046875,
   "ticker": "AAPL",
   "weburl": "https://www.apple.com/",
   "logo": "https://static.finnhub.io/logo/87cb30d8-80df-11ea-8951-00000000092a.png",
   "finnhubIndustry":"Technology"
 }
 
 Quote - https://finnhub.io/api/v1/quote?symbol=AAPL
 {
   "c": 261.74, - Current price
   "h": 263.31, - High price of the day
   "l": 260.68, - Low price of the day
   "o": 261.07, - Open price of the day
   "pc": 259.45, - Previous close price
   "t": 1582641000
 }
 */
