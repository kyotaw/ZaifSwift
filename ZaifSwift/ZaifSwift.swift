//
//  ZaifSwift.swift
//  ZaifSwift
//
//  Created by Kyota Watanabe on 6/24/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation

import SwiftyJSON


public enum Currency : String {
    case BTC = "btc"
    case JPY = "jpy"
    case MONA = "mona"
    case XEM = "xem"
}

public enum CurrencyPair : String {
    case BTC_JPY = "btc_jpy"
    case MONA_JPY = "mona_jpy"
    case MONA_BTC = "mona_btc"
    case XEM_JPY = "xem_jpy"
    
    public var orderUnit: Double {
        switch self {
        case .BTC_JPY: return 0.0001
        case .MONA_JPY: return 0.1
        case .MONA_BTC: return 0.00000001
        case .XEM_JPY: return 0.1
        }
    }
}

public enum OrderAction : String {
    case ASK = "ask"
    case BID = "bid"
}

public typealias ZSCallback = ((_ err: ZSError?, _ res: JSON?) -> Void)


open class PrivateApi {
    
    public init(apiKey: String, secretKey: String, nonce: NonceProtocol?=nil) {
        self.keys = ApiKeys(apiKey: apiKey, secretKey: secretKey)
        if let n = nonce {
            self.nonce = n
        } else {
            self.nonce = TimeNonce()
        }
    }
    
    open func getInfo(_ callback: @escaping ZSCallback) {
        PrivateResource.getInfo(self.keys, nonce: self.nonce, callback: callback)
    }
    
    open func getInfo2(_ callback: @escaping ZSCallback) {
        PrivateResource.getInfo2(self.keys, nonce: self.nonce, callback: callback)
    }
    
    open func trade(_ order: Order, validate: Bool=true, callback: @escaping ZSCallback) {
        do {
            if validate {
                try order.valid()
            }
            order.execute(self.keys, nonce: self.nonce, callback: callback)
        } catch ZSErrorType.INVALID_ORDER(let message) {
            callback(ZSError(errorType: .INVALID_ORDER(message: message), message: message), nil)
        } catch {
            callback(ZSError(errorType: .UNKNOWN_ERROR), nil)
        }
    }
    
    open func tradeHistory(_ query: HistoryQuery, callback: @escaping ZSCallback) {
        PrivateResource.tradeHistory(self.keys, nonce: self.nonce, query: query, callback: callback)
    }
    
    open func activeOrders(_ currencyPair: CurrencyPair?=nil, callback: @escaping ZSCallback) {
        PrivateResource.activeOrders(self.keys, nonce: self.nonce, currencyPair: currencyPair, callback: callback)
    }
    
    open func cancelOrder(_ orderId: Int, callback: @escaping ZSCallback) {
        PrivateResource.cancelOrder(self.keys, nonce: self.nonce, orderId: orderId, callback: callback)
    }
    
    open func searchValidNonce(count: Int=10, step: Int=100, callback: @escaping (ZSError?) -> Void) {
        self.getInfo2() { (err, _) in
            if let e = err {
                switch e.errorType {
                case .NONCE_NOT_INCREMENTED:
                    do {
                        try self.nonce.countUp(value: step)
                    } catch {
                        callback(e)
                    }
                    if count == 0 {
                        callback(e)
                    } else {
                        sleep(1)
                        self.searchValidNonce(count: count - 1, callback: callback)
                    }
                default:
                    callback(e)
                }
                
            } else {
                callback(nil)
            }
        }
    }
    
    open var apiKey: String {
        get { return self.keys.apiKey }
    }
    
    open var secretKey: String {
        get { return self.keys.secretKey }
    }
    
    open var nonceValue: Int64 {
        get { return self.nonce.currentValue }
    }
    
    fileprivate let keys: ApiKeys
    fileprivate let nonce: NonceProtocol!
}

open class PublicApi {
    
    open static func lastPrice(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        PublicResource.lastPrice(currencyPair, callback: callback)
    }

    open static func ticker(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        PublicResource.ticker(currencyPair, callback: callback)
    }
    
    open static func trades(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        PublicResource.trades(currencyPair, callback: callback)
    }
    
    open static func depth(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        PublicResource.depth(currencyPair, callback: callback)
    }
}

open class StreamingApi {
    
    open static func stream(_ currencyPair: CurrencyPair, openCallback: @escaping ZSCallback) -> Stream {
        return StreamingResource.stream(currencyPair, openCallback: openCallback)
    }
    
}

internal struct ApiKeys {
    internal init(apiKey: String, secretKey: String) {
        self.apiKey = apiKey
        self.secretKey = secretKey
    }
    
    internal let apiKey: String
    internal let secretKey: String
}


