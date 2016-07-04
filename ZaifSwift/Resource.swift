//
//  Resource.swift
//  ZaifSwift
//
//  Created by 渡部郷太 on 6/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON
import CryptoSwift
import Alamofire


private func makeQueryString(params: Dictionary<String, String>) -> String {
    let URL = NSURL(string: PrivateResource.url)!
    var request = NSMutableURLRequest(URL: URL)
    request.HTTPMethod = "POST"
    let encoding = Alamofire.ParameterEncoding.URL
    (request, _) = encoding.encode(request, parameters: params)
    return NSString(data: request.HTTPBody!, encoding:NSUTF8StringEncoding)! as String
}


class PrivateResource {
    
    internal static func getInfo(apiKeys: ApiKeys, nonce: NonceProtocol, callback: ZSCallback) {
        do {
            let nonce = try nonce.getNonce()
            let params = [
                "nonce": nonce,
                "method": "get_info",
            ]
            let headers = try self.makeHeaders(params, apiKeys: apiKeys)
            self.post(params, headers: headers, callback: callback)
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(err: ZSError(errorType: .NONCE_EXCEED_LIMIT), res: nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(err: ZSError(errorType: .CRYPTION_ERROR), res: nil)
        } catch {
            callback(err: ZSError(errorType: .UNKNOWN_ERROR), res: nil)
        }
    }
    
    internal static func trade(apiKeys: ApiKeys, nonce: NonceProtocol, order: Order, callback: ZSCallback) {
        do {
            let nonce = try nonce.getNonce()
            var params = [
                "nonce": nonce,
                "method": "trade",
                "currency_pair": order.currencyPair.rawValue,
                "action": order.action.rawValue,
                "price": order.priceString,
                "amount": order.amountString,
            ]
            if let limit = order.limitString {
                params["limit"] = limit
            }
            let headers = try self.makeHeaders(params, apiKeys: apiKeys)
            self.post(params, headers: headers, callback: callback)
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(err: ZSError(errorType: .NONCE_EXCEED_LIMIT), res: nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(err: ZSError(errorType: .CRYPTION_ERROR), res: nil)
        } catch {
            callback(err: ZSError(errorType: .UNKNOWN_ERROR), res: nil)
        }
    }
    
    internal static func tradeHistory(apiKeys: ApiKeys, nonce: NonceProtocol, query: HistoryQuery, callback: ZSCallback) {
        do {
            let nonce = try nonce.getNonce()
            var params = [
                "nonce": nonce,
                "method": "trade_history",
            ]
            if let f = query.from {
                params["from"] = f.description
            }
            if let c = query.count {
                params["count"] = c.description
            }
            if let f = query.fromId {
                params["from_id"] = f.description
            }
            if let e = query.endId {
                params["end_id"] = e.description
            }
            if let o = query.order {
                params["order"] = o.rawValue
            }
            if let s = query.since {
                params["since"] = s.description
            }
            if let e = query.end {
                params["end"] = e.description
            }
            if let c = query.currencyPair {
                params["currency_pair"] = c.rawValue
            }

            let headers = try self.makeHeaders(params, apiKeys: apiKeys)
            self.post(params, headers: headers, callback: callback)
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(err: ZSError(errorType: .NONCE_EXCEED_LIMIT), res: nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(err: ZSError(errorType: .CRYPTION_ERROR), res: nil)
        } catch {
            callback(err: ZSError(errorType: .UNKNOWN_ERROR), res: nil)
        }
    }
    
    private static func makeHeaders(params: Dictionary<String, String>, apiKeys: ApiKeys) throws -> Dictionary<String, String> {
        var headers = [
            "Key": apiKeys.apiKey
        ]
        do {
            let query = makeQueryString(params).utf8.map({$0})
            let hmac: Array<UInt8> = try Authenticator.HMAC(key: apiKeys.secretKey.utf8.map({$0}), variant: .sha512).authenticate(query)
            headers["Sign"] = hmac.toHexString()
        } catch {
            throw ZSErrorType.CRYPTION_ERROR
        }
        
        return headers
    }
    
    private static func post(
        params: Dictionary<String, String>,
        headers: Dictionary<String, String>,
        callback: ((err: ZSError?, res: JSON?) -> Void)) {
        
        
        Alamofire.request(.POST, PrivateResource.url, parameters: params, headers: headers)
            .responseJSON(queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                response in
                
                switch response.result {
                case .Failure(let error):
                    callback(err: ZSError(errorType: .CONNECTION_ERROR, message: error.domain), res: nil)
                    return
                case .Success:
                    let data = JSON(response.result.value! as AnyObject)
                    guard let status = data["success"].int else {
                        callback(err: ZSError(errorType: .INVALID_RESPONSE), res: nil)
                        return
                    }
                    if status == 0 {
                        let message = data["error"].stringValue
                        switch message {
                        case "no data found for the key":
                            callback(err: ZSError(errorType: .INVALID_API_KEY, message: message), res: data)
                        case "signature mismatch":
                            callback(err: ZSError(errorType: .INVALID_SIGNATURE, message: message), res: data)
                        case "api key dont have info permission":
                            callback(err: ZSError(errorType: .INFO_API_NO_PERMISSION, message: message), res: data)
                        case "api key dont have trade permission":
                            callback(err: ZSError(errorType: .TRADE_API_NO_PERMISSION, message: message), res: data)
                        case "api key dont have withdraw permission":
                            callback(err: ZSError(errorType: .WITHDRAW_API_NO_PERMISSION, message: message), res: data)
                        case "nonce out of range":
                            callback(err: ZSError(errorType: .NONCE_EXCEED_LIMIT, message: message), res: data)
                        case "nonce not incremented":
                            callback(err: ZSError(errorType: .NONCE_NOT_INCREMENTED, message: message), res: data)
                        default:
                            callback(err: ZSError(errorType: .PROCESSING_ERROR, message: message), res: data)
                        }
                    } else {
                        callback(err: nil, res: data)
                    }
                }
            }
    }

    internal static let url = "https://api.zaif.jp/tapi"
}


class PublicResource {
    internal static func ticker(currencyPair: CurrencyPair, callback: ZSCallback) {
        let url = [PublicResource.url, "ticker", currencyPair.rawValue].joinWithSeparator("/")
        self.get(url, callback: callback)
    }

    private static func get(url: String, callback: ((err: ZSError?, res: JSON?) -> Void)) {
        Alamofire.request(.GET, url).responseJSON() { response in
            switch response.result {
            case .Failure(let error):
                callback(err: ZSError(errorType: .CONNECTION_ERROR, message: error.domain), res: nil)
                return
            case .Success:
                let data = JSON(response.result.value! as AnyObject)
                callback(err: nil, res: data)
            }
        }
    }
    
    internal static let url = "https://api.zaif.jp/api/1"
}