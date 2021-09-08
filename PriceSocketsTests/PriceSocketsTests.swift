//
//  PriceSocketsTests.swift
//  PriceSocketsTests
//
//  Created by Nikolay Kryuchkov on 06.09.2021.
//

import XCTest
import Starscream

@testable import YaMDS

class PriceSocketsTests: XCTestCase {

    var sut: PriceSocket!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = PriceSocket()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testSocketConnects() throws {
        // given
        let socket = sut.webSocket

        //when
        socket.connect()

        //then
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            XCTAssertTrue(self.sut.isConnected, "No connection for WebSocket")
        }
    }

    func testSocketDidReceiveEvent() throws {
        // given
        let event = WebSocketEvent.connected([:])

        //when
        sut.didReceive(event: event, client: sut.webSocket)

        //then
        XCTAssertTrue(self.sut.isConnected, "No connection for WebSocket")
    }

    func testSocketSubsribes() throws {
        // given
        let ticker = ["AAPL"]

        //when
        sut.startWebSocket(tickerArray: ticker)

        //then
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            XCTAssertTrue(self.sut.isConnected, "No subscribe for WebSocket")
        }
    }

}
