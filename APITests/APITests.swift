//
//  APITests.swift
//  APITests
//
//  Created by Nikolay Kryuchkov on 06.09.2021.
//

import XCTest

@testable import YaMDS

class APITests: XCTestCase {

    var sut: StockAPIData!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = StockAPIData()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testStockBasicLoad() {
        let promise = expectation(description: "API OK")
        sut.loadPricesFromAPI { (dict, alert) in
            if alert != nil {
                XCTFail("Error on API requests")
            }
            promise.fulfill()
        }
        wait(for: [promise], timeout: 5)
    }

}
