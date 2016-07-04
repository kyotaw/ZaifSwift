//
//  Error.swift
//  ZaifSwift
//
//  Created by 渡部郷太 on 6/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

public enum ZSErrorType : ErrorType {
    case CONNECTION_ERROR
    case CRYPTION_ERROR
    case INVALID_API_KEY
    case INVALID_SIGNATURE
    case INVALID_REQUEST
    case INVALID_RESPONSE
    case INVALID_ORDER(message: String)
    case SEVER_ERROR
    case PROCESSING_ERROR
    case NONCE_EXCEED_LIMIT
    case NONCE_NOT_INCREMENTED
    case INFO_API_NO_PERMISSION
    case TRADE_API_NO_PERMISSION
    case WITHDRAW_API_NO_PERMISSION
    case UNKNOWN_ERROR
}

public struct ZSError {
    public init(errorType: ZSErrorType, message: String="") {
        self.errorType = errorType
        self.message = message
    }
    
    public let errorType: ZSErrorType
    public let message: String
}