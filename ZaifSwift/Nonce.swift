//
//  Nonce.swift
//  ZaifSwift
//
//  Created by Kyota Watanabe on 6/24/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation

public protocol NonceProtocol {
    func getNonce() throws -> String
    func countUp(value: Int) throws
    
    var currentValue: Int64 { get }
}

open class SerialNonce : NonceProtocol {
    public init(initialValue: Int64) {
        if initialValue > 0 {
            self.value = initialValue;
        } else {
            self.value = 1
        }
        self.exceedLimit = false
    }
    
    open func getNonce() throws -> String {
        if self.exceedLimit {
            throw ZSErrorType.NONCE_EXCEED_LIMIT
        }
        let v = self.value
        if v == IntMax.max {
            self.exceedLimit = true
        } else {
            self.value += 1
        }
        return v.description
    }
    
    open func countUp(value: Int) {
        self.value += value
    }
    
    open var currentValue: Int64 { get { return self.value } }
    
    fileprivate var value: Int64
    fileprivate var exceedLimit: Bool
}


open class TimeNonce : NonceProtocol {
    public init(initialValue: Int64=0) {
        self.prevValue = 0
        if initialValue > 0 {
            self.prevValue = initialValue;
        }
    }
    
    open func getNonce() throws -> String {
        if self.prevValue == IntMax.max {
            throw ZSErrorType.NONCE_EXCEED_LIMIT
        }
        
        let now = Int64(Date().timeIntervalSince1970)
        if self.prevValue < now {
            self.prevValue = now
            return now.description
        } else {
            self.prevValue += 5
            return self.prevValue.description
        }
    }
    
    open func countUp(value: Int) {
        for i in (0 ..< value) {
            do {
                try! self.getNonce()
            }
        }
    }
    
    open var currentValue: Int64 { get { return self.prevValue } }
    
    fileprivate var prevValue: Int64
}
