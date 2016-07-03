//
//  Nonce.swift
//  Zaifoo
//
//  Created by 渡部郷太 on 6/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

public protocol NonceProtocol {
    func getNonce() throws -> String
}

public class SerialNonce : NonceProtocol {
    public init(initialValue: Int64) {
        if initialValue > 0 {
            self.value = initialValue;
        } else {
            self.value = 1
        }
        self.exceedLimit = false
    }
    
    public func getNonce() throws -> String {
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
    
    private var value: Int64
    private var exceedLimit: Bool
}


public class TimeNonce : NonceProtocol {
    public init() {
        self.prevValue = 0
    }
    
    public func getNonce() throws -> String {
        if self.prevValue == IntMax.max {
            throw ZSErrorType.NONCE_EXCEED_LIMIT
        }
        
        let now = Int64(NSDate().timeIntervalSince1970)
        if self.prevValue < now {
            self.prevValue = now
            return now.description
        } else {
            self.prevValue += 1
            return self.prevValue.description
        }
    }
    
    private var prevValue: Int64
}