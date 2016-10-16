//
//  Trade.swift
//  ZaifSwift
//
//  Created by 渡部郷太 on 6/26/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


public class Trade {
    public class Buy {
        public class Btc {
            public class In {
                public class Jpy {
                    public static func createOrder(_ price: Int?, amount: Double, limit: Int?=nil) -> Order {
                        return BuyBtcInJpyOrder(price: price, amount: amount, limit: limit) as Order
                    }
                    init(){
                    }
                }
                init(){
                }
            }
            init(){
            }
        }
        public class Mona {
            public class In {
                public class Jpy {
                    public static func createOrder(_ price: Double?, amount: Int, limit: Double?=nil) -> Order {
                        return BuyMonaInJpyOrder(price: price, amount: amount, limit: limit) as Order
                    }
                    init(){
                    }
                }
                public class Btc {
                    public static func createOrder(_ price: Double?, amount: Int, limit: Double?=nil) -> Order {
                        return BuyMonaInBtcOrder(price: price, amount: amount, limit: limit) as Order
                    }
                }
                init(){
                }
            }
            init(){
            }
        }
        init(){
        }
    }
    
    public class Sell {
        public class Btc {
            public class For {
                public class Jpy {
                    public static func createOrder(_ price: Int?, amount: Double, limit: Int?=nil) -> Order {
                        return SellBtcForJpyOrder(price: price, amount: amount, limit: limit) as Order
                    }
                }
            }
        }
        public class Mona {
            public class For {
                public class Jpy {
                    public static func createOrder(_ price: Double?, amount: Int, limit: Double?=nil) -> Order {
                        return SellMonaForJpyOrder(price: price, amount: amount, limit: limit) as Order
                    }
                }
                public class Btc {
                    public static func createOrder(_ price: Double?, amount: Int, limit: Double?=nil) -> Order {
                        return SellMonaForBtcOrder(price: price, amount: amount, limit: limit) as Order
                    }
                }
            }
        }
        init(){
        }
    }
    init(){
    }
}


public class Order {
    internal init(currencyPair: CurrencyPair, action: OrderAction, price: Double?, amount: Double, limit: Double?=nil) {
        self.currencyPair = currencyPair
        self.action = action
        self.price = price
        self.amount = amount
        self.limit = limit
    }
    
    internal func execute(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        if self.price != nil {
            PrivateResource.trade(apiKeys, nonce: nonce, order: self, callback: callback)
        } else {
            self.marketOrder(apiKeys, nonce: nonce, callback: callback)
        }
    }
    
    internal func valid() throws {
        if let p = self.price {
            if p <= 0.0 {
                throw ZSErrorType.INVALID_ORDER(message: "invalid price")
            }
            
        }
        if let l = self.limit {
            if l <= 0 {
                throw ZSErrorType.INVALID_ORDER(message: "invalid limit")
            }
        }
        if self.amount <= 0 {
            throw ZSErrorType.INVALID_ORDER(message: "invalid amount")
        }
    }
    
    internal func marketOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        callback(ZSError(errorType: .UNKNOWN_ERROR, message: "not implemented"), nil)
    }
    
    var priceString: String {
        get {
            if let p = self.price {
                return p.description
            } else {
                return ""
            }
        }
    }
    var amountString: String { get { return self.amount.description } }
    var limitString: String? { get { return self.limit == nil ? nil : self.limit!.description } }
    
    public let currencyPair: CurrencyPair
    public let action: OrderAction
    public let price: Double?
    public let amount: Double
    public let limit: Double?
}

public class BtcJpyOrder : Order {
    public init(action: OrderAction, price: Int?, amount: Double, limit: Int?=nil) {
        super.init(currencyPair: .BTC_JPY, action: action, price: price == nil ? nil : Double(price!), amount: amount, limit: limit == nil ? nil : Double(limit!))
    }
    
    internal override func valid() throws {
        if let p = self.price {
            let priceRem = Int(p) % 5
            if priceRem != 0 || p <= 0 {
                throw ZSErrorType.INVALID_ORDER(message: "price unit must be 5")
            }
        }
        
        if let l = self.limit {
            let limitRem = Int(l) % 5
            
            if limitRem != 0 || l <= 0 {
                throw ZSErrorType.INVALID_ORDER(message: "limit unit must be 5")
            }
        }
        let amount10000 = self.amount * 10000
        if amount10000 - Double(Int(amount10000)) != 0 || self.amount <= 0 {
            throw ZSErrorType.INVALID_ORDER(message: "amount unit must be 0.0001")
        }
    }
    
    override var priceString: String {
        get {
            if let p = self.price {
                return Int(p).description
            } else {
                return ""
            }
        }
    }
    override var limitString: String? { get { return self.limit == nil ? nil : Int(self.limit!).description } }
}

public class MonaJpyOrder : Order {
    public init(action: OrderAction, price: Double?, amount: Int, limit: Double?=nil) {
        super.init(currencyPair: .MONA_JPY, action: action, price: price, amount: Double(amount), limit: limit)
    }
    
    internal override func valid() throws {
        if let p = self.price {
            let price10 = p * 10
            if price10 - Double(Int(price10)) != 0 || p <= 0 {
                throw ZSErrorType.INVALID_ORDER(message: "price unit must be 0.1")
            }
        }
        
        if let l = self.limit {
            let l10 = l * 10
            if l10 - Double(Int(l10)) != 0 || l <= 0 {
                throw ZSErrorType.INVALID_ORDER(message: "limit unit must be 0.1")
            }
        }
        if self.amount - Double(Int(self.amount)) != 0 || self.amount <= 0 {
            throw ZSErrorType.INVALID_ORDER(message: "amount unit must be 1")
        }
    }
    
    override var amountString: String { get { return Int(self.amount).description } }
}

public class MonaBtcOrder : Order {
    public init(action: OrderAction, price: Double?, amount: Int, limit: Double?=nil) {
        super.init(currencyPair: .MONA_BTC, action: action, price: price, amount: Double(amount), limit: limit)
    }
    
    internal override func valid() throws {
        if let p = self.price {
            let price100000000 = p * 100000000
            if price100000000 - Double(Int(price100000000)) != 0 || p <= 0 {
                throw ZSErrorType.INVALID_ORDER(message: "price unit must be 0.00000001")
            }
        }
        
        if let l = self.limit {
            let l100000000 = l * 100000000
            if l100000000 - Double(Int(l100000000)) != 0 || l <= 0 {
                throw ZSErrorType.INVALID_ORDER(message: "limit unit must be 0.00000001")
            }
        }
        if self.amount - Double(Int(self.amount)) != 0 || self.amount <= 0 {
            throw ZSErrorType.INVALID_ORDER(message: "amount unit must be 1")
        }
    }
    
    override var amountString: String { get { return Int(self.amount).description } }
}

public class BuyBtcInJpyOrder : BtcJpyOrder {
    public init(price: Int?, amount: Double, limit: Int?=nil) {
        super.init(action: .BID, price: price, amount: amount, limit: limit)
    }
    
    override func marketOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        PublicApi.ticker(self.currencyPair) { (err, res) in
            if let e = err {
                callback(err, nil)
            } else {
                let marketPrice = res!["bid"].doubleValue
                var price = Int(round(marketPrice * 1.0005))
                price = (price / 5) * 5
                let order = BtcJpyOrder(action: self.action, price: price, amount: self.amount)
                order.execute(apiKeys, nonce: nonce, callback: callback)
            }
        }
    }
}

public class BuyMonaInJpyOrder : MonaJpyOrder {
    public init(price: Double?, amount: Int, limit: Double?=nil) {
        super.init(action: .BID, price: price, amount: amount, limit: limit)
    }
    
    override func marketOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        PublicApi.ticker(self.currencyPair) { (err, res) in
            if let e = err {
                callback(err, nil)
            } else {
                let marketPrice = res!["bid"].doubleValue
                var price = marketPrice * 1.0005
                price = floor(price * 10) / 10
                let order = MonaJpyOrder(action: self.action, price: price, amount: Int(self.amount))
                order.execute(apiKeys, nonce: nonce, callback: callback)
            }
        }
    }
}

class BuyMonaInBtcOrder : MonaBtcOrder {
    public init(price: Double?, amount: Int, limit: Double?=nil) {
        super.init(action: .BID, price: price, amount: amount, limit: limit)
    }
    
    override func marketOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        PublicApi.ticker(self.currencyPair) { (err, res) in
            if let e = err {
                callback(err, nil)
            } else {
                let marketPrice = res!["bid"].doubleValue
                var price = marketPrice * 1.0005
                price = floor(price * 100000000) / 100000000
                let order = MonaJpyOrder(action: self.action, price: price, amount: Int(self.amount))
                order.execute(apiKeys, nonce: nonce, callback: callback)
            }
        }
    }
}

public class SellBtcForJpyOrder : BtcJpyOrder {
    public init(price: Int?, amount: Double, limit: Int?=nil) {
        super.init(action: .ASK, price: price, amount: amount, limit: limit)
    }
    
    override func marketOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        PublicApi.ticker(self.currencyPair) { (err, res) in
            if let e = err {
                callback(err, nil)
            } else {
                let marketPrice = res!["ask"].doubleValue
                var price = Int(round(marketPrice * 0.9995))
                price = (price / 5) * 5
                let order = BtcJpyOrder(action: self.action, price: price, amount: self.amount)
                order.execute(apiKeys, nonce: nonce, callback: callback)
            }
        }
    }
}

public class SellMonaForJpyOrder : MonaJpyOrder {
    public init(price: Double?, amount: Int, limit: Double?=nil) {
        super.init(action: .ASK, price: price, amount: amount, limit: limit)
    }
    
    override func marketOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        PublicApi.ticker(self.currencyPair) { (err, res) in
            if let e = err {
                callback(err, nil)
            } else {
                let marketPrice = res!["ask"].doubleValue
                var price = marketPrice * 0.9995
                price = floor(price * 10) / 10
                let order = MonaJpyOrder(action: self.action, price: price, amount: Int(self.amount))
                order.execute(apiKeys, nonce: nonce, callback: callback)
            }
        }
    }
}

public class SellMonaForBtcOrder : MonaBtcOrder {
    public init(price: Double?, amount: Int, limit: Double?=nil) {
        super.init(action: .ASK, price: price, amount: amount, limit: limit)
    }
    
    override func marketOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        PublicApi.ticker(self.currencyPair) { (err, res) in
            if let e = err {
                callback(err, nil)
            } else {
                let marketPrice = res!["ask"].doubleValue
                var price = marketPrice * 0.9995
                price = floor(price * 100000000) / 100000000
                let order = MonaJpyOrder(action: self.action, price: price, amount: Int(self.amount))
                order.execute(apiKeys, nonce: nonce, callback: callback)
            }
        }
    }
}
