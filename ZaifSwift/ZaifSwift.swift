//
//  ZaifSwift.swift
//  ZaifSwift
//
//  Created by 渡部郷太 on 6/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
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
    
    open var apiKey: String {
        get {
            return self.keys.apiKey
        }
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


