//
//  StockCardData.swift
//  YaMDS
//
//  Created by Nikolay Kryuchkov on 05.03.2021.
//

import Foundation

struct StockTableCard: Codable {
    // Data from Company Profile 2 request
    let name: String
    let logo: URL?
    let ticker: String
    let weburl: String
    
    // Data for DetailVC
    let industry: String
    let marketCap: Float // marketCapitalization, M
    let sharesOutstanding: Float // shareOutstanding, M
    var peValue: Float  // peNormalizedAnnual
    var psValue: Float // psTTM
    var ebitda: Float // ebitdPerShareTTM * shareOutstanding, M
    
    // MBOUM Data
    var summary: String
    
    // Data from Quote request
    var currentPrice: Float
    var previousClosePrice: Float
    
    var isFavourite: Bool
    
}

extension StockTableCard: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
        hasher.combine(self.ticker)
    }
}

// MARK: -API Requests (Finnhub)

/*
 Company Profile 2 - https://finnhub.io/api/v1/stock/profile2?symbol=AAPL
 
 {
     "name": Apple Inc,
     "country": US,
     "currency": USD,
     "marketCapitalization": 1953463,
     "shareOutstanding": 16788.096, - M
     "ipo": 1980-12-12,
     "phone": 14089961010.0,
     "ticker": AAPL,
     "exchange": NASDAQ NMS - GLOBAL MARKET,
     "finnhubIndustry": Technology,
     "logo": https://finnhub.io/api/logo?symbol=AAPL,
     "weburl": https://www.apple.com/
 }
 
 Quote - https://finnhub.io/api/v1/quote?symbol=AAPL
 {
     "h": 122.17,
     "t": 1615420800,
     "c": 119.98,
     "o": 121.69,
     "pc": 121.085,
     "l": 119.45
 }
 
 Basic Financials - https://finnhub.io/api/v1/stock/metric?symbol=\(symbol)&metric=all
 {
 "metric": {
     10DayAverageTradingVolume = "139.99062";
     13WeekPriceReturnDaily = "-5.97172";
     26WeekPriceReturnDaily = "-3.80291";
     3MonthAverageTradingVolume = "2251.63905";
     52WeekHigh = "145.09";
     52WeekHighDate = "2021-01-25";
     52WeekLow = "53.1525";
     52WeekLowDate = "2020-03-23";
     52WeekPriceReturnDaily = "61.03519";
     5DayPriceReturnDaily = "-8.94436";
     assetTurnoverAnnual = "0.82884";
     assetTurnoverTTM = "0.84683";
     beta = "1.24105";
     bookValuePerShareAnnual = "3.84873";
     bookValuePerShareQuarterly = "3.93645";
     bookValueShareGrowth5Y = "-6.37004";
     capitalSpendingGrowth5Y = "-8.647019999999999";
     cashFlowPerShareAnnual = "3.9061";
     cashFlowPerShareTTM = "4.31281";
     cashPerSharePerShareAnnual = "5.35691";
     cashPerSharePerShareQuarterly = "4.56665";
     currentDividendYieldTTM = "0.69397";
     "currentEv/freeCashFlowAnnual" = "41.96565";
     "currentEv/freeCashFlowTTM" = "38.25929";
     currentRatioAnnual = "1.3636";
     currentRatioQuarterly = "1.163";
     dividendGrowthRate5Y = "9.83445";
     dividendPerShare5Y = "0.674";
     dividendPerShareAnnual = "0.795";
     dividendYield5Y = "1.16156";
     dividendYieldIndicatedAnnual = "0.7047099999999999";
     dividendsPerShareTTM = "0.8075";
     ebitdPerShareTTM = "4.90773";
     ebitdaCagr5Y = "-1.0971";
     ebitdaInterimCagr5Y = "0.5656099999999999";
     epsBasicExclExtraItemsAnnual = "3.30859";
     epsBasicExclExtraItemsTTM = "3.73824";
     epsExclExtraItemsAnnual = "3.27535";
     epsExclExtraItemsTTM = "3.6991";
     epsGrowth3Y = "12.47869";
     epsGrowth5Y = "7.28691";
     epsGrowthQuarterlyYoy = "34.64245";
     epsGrowthTTMYoy = "16.86043";
     epsInclExtraItemsAnnual = "3.27535";
     epsInclExtraItemsTTM = "3.6991";
     epsNormalizedAnnual = "3.27535";
     focfCagr5Y = "0.3639";
     freeCashFlowAnnual = 59284;
     freeCashFlowPerShareTTM = "3.80728";
     freeCashFlowTTM = 66064;
     "freeOperatingCashFlow/revenue5Y" = "18.85883";
     "freeOperatingCashFlow/revenueTTM" = "22.46043";
     grossMargin5Y = "38.3595";
     grossMarginAnnual = "38.23325";
     grossMarginTTM = "38.78049";
     inventoryTurnoverAnnual = "41.52296";
     inventoryTurnoverTTM = "39.70628";
     "longTermDebt/equityAnnual" = "151.9827";
     "longTermDebt/equityQuarterly" = "149.9169";
     marketCapitalization = 1953463;
     monthToDatePriceReturnDaily = "-4.0409";
     netDebtAnnual = 22154;
     netDebtInterim = 35217;
     netIncomeEmployeeAnnual = "404302.8";
     netIncomeEmployeeTTM = 434898;
     netInterestCoverageAnnual = "<null>";
     netInterestCoverageTTM = "<null>";
     netMarginGrowth5Y = "-1.75179";
     netProfitMargin5Y = "21.50219";
     netProfitMarginAnnual = "20.91361";
     netProfitMarginTTM = "21.73492";
     operatingMargin5Y = "25.89906";
     operatingMarginAnnual = "24.14731";
     operatingMarginTTM = "25.24453";
     payoutRatioAnnual = "24.53711";
     payoutRatioTTM = "22.13202";
     pbAnnual = "30.23334";
     pbQuarterly = "29.5596";
     pcfShareTTM = "26.10325";
     peBasicExclExtraTTM = "35.30271";
     peExclExtraAnnual = "35.52597";
     peExclExtraHighTTM = "35.67625";
     peExclExtraTTM = "31.4563";
     peExclLowTTM = "10.90841";
     peInclExtraTTM = "31.4563";
     peNormalizedAnnual = "35.52597";
     pfcfShareAnnual = "32.95093";
     pfcfShareTTM = "29.56925";
     pretaxMargin5Y = "26.59841";
     pretaxMarginAnnual = "24.43983";
     pretaxMarginTTM = "25.41418";
     "priceRelativeToS&P50013Week" = "-9.15549";
     "priceRelativeToS&P50026Week" = "-13.73112";
     "priceRelativeToS&P5004Week" = "-12.91388";
     "priceRelativeToS&P50052Week" = "25.25839";
     "priceRelativeToS&P500Ytd" = "-13.80494";
     psAnnual = "7.11605";
     psTTM = "6.64138";
     ptbvAnnual = "29.89735";
     ptbvQuarterly = "29.49781";
     quickRatioAnnual = "1.32507";
     quickRatioQuarterly = "1.12547";
     receivablesTurnoverAnnual = "14.06111";
     receivablesTurnoverTTM = "12.23752";
     revenueEmployeeAnnual = 1933204;
     revenueEmployeeTTM = 2000918;
     revenueGrowth3Y = "6.19294";
     revenueGrowth5Y = "3.27041";
     revenueGrowthQuarterlyYoy = "21.36813";
     revenueGrowthTTMYoy = "9.88184";
     revenuePerShareAnnual = "15.66132";
     revenuePerShareTTM = "16.95104";
     revenueShareGrowth5Y = "9.199870000000001";
     roaRfy = "17.33413";
     roaa5Y = "15.67208";
     roae5Y = "48.47848";
     roaeTTM = "82.09045999999999";
     roeRfy = "73.68556";
     roeTTM = "18.40581";
     roi5Y = "22.05595";
     roiAnnual = "25.44284";
     roiTTM = "27.79541";
     tangibleBookValuePerShareAnnual = "3.84873";
     tangibleBookValuePerShareQuarterly = "3.93645";
     tbvCagr5Y = "-9.95011";
     "totalDebt/totalEquityAnnual" = "173.0926";
     "totalDebt/totalEquityQuarterly" = "169.1879";
     totalDebtCagr5Y = "11.94642";
     yearToDatePriceReturnDaily = "-12.30688";
 }
 
 MBOUM Company Profile - https://mboum.com/api/v1/qu/quote/profile/?symbol=AAPL
 {
 {
 ["industry": Consumer Electronics,
 "fullTimeEmployees": 147000,
 "website": http://www.apple.com,
 "shareHolderRightsRisk": 1,
 "zip": 95014,
 "auditRisk": 6,
 "maxAge": 86400,
 "sector": Technology,
 "address1": One Apple Park Way,
 "boardRisk": 1,
 "state": CA,
 "phone": 408-996-1010,
 "compensationAsOfEpochDate": 1609372800,
 "country": United States,
 "overallRisk": 1,
 "companyOfficers": <__NSArrayI 0x600001a419e0>(
 {
     age = 59;
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     fiscalYear = 2020;
     maxAge = 1;
     name = "Mr. Timothy D. Cook";
     title = "CEO & Director";
     totalPay =     {
         fmt = "14.77M";
         longFmt = "14,769,259";
         raw = 14769259;
     };
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     yearBorn = 1961;
 },
 {
     age = 56;
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     fiscalYear = 2020;
     maxAge = 1;
     name = "Mr. Luca  Maestri";
     title = "CFO & Sr. VP";
     totalPay =     {
         fmt = "4.6M";
         longFmt = "4,595,583";
         raw = 4595583;
     };
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     yearBorn = 1964;
 },
 {
     age = 56;
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     fiscalYear = 2020;
     maxAge = 1;
     name = "Mr. Jeffrey E. Williams";
     title = "Chief Operating Officer";
     totalPay =     {
         fmt = "4.59M";
         longFmt = "4,594,137";
         raw = 4594137;
     };
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     yearBorn = 1964;
 },
 {
     age = 56;
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     fiscalYear = 2020;
     maxAge = 1;
     name = "Ms. Katherine L. Adams";
     title = "Sr. VP, Gen. Counsel & Sec.";
     totalPay =     {
         fmt = "4.59M";
         longFmt = "4,591,310";
         raw = 4591310;
     };
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     yearBorn = 1964;
 },
 {
     age = 53;
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     fiscalYear = 2020;
     maxAge = 1;
     name = "Ms. Deirdre  O'Brien";
     title = "Sr. VP of People & Retail";
     totalPay =     {
         fmt = "4.61M";
         longFmt = "4,614,684";
         raw = 4614684;
     };
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     yearBorn = 1967;
 },
 {
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     maxAge = 1;
     name = "Mr. Chris  Kondo";
     title = "Sr. Director of Corp. Accounting";
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
 },
 {
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     maxAge = 1;
     name = "Mr. James  Wilson";
     title = "Chief Technology Officer";
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
 },
 {
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     maxAge = 1;
     name = "Ms. Mary  Demby";
     title = "Chief Information Officer";
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
 },
 {
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     maxAge = 1;
     name = "Ms. Nancy  Paxton";
     title = "Sr. Director of Investor Relations & Treasury";
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
 },
 {
     exercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
     maxAge = 1;
     name = "Mr. Greg  Joswiak";
     title = "Sr. VP of Worldwide Marketing";
     unexercisedValue =     {
         fmt = "<null>";
         longFmt = 0;
         raw = 0;
     };
 }
 )
 , "compensationRisk": 2, "city": Cupertino, "governanceEpochDate": 1606953600, "longBusinessSummary": Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. It also sells various related services. The company offers iPhone, a line of smartphones; Mac, a line of personal computers; iPad, a line of multi-purpose tablets; and wearables, home, and accessories comprising AirPods, Apple TV, Apple Watch, Beats products, HomePod, iPod touch, and other Apple-branded and third-party accessories. It also provides AppleCare support services; cloud services store services; and operates various platforms, including the App Store, that allow customers to discover and download applications and digital content, such as books, music, video, games, and podcasts. In addition, the company offers various services, such as Apple Arcade, a game subscription service; Apple Music, which offers users a curated listening experience with on-demand radio stations; Apple News+, a subscription news and magazine service; Apple TV+, which offers exclusive original content; Apple Card, a co-branded credit card; and Apple Pay, a cashless payment service, as well as licenses its intellectual property. The company serves consumers, and small and mid-sized businesses; and the education, enterprise, and government markets. It sells and delivers third-party applications for its products through the App Store. The company also sells its products through its retail and online stores, and direct sales force; and third-party cellular network carriers, wholesalers, retailers, and resellers. Apple Inc. was founded in 1977 and is headquartered in Cupertino, California.]
 }
 */
