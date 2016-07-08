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

public typealias ZSCallback = ((err: ZSError?, res: JSON?) -> Void)


public class PrivateApi {
    
    public init(apiKey: String, secretKey: String, nonce: NonceProtocol?=nil) {
        self.keys = ApiKeys(apiKey: apiKey, secretKey: secretKey)
        if let n = nonce {
            self.nonce = n
        } else {
            self.nonce = TimeNonce()
        }
    }
    
    public func getInfo(callback: ZSCallback) {
        PrivateResource.getInfo(self.keys, nonce: self.nonce, callback: callback)
    }
    
    public func trade(order: Order, callback: ZSCallback) {
        do {
            try order.valid()
            order.execute(self.keys, nonce: self.nonce, callback: callback)
        } catch ZSErrorType.INVALID_ORDER(let message) {
            callback(err: ZSError(errorType: .INVALID_ORDER(message: message), message: message), res: nil)
        } catch {
            callback(err: ZSError(errorType: .UNKNOWN_ERROR), res: nil)
        }
    }
    
    public func tradeHistory(query: HistoryQuery, callback: ZSCallback) {
        PrivateResource.tradeHistory(self.keys, nonce: self.nonce, query: query, callback: callback)
    }
    
    public func activeOrder(currencyPair: CurrencyPair?=nil, callback: ZSCallback) {
        PrivateResource.activeOrders(self.keys, nonce: self.nonce, currencyPair: currencyPair, callback: callback)
    }
    
    private let keys: ApiKeys
    private let nonce: NonceProtocol!
}

public class PublicApi {
    
    public static func lastPrice(currencyPair: CurrencyPair, callback: ZSCallback) {
        PublicResource.lastPrice(currencyPair, callback: callback)
    }

    public static func ticker(currencyPair: CurrencyPair, callback: ZSCallback) {
        PublicResource.ticker(currencyPair, callback: callback)
    }
    
    public static func trades(currencyPair: CurrencyPair, callback: ZSCallback) {
        PublicResource.trades(currencyPair, callback: callback)
    }
    
    public static func depth(currencyPair: CurrencyPair, callback: ZSCallback) {
        PublicResource.depth(currencyPair, callback: callback)
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


