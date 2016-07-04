//
//  ZaifSwiftTests.swift
//  ZaifSwiftTests
//
//  Created by 渡部郷太 on 6/30/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import XCTest
@testable import ZaifSwift


private let api = PrivateApi(apiKey: key_full, secretKey: secret_full)

class ZaifSwiftTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetInfo() {
        // successfully complete
        let successExpectation = self.expectationWithDescription("get_info success")
        api.getInfo() { (err, res) in
            XCTAssertNil(err, "get_info success. err is nil")
            XCTAssertNotNil(res, "get_info success. res is not nil")
            successExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // keys has no permission for get_info
        let noPermissionExpectation = self.expectationWithDescription("no permission error")
        
        let api2 = ZaifSwift.PrivateApi(apiKey: key_no_info, secretKey: secret_no_info)
        api2.getInfo() { (err, res) in
            XCTAssertNotNil(err, "no permission. err is not nil")
            switch err!.errorType {
            case ZaifSwift.ZSErrorType.INFO_API_NO_PERMISSION:
                XCTAssertTrue(true, "no permission exception")
            default:
                XCTFail()
            }
            noPermissionExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        //invalid key
        let invalidKeyExpectaion = self.expectationWithDescription("invalid key error")
        let key_invalid = "INVALID"
        let api6 = ZaifSwift.PrivateApi(apiKey: key_invalid, secretKey: secret_full)
        api6.getInfo() { (err, res) in
            XCTAssertNotNil(err, "invalid key. err is not nil")
            switch err!.errorType {
            case ZaifSwift.ZSErrorType.INVALID_API_KEY:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            invalidKeyExpectaion.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        //invalid secret
        let invalidSecretExpectaion = self.expectationWithDescription("invalid secret error")
        let secret_invalid = "INVALID"
        let api5 = ZaifSwift.PrivateApi(apiKey: key_full, secretKey: secret_invalid)
        api5.getInfo() { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZaifSwift.ZSErrorType.INVALID_SIGNATURE:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            invalidSecretExpectaion.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // nonce exceeds limit
        let nonceExceedExpectaion = self.expectationWithDescription("nonce exceed limit error")
        let nonce = SerialNonce(initialValue: IntMax.max)
        let _ = try! nonce.getNonce()
        let api7 = PrivateApi(apiKey: key_full, secretKey: secret_full, nonce: nonce)
        api7.getInfo() { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.NONCE_EXCEED_LIMIT:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            nonceExceedExpectaion.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // nonce out of range
        let nonceOutOfRangeExpectaion = self.expectationWithDescription("nonce out of range error")
        let nonce2 = SerialNonce(initialValue: IntMax.max)
        let api8 = PrivateApi(apiKey: key_limit, secretKey: secret_limit, nonce: nonce2)
        api8.getInfo() { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.NONCE_EXCEED_LIMIT:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            nonceOutOfRangeExpectaion.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // nonce not incremented
        let nonceNotIncremented = self.expectationWithDescription("nonce not incremented error")
        let nonce3 = SerialNonce(initialValue: 1)
        let api9 = PrivateApi(apiKey: key_limit, secretKey: secret_limit, nonce: nonce3)
        api9.getInfo() { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.NONCE_NOT_INCREMENTED:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            nonceNotIncremented.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // connection error
        /*
        let connectionErrorExpectation = self.expectationWithDescription("connection error")
        let api5 = PrivateApi(apiKey: key_full, secretKey: secret_full)
        api5.getInfo() { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.CONNECTION_ERROR:
                XCTAssertTrue(true)
            default:
                XCTAssertTrue(true)
            }
            connectionErrorExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        */
    }
    
    func testTradeBtcJpy() {
        // keys has no permission for trade
        let noPermissionExpectation = self.expectationWithDescription("no permission error")
        let api_no_trade = PrivateApi(apiKey: key_no_trade, secretKey: secret_no_trade)
        let dummyOrder = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.0001)
        api_no_trade.trade(dummyOrder) { (err, res) in
            XCTAssertNotNil(err, "no permission. err is not nil")
            switch err!.errorType {
            case ZSErrorType.TRADE_API_NO_PERMISSION:
                XCTAssertTrue(true, "no permission exception")
            default:
                XCTFail()
            }
            noPermissionExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // buy btc_jpy
        let btcJpyExpectation = self.expectationWithDescription("buy btc_jpy order success")
        let btcOrder = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.0001)
        api.trade(btcOrder) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            btcJpyExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid price (border)
        let btcJpyExpectation20 = self.expectationWithDescription("btc_jpy order invalid price error")
        let btcOrder20 = Trade.Buy.Btc.In.Jpy.createOrder(5, amount: 0.0001)
        api.trade(btcOrder20) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            btcJpyExpectation20.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // buy btc_jpy with limit
        let btcJpyExpectation4 = self.expectationWithDescription("buy btc_jpy order with limit success")
        let btcOrder4 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.0001, limit: 60005)
        api.trade(btcOrder4) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            btcJpyExpectation4.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid price
        let btcJpyExpectation2 = self.expectationWithDescription("btc_jpy order invalid price error")
        let btcOrder2 = Trade.Buy.Btc.In.Jpy.createOrder(60001, amount: 0.0001)
        api.trade(btcOrder2) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid price (border)
        let btcJpyExpectation22 = self.expectationWithDescription("btc_jpy order invalid price error")
        let btcOrder22 = Trade.Buy.Btc.In.Jpy.createOrder(4, amount: 0.0001)
        api.trade(btcOrder22) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation22.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid price (minus)
        let btcJpyExpectation11 = self.expectationWithDescription("btc_jpy order invalid price error")
        let btcOrder11 = Trade.Buy.Btc.In.Jpy.createOrder(-60000, amount: 0.0001)
        api.trade(btcOrder11) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation11.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid price (zero)
        let btcJpyExpectation12 = self.expectationWithDescription("btc_jpy order invalid price error")
        let btcOrder12 = Trade.Buy.Btc.In.Jpy.createOrder(0, amount: 0.0001)
        api.trade(btcOrder12) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation12.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid limit
        let btcJpyExpectation3 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder3 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.0001, limit: 60002)
        api.trade(btcOrder3) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation3.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid limit (minus)
        let btcJpyExpectation13 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder13 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.0001, limit: -60005)
        api.trade(btcOrder13) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation13.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid limit (zero)
        let btcJpyExpectation14 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder14 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.0001, limit: 0)
        api.trade(btcOrder14) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation14.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid amount
        let btcJpyExpectation5 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder5 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.00011)
        api.trade(btcOrder5) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 0.0001")
            default:
                XCTFail()
            }
            btcJpyExpectation5.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid amount (minus)
        let btcJpyExpectation15 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder15 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: -0.0001)
        api.trade(btcOrder15) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 0.0001")
            default:
                XCTFail()
            }
            btcJpyExpectation15.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid amount (zero)
        let btcJpyExpectation16 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder16 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0)
        api.trade(btcOrder16) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 0.0001")
            default:
                XCTFail()
            }
            btcJpyExpectation16.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // sell btc_jpy
        let btcJpyExpectation6 = self.expectationWithDescription("sell btc_jpy order success")
        let btcOrder6 = Trade.Sell.Btc.For.Jpy.createOrder(80000, amount: 0.0001)
        api.trade(btcOrder6) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            btcJpyExpectation6.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // sell btc_jpy with limit
        let btcJpyExpectation7 = self.expectationWithDescription("sell btc_jpy order with limit success")
        let btcOrder7 = Trade.Sell.Btc.For.Jpy.createOrder(80000, amount: 0.0001, limit: 79995)
        api.trade(btcOrder7) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            btcJpyExpectation7.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid price
        let btcJpyExpectation8 = self.expectationWithDescription("btc_jpy order invalid price error")
        let btcOrder8 = Trade.Sell.Btc.For.Jpy.createOrder(79999, amount: 0.0001)
        api.trade(btcOrder8) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation8.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid limit
        let btcJpyExpectation9 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder9 = Trade.Buy.Btc.In.Jpy.createOrder(80000, amount: 0.0001, limit: 79998)
        api.trade(btcOrder9) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 5")
            default:
                XCTFail()
            }
            btcJpyExpectation9.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // btc_jpy invalid amount
        let btcJpyExpectation10 = self.expectationWithDescription("btc_jpy order invalid limit error")
        let btcOrder10 = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.00009)
        api.trade(btcOrder10) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 0.0001")
            default:
                XCTFail()
            }
            btcJpyExpectation10.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testTradeMonaJpy() {
        // buy mona_jpy
        let monaJpyExpectation = self.expectationWithDescription("buy mona_jpy order success")
        let monaOrder = Trade.Buy.Mona.In.Jpy.createOrder(4.0, amount: 1)
        api.trade(monaOrder) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaJpyExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid price (min)
        let monaJpyExpectation60 = self.expectationWithDescription("mona_jpy order invalid price error")
        let monaOrder60 = Trade.Buy.Mona.In.Jpy.createOrder(0.1, amount: 1)
        api.trade(monaOrder60) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaJpyExpectation60.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // buy mona_jpy with limit
        let monaJpyExpectation2 = self.expectationWithDescription("buy mona_jpy order with limit success")
        let monaOrder2 = Trade.Buy.Mona.In.Jpy.createOrder(4.0, amount: 1, limit: 4.1)
        api.trade(monaOrder2) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaJpyExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid price
        let monaJpyExpectation3 = self.expectationWithDescription("mona_jpy order invalid price error")
        let monaOrder3 = Trade.Buy.Mona.In.Jpy.createOrder(4.01, amount: 1)
        api.trade(monaOrder3) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation3.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid price (border)
        let monaJpyExpectation34 = self.expectationWithDescription("mona_jpy order invalid price error")
        let monaOrder34 = Trade.Buy.Mona.In.Jpy.createOrder(0.09, amount: 1)
        api.trade(monaOrder34) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation34.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid price (minus)
        let monaJpyExpectation33 = self.expectationWithDescription("mona_jpy order invalid price error")
        let monaOrder33 = Trade.Buy.Mona.In.Jpy.createOrder(-4.0, amount: 1)
        api.trade(monaOrder33) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation33.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid price (zero)
        let monaJpyExpectation7 = self.expectationWithDescription("mona_jpy order invalid price error")
        let monaOrder7 = Trade.Buy.Mona.In.Jpy.createOrder(0, amount: 1)
        api.trade(monaOrder7) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation7.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid limit
        let monaJpyExpectation4 = self.expectationWithDescription("mona_jpy order invalid limit error")
        let monaOrder4 = Trade.Buy.Mona.In.Jpy.createOrder(4.0, amount: 1, limit: 3.99)
        api.trade(monaOrder4) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation4.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid limit (minus)
        let monaJpyExpectation8 = self.expectationWithDescription("mona_jpy order invalid limit error")
        let monaOrder8 = Trade.Buy.Mona.In.Jpy.createOrder(4.0, amount: 1, limit: -4.1)
        api.trade(monaOrder8) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation8.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid limit (zero)
        let monaJpyExpectation9 = self.expectationWithDescription("mona_jpy order invalid limit error")
        let monaOrder9 = Trade.Buy.Mona.In.Jpy.createOrder(4.0, amount: 1, limit: 0)
        api.trade(monaOrder9) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation9.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid amount (minus)
        let monaJpyExpectation10 = self.expectationWithDescription("mona_jpy order invalid limit error")
        let monaOrder10 = Trade.Buy.Mona.In.Jpy.createOrder(4.2, amount: -1)
        api.trade(monaOrder10) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 1")
            default:
                XCTFail()
            }
            monaJpyExpectation10.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid amount (zero)
        let monaJpyExpectation5 = self.expectationWithDescription("mona_jpy order invalid limit error")
        let monaOrder5 = Trade.Buy.Mona.In.Jpy.createOrder(4.2, amount: 0)
        api.trade(monaOrder5) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 1")
            default:
                XCTFail()
            }
            monaJpyExpectation5.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // sell mona_jpy
        let monaJpyExpectation11 = self.expectationWithDescription("sell mona_jpy order success")
        let monaOrder11 = Trade.Sell.Mona.For.Jpy.createOrder(6.0, amount: 1)
        api.trade(monaOrder11) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaJpyExpectation11.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // sell mona_jpy with limit
        let monaJpyExpectation12 = self.expectationWithDescription("sell mona_jpy order with limit success")
        let monaOrder12 = Trade.Sell.Mona.For.Jpy.createOrder(6.0, amount: 1, limit: 5.9)
        api.trade(monaOrder12) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaJpyExpectation12.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid price
        let monaJpyExpectation13 = self.expectationWithDescription("mona_jpy order invalid price error")
        let monaOrder13 = Trade.Sell.Mona.For.Jpy.createOrder(6.01, amount: 1)
        api.trade(monaOrder13) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation13.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid limit
        let monaJpyExpectation14 = self.expectationWithDescription("mona_jpy order invalid limit error")
        let monaOrder14 = Trade.Sell.Mona.For.Jpy.createOrder(6.0, amount: 1, limit: 3.91)
        api.trade(monaOrder14) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.1")
            default:
                XCTFail()
            }
            monaJpyExpectation14.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_jpy invalid amount
        let monaJpyExpectation15 = self.expectationWithDescription("mona_jpy order invalid limit error")
        let monaOrder15 = Trade.Sell.Mona.For.Jpy.createOrder(6.2, amount: 0)
        api.trade(monaOrder15) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 1")
            default:
                XCTFail()
            }
            monaJpyExpectation15.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testTradeMonaBtc() {
        // buy mona_btc
        let monaBtcExpectation = self.expectationWithDescription("buy mona_btc order success")
        let monaOrder = Trade.Buy.Mona.In.Btc.createOrder(0.00000321, amount: 1)
        api.trade(monaOrder) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaBtcExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // buy mona_btc (min)
        let monaBtcExpectation22 = self.expectationWithDescription("buy mona_btc order success")
        let monaOrder22 = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: 1)
        api.trade(monaOrder22) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaBtcExpectation22.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // buy mona_btc with limit
        let monaBtcExpectation2 = self.expectationWithDescription("buy mona_btc order with limit success")
        let monaOrder2 = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: 1, limit: 0.00010001)
        api.trade(monaOrder2) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaBtcExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid price
        let monaBtcExpectation3 = self.expectationWithDescription("mona_btc order invalid price error")
        let monaOrder3 = Trade.Buy.Mona.In.Btc.createOrder(0.000000009, amount: 1)
        api.trade(monaOrder3) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation3.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid price (border)
        let monaBtcExpectation44 = self.expectationWithDescription("mona_btc order invalid price error")
        let monaOrder44 = Trade.Buy.Mona.In.Btc.createOrder(0.000000009, amount: 1)
        api.trade(monaOrder44) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation44.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid price (minus)
        let monaBtcExpectation4 = self.expectationWithDescription("mona_btc order invalid price error")
        let monaOrder4 = Trade.Buy.Mona.In.Btc.createOrder(-0.00000001, amount: 1)
        api.trade(monaOrder4) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation4.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid price (zero)
        let monaBtcExpectation5 = self.expectationWithDescription("mona_btc order invalid price error")
        let monaOrder5 = Trade.Buy.Mona.In.Btc.createOrder(0, amount: 1)
        api.trade(monaOrder5) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation5.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid limit
        let monaBtcExpectation6 = self.expectationWithDescription("mona_btc order invalid limit error")
        let monaOrder6 = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: 1, limit: 0.000000019)
        api.trade(monaOrder6) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation6.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid limit (minus)
        let monaBtcExpectation7 = self.expectationWithDescription("mona_btc order invalid limit error")
        let monaOrder7 = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: 1, limit: -0.00000002)
        api.trade(monaOrder7) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation7.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid limit (zero)
        let monaBtcExpectation8 = self.expectationWithDescription("mona_btc order invalid limit error")
        let monaOrder8 = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: 1, limit: 0)
        api.trade(monaOrder8) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation8.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid amount (minus)
        let monaBtcExpectation10 = self.expectationWithDescription("mona_btc order invalid limit error")
        let monaOrder10 = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: -1)
        api.trade(monaOrder10) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 1")
            default:
                XCTFail()
            }
            monaBtcExpectation10.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid amount (zero)
        let monaBtcExpectation55 = self.expectationWithDescription("mona_btc order invalid limit error")
        let monaOrder55 = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: 0)
        api.trade(monaOrder55) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 1")
            default:
                XCTFail()
            }
            monaBtcExpectation55.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // sell mona_btc
        let monaBtcExpectation32 = self.expectationWithDescription("sell mona_btc order success")
        let monaOrder32 = Trade.Sell.Mona.For.Btc.createOrder(6.0, amount: 1)
        api.trade(monaOrder32) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaBtcExpectation32.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // sell mona_btc with limit
        let monaBtcExpectation19 = self.expectationWithDescription("sell mona_btc order with limit success")
        let monaOrder19 = Trade.Sell.Mona.For.Btc.createOrder(6.0, amount: 1, limit: 5.9)
        api.trade(monaOrder19) { (err, res) in
            XCTAssertNil(err)
            XCTAssertNotNil(res)
            monaBtcExpectation19.fulfill()
        }
        self.waitForExpectationsWithTimeout(10.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid price
        let monaBtcExpectation40 = self.expectationWithDescription("mona_btc order invalid price error")
        let monaOrder40 = Trade.Sell.Mona.For.Btc.createOrder(0.000000019, amount: 1)
        api.trade(monaOrder40) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "price unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation40.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid limit
        let monaBtcExpectation64 = self.expectationWithDescription("mona_btc order invalid limit error")
        let monaOrder64 = Trade.Sell.Mona.For.Btc.createOrder(6.0, amount: 1, limit: 0.000000009)
        api.trade(monaOrder64) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "limit unit must be 0.00000001")
            default:
                XCTFail()
            }
            monaBtcExpectation64.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // mona_btc invalid amount
        let monaBtcExpectation54 = self.expectationWithDescription("mona_btc order invalid limit error")
        let monaOrder54 = Trade.Sell.Mona.For.Jpy.createOrder(6.2, amount: 0)
        api.trade(monaOrder54) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.INVALID_ORDER(let message):
                XCTAssertEqual(message, "amount unit must be 1")
            default:
                XCTFail()
            }
            monaBtcExpectation54.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testHistory() {
        // query using 'from' and 'count'. 'from' minus value
        let fromQueryExpectation2 = self.expectationWithDescription("query using 'from' and 'count'")
        let query2 = HistoryQuery(from: -1, count: 10)
        api.tradeHistory(query2) { (err, res) in
                XCTAssertNotNil(err)
                switch err!.errorType {
                case ZSErrorType.PROCESSING_ERROR:
                    XCTAssertTrue(true)
                default:
                    XCTFail()
                }
            fromQueryExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'from' zero value
        let fromQueryExpectation3 = self.expectationWithDescription("query using 'from' and 'count'")
        let query3 = HistoryQuery(from: 0, count: 10)
        api.tradeHistory(query3) { (err, res) in
            //print(res)
            XCTAssertEqual(res!["return"].dictionary?.count, 10)
            fromQueryExpectation3.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'from' valid value
        let fromQueryExpectation = self.expectationWithDescription("query using 'from' and 'count'")
        let query = HistoryQuery(from: 1, count: 10)
        api.tradeHistory(query) { (err, res) in
            //print(res)
            XCTAssertEqual(res!["return"].dictionary?.count, 10)
            fromQueryExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'from' valid value
        let fromQueryExpectation4 = self.expectationWithDescription("query using 'from' and 'count'")
        let query4 = HistoryQuery(from: 10, count: 10)
        api.tradeHistory(query4) { (err, res) in
            //print(res)
            XCTAssertEqual(res!["return"].dictionary?.count, 10)
            fromQueryExpectation4.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'from' not specified
        let fromQueryExpectation41 = self.expectationWithDescription("query using 'from' and 'count'")
        let query41 = HistoryQuery(count: 10)
        api.tradeHistory(query41) { (err, res) in
            //print(res)
            XCTAssertEqual(res!["return"].dictionary?.count, 10)
            fromQueryExpectation41.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'count' minus value
        let fromQueryExpectation5 = self.expectationWithDescription("query using 'from' and 'count'")
        let query5 = HistoryQuery(from: 0, count: -1)
        api.tradeHistory(query5) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.PROCESSING_ERROR:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            fromQueryExpectation5.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'count' zero value
        let fromQueryExpectation6 = self.expectationWithDescription("query using 'from' and 'count'")
        let query6 = HistoryQuery(from: 0, count: 0)
        api.tradeHistory(query6) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.PROCESSING_ERROR:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            fromQueryExpectation6.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'count' valid value
        let fromQueryExpectation7 = self.expectationWithDescription("query using 'from' and 'count'")
        let query7 = HistoryQuery(from: 1, count: 1)
        api.tradeHistory(query7) { (err, res) in
            //print(res)
            XCTAssertNil(err)
            XCTAssertEqual(res!["return"].dictionary?.count, 1)
            fromQueryExpectation7.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'count' valid value
        let fromQueryExpectation8 = self.expectationWithDescription("query using 'from' and 'count'")
        let query8 = HistoryQuery(from: 1, count: 2)
        api.tradeHistory(query8) { (err, res) in
            //print(res)
            XCTAssertEqual(res!["return"].dictionary?.count, 2)
            fromQueryExpectation8.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from' and 'count'. 'count' not specified
        let fromQueryExpectation9 = self.expectationWithDescription("query using 'from' and 'count'")
        let query9 = HistoryQuery(from: 1, count: 2)
        api.tradeHistory(query9) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            fromQueryExpectation9.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        
        // query using 'from_id' and 'end_id'
        let idQueryExpectation = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery = HistoryQuery(fromId: 6915724, endId: 7087911)
        api.tradeHistory(idQuery) { (err, res) in
            //print(res)
            XCTAssertEqual(res!["return"].dictionary?.count, 8)
            idQueryExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from_id' and 'end_id'. 'from_id' minus value
        let idQueryExpectation2 = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery2 = HistoryQuery(fromId: -1, endId: 7087911)
        api.tradeHistory(idQuery2) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.PROCESSING_ERROR:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            idQueryExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from_id' and 'end_id'. 'from_id' 0 value
        let idQueryExpectation3 = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery3 = HistoryQuery(fromId: 0, endId: 7087911)
        api.tradeHistory(idQuery3) { (err, res) in
            XCTAssertNil(err)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            idQueryExpectation3.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from_id' and 'end_id'. 'from_id' not specified
        let idQueryExpectation4 = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery4 = HistoryQuery(endId: 7087911)
        api.tradeHistory(idQuery4) { (err, res) in
            XCTAssertNil(err)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            idQueryExpectation4.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        
        // query using 'from_id' and 'end_id'. 'end_id' minus value
        let idQueryExpectation5 = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery5 = HistoryQuery(fromId: 6915724, endId: -1)
        api.tradeHistory(idQuery5) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.PROCESSING_ERROR:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            idQueryExpectation5.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from_id' and 'end_id'. 'end_id' zero value
        let idQueryExpectation6 = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery6 = HistoryQuery(fromId: 6915724, endId: 0)
        api.tradeHistory(idQuery6) { (err, res) in
            XCTAssertNil(err)
            //print(res)
            let noEntry = res!["return"].dictionary?.count == 0
            XCTAssertTrue(noEntry)
            idQueryExpectation6.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from_id' and 'end_id'. 'end_id' not specified
        let idQueryExpectation7 = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery7 = HistoryQuery(fromId: 6915724)
        api.tradeHistory(idQuery7) { (err, res) in
            XCTAssertNil(err)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            idQueryExpectation7.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'from_id' and 'end_id'. 'end_id' is greater than 'from_id'
        let idQueryExpectation8 = self.expectationWithDescription("query using 'from_id' and 'end_id'")
        let idQuery8 = HistoryQuery(fromId: 7087911 , endId: 6915724)
        api.tradeHistory(idQuery8) { (err, res) in
            XCTAssertNil(err)
            //print(res)
            let noEntry = res!["return"].dictionary?.count == 0
            XCTAssertTrue(noEntry)
            idQueryExpectation8.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        
        // query using 'since' and 'end'
        let sinceQueryExpectation = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery = HistoryQuery(since: 1467014263, end: 1467540926)
        api.tradeHistory(sinceQuery) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            sinceQueryExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'since' minus value
        let sinceQueryExpectation2 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery2 = HistoryQuery(since: -1, end: 1467540926)
        api.tradeHistory(sinceQuery2) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.PROCESSING_ERROR:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            sinceQueryExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'since' zero value
        let sinceQueryExpectation3 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery3 = HistoryQuery(since: 0, end: 1467540926)
        api.tradeHistory(sinceQuery3) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            sinceQueryExpectation3.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'since' valid value
        let sinceQueryExpectation4 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery4 = HistoryQuery(since: 1, end: 1467540926)
        api.tradeHistory(sinceQuery4) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            sinceQueryExpectation4.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'since' not spcified
        let sinceQueryExpectation5 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery5 = HistoryQuery(end: 1467540926)
        api.tradeHistory(sinceQuery5) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            sinceQueryExpectation5.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'end' minus value
        let sinceQueryExpectation6 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery6 = HistoryQuery(since: 1467014263, end: -1)
        api.tradeHistory(sinceQuery6) { (err, res) in
            XCTAssertNotNil(err)
            switch err!.errorType {
            case ZSErrorType.PROCESSING_ERROR:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
            sinceQueryExpectation6.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'end' zero value
        let sinceQueryExpectation7 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery7 = HistoryQuery(since: 1467014263, end: 0)
        api.tradeHistory(sinceQuery7) { (err, res) in
            //print(res)
            let noEntry = res!["return"].dictionary?.count == 0
            XCTAssertTrue(noEntry)
            sinceQueryExpectation7.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'end' valid value
        let sinceQueryExpectation8 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery8 = HistoryQuery(since: 1467014263, end: 1)
        api.tradeHistory(sinceQuery8) { (err, res) in
            //print(res)
            let noEntry = res!["return"].dictionary?.count == 0
            XCTAssertTrue(noEntry)
            sinceQueryExpectation8.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'end' not specified
        let sinceQueryExpectation9 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery9 = HistoryQuery(since: 1467014263)
        api.tradeHistory(sinceQuery9) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            sinceQueryExpectation9.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query using 'since' and 'end'. 'since' is greater than 'end'
        let sinceQueryExpectation10 = self.expectationWithDescription("query using 'since' and 'end'")
        let sinceQuery10 = HistoryQuery(since: 1467540926, end: 1467014263)
        api.tradeHistory(sinceQuery10) { (err, res) in
            //print(res)
            let noEntry = res!["return"].dictionary?.count == 0
            XCTAssertTrue(noEntry)
            sinceQueryExpectation10.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        usleep(200)
        
        // query for btc_jpy. asc order
        let btcQueryExpectation = self.expectationWithDescription("query for btc_jpy")
        let btcQuery = HistoryQuery(currencyPair: .BTC_JPY, order: .ASC)
        api.tradeHistory(btcQuery) { (err, res) in
            print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            let pair = res!["return"].dictionary?.first?.1["currency_pair"].stringValue
            XCTAssertEqual(pair, "btc_jpy")
            btcQueryExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        // query for btc_jpy. desc order
        let btcQueryExpectation2 = self.expectationWithDescription("query for btc_jpy")
        let btcQuery2 = HistoryQuery(currencyPair: .BTC_JPY, order: .DESC)
        api.tradeHistory(btcQuery2) { (err, res) in
            print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            let pair = res!["return"].dictionary?.first?.1["currency_pair"].stringValue
            XCTAssertEqual(pair, "btc_jpy")
            btcQueryExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        // query for mona_jpy. asc order
        let monaQueryExpectation = self.expectationWithDescription("query for mona_jpy")
        let monaQuery = HistoryQuery(currencyPair: .MONA_JPY, order: .ASC)
        api.tradeHistory(monaQuery) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            let pair = res!["return"].dictionary?.first?.1["currency_pair"].stringValue
            XCTAssertEqual(pair, "mona_jpy")
            monaQueryExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        // query for mona_jpy. desc order
        let monaQueryExpectation2 = self.expectationWithDescription("query for mona_jpy")
        let monaQuery2 = HistoryQuery(currencyPair: .MONA_JPY, order: .DESC)
        api.tradeHistory(monaQuery2) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            let pair = res!["return"].dictionary?.first?.1["currency_pair"].stringValue
            XCTAssertEqual(pair, "mona_jpy")
            monaQueryExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        // query for mona_btc. asc order
        let monaBtcQueryExpectation = self.expectationWithDescription("query for mona_btc")
        let monaBtcQuery = HistoryQuery(currencyPair: .MONA_BTC, order: .ASC)
        api.tradeHistory(monaBtcQuery) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            let pair = res!["return"].dictionary?.first?.1["currency_pair"].stringValue
            XCTAssertEqual(pair, "mona_btc")
            monaBtcQueryExpectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
        
        // query for mona_btc. desc order
        let monaBtcQueryExpectation2 = self.expectationWithDescription("query for mona_btc")
        let monaBtcQuery2 = HistoryQuery(currencyPair: .MONA_BTC, order: .DESC)
        api.tradeHistory(monaBtcQuery2) { (err, res) in
            //print(res)
            let hasEntry = res!["return"].dictionary?.count > 0
            XCTAssertTrue(hasEntry)
            let pair = res!["return"].dictionary?.first?.1["currency_pair"].stringValue
            XCTAssertEqual(pair, "mona_btc")
            monaBtcQueryExpectation2.fulfill()
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    
    func testSerialNonce() {
        // invalid initial value test
        var nonce = SerialNonce(initialValue: -1)
        var value = try! nonce.getNonce()
        XCTAssertEqual(value, "1", "initial value -1")
        value = try! nonce.getNonce()
        XCTAssertEqual(value, "2", "initial value -1, 1 increment")
        
        nonce = SerialNonce(initialValue: 0)
        value = try! nonce.getNonce()
        XCTAssertEqual(value, "1", "initial value 0")
        value = try! nonce.getNonce()
        XCTAssertEqual(value, "2", "initial value 0, 1 increment")
        
        // valid initial value test
        nonce = SerialNonce(initialValue: 1)
        value = try! nonce.getNonce()
        XCTAssertEqual(value, "1", "initial value 1")
        value = try! nonce.getNonce()
        XCTAssertEqual(value, "2", "initial value 1, 1 increment")
        
        nonce = SerialNonce(initialValue: 2)
        value = try! nonce.getNonce()
        XCTAssertEqual(value, "2", "initial value 2")
        value = try! nonce.getNonce()
        XCTAssertEqual(value, "3", "initial value 2, 1 increment")
        
        // max initial value test
        nonce = SerialNonce(initialValue: IntMax.max)
        value = try! nonce.getNonce()
        XCTAssertEqual(value, IntMax.max.description, "initial value max")
        XCTAssertThrowsError(try nonce.getNonce()) { (error) in
            switch error as! ZSErrorType {
            case .NONCE_EXCEED_LIMIT:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        }
    }
    
    func testTimeNonce() {
        let nonce = TimeNonce()
        var prev = try! nonce.getNonce()
        sleep(1)
        var cur = try! nonce.getNonce()
        XCTAssertTrue(Int64(prev) < Int64(cur), "one request in a second")
        prev = cur
        sleep(2)
        cur = try! nonce.getNonce()
        XCTAssertTrue(Int64(prev) < Int64(cur), "one request in a second")
        prev = cur
        
        var count = 10
        while count > 0 {
            cur = try! nonce.getNonce()
            XCTAssertTrue(Int64(prev) < Int64(cur), "multiple request in a second")
            prev = cur
            if Int64(cur) == IntMax.max {
                break
            }
            count -= 1
        }
        /*
        XCTAssertThrowsError(try nonce.getNonce()) { (error) in
            switch error as! ZSErrorType {
            case .NONCE_EXCEED_LIMIT:
                XCTAssertTrue(true)
            default:
                XCTFail()
            }
        }
        */
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
