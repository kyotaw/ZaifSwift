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


private class URLtoEncoding : URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        let URL = Foundation.URL(string: PrivateResource.url)!
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        return request
    }
}

private func makeQueryString(_ params: Dictionary<String, String>) -> String {
    let encoding = Alamofire.URLEncoding()
    do {
        let request = try encoding.encode(URLtoEncoding(), with: params)
        return NSString(data: request.httpBody!, encoding:String.Encoding.utf8.rawValue)! as String
    } catch {
        return ""
    }
}


internal class PrivateResource {
    
    internal static func getInfo(_ apiKeys: ApiKeys, nonce: NonceProtocol, callback: @escaping ZSCallback) {
        do {
            let nonce = try nonce.getNonce()
            let params = [
                "nonce": nonce,
                "method": "get_info",
            ]
            let headers = try self.makeHeaders(params, apiKeys: apiKeys)
            self.post(params: params, headers: headers, callback: callback)
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(ZSError(errorType: .NONCE_EXCEED_LIMIT), nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(ZSError(errorType: .CRYPTION_ERROR), nil)
        } catch {
            callback(ZSError(errorType: .UNKNOWN_ERROR), nil)
        }
    }
    
    internal static func trade(_ apiKeys: ApiKeys, nonce: NonceProtocol, order: Order, callback: @escaping ZSCallback) {
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
            self.post(params: params, headers: headers) { (err, res) in
                if err != nil {
                    callback(err, res)
                } else {
                    var resCopy = res
                    resCopy!["return"]["order_price"] = JSON(order.price!)
                    callback(nil, resCopy)
                }
            }
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(ZSError(errorType: .NONCE_EXCEED_LIMIT), nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(ZSError(errorType: .CRYPTION_ERROR), nil)
        } catch {
            callback(ZSError(errorType: .UNKNOWN_ERROR), nil)
        }
    }
    
    internal static func tradeHistory(_ apiKeys: ApiKeys, nonce: NonceProtocol, query: HistoryQuery, callback: @escaping ZSCallback) {
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
            self.post(params: params, headers: headers, callback: callback)
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(ZSError(errorType: .NONCE_EXCEED_LIMIT), nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(ZSError(errorType: .CRYPTION_ERROR), nil)
        } catch {
            callback(ZSError(errorType: .UNKNOWN_ERROR), nil)
        }
    }
    
    internal static func activeOrders(_ apiKeys: ApiKeys, nonce: NonceProtocol, currencyPair: CurrencyPair?, callback: @escaping ZSCallback) {
        do {
            let nonce = try nonce.getNonce()
            var params = [
                "nonce": nonce,
                "method": "active_orders",
                ]
            if let c = currencyPair {
                params["currency_pair"] = c.rawValue
            }
            let headers = try self.makeHeaders(params, apiKeys: apiKeys)
            self.post(params: params, headers: headers, callback: callback)
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(ZSError(errorType: .NONCE_EXCEED_LIMIT), nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(ZSError(errorType: .CRYPTION_ERROR), nil)
        } catch {
            callback(ZSError(errorType: .UNKNOWN_ERROR), nil)
        }
    }
    
    internal static func cancelOrder(_ apiKeys: ApiKeys, nonce: NonceProtocol, orderId: Int, callback: @escaping ZSCallback) {
        do {
            let nonce = try nonce.getNonce()
            let params = [
                "nonce": nonce,
                "method": "cancel_order",
                "order_id": orderId.description
            ]
            let headers = try self.makeHeaders(params, apiKeys: apiKeys)
            self.post(params: params, headers: headers, callback: callback)
        } catch ZSErrorType.NONCE_EXCEED_LIMIT {
            callback(ZSError(errorType: .NONCE_EXCEED_LIMIT), nil)
        } catch ZSErrorType.CRYPTION_ERROR {
            callback(ZSError(errorType: .CRYPTION_ERROR), nil)
        } catch {
            callback(ZSError(errorType: .UNKNOWN_ERROR), nil)
        }
    }

    internal static func makeHeaders(_ params: Dictionary<String, String>, apiKeys: ApiKeys) throws -> Dictionary<String, String> {
        var headers = [
            "Key": apiKeys.apiKey
        ]
        do {
            let query = makeQueryString(params).utf8.map({$0})
            let hmac: Array<UInt8> = try HMAC(key: apiKeys.secretKey.utf8.map({$0}), variant: .sha512).authenticate(query)
            headers["Sign"] = hmac.toHexString()
        } catch {
            throw ZSErrorType.CRYPTION_ERROR
        }
        
        return headers
    }
    
    internal static func post(
        params: Dictionary<String, String>,
        headers: Dictionary<String, String>,
        callback: @escaping ((_ err: ZSError?, _ res: JSON?) -> Void)) {
        
        
        Alamofire.request(PrivateResource.url, method: .post, parameters: params, headers: headers)
            .responseJSON(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default
            )) {
                response in
                
                switch response.result {
                case .failure(_):
                    callback(ZSError(errorType: .CONNECTION_ERROR), nil)
                    return
                case .success:
                    let data = JSON(response.result.value! as AnyObject)
                    guard let status = data["success"].int else {
                        callback(ZSError(errorType: .INVALID_RESPONSE), nil)
                        return
                    }
                    if status == 0 {
                        let message = data["error"].stringValue
                        switch message {
                        case "no data found for the key":
                            callback(ZSError(errorType: .INVALID_API_KEY, message: message), data)
                        case "signature mismatch":
                            callback(ZSError(errorType: .INVALID_SIGNATURE, message: message), data)
                        case "api key dont have info permission":
                            callback(ZSError(errorType: .INFO_API_NO_PERMISSION, message: message), data)
                        case "api key dont have trade permission":
                            callback(ZSError(errorType: .TRADE_API_NO_PERMISSION, message: message), data)
                        case "api key dont have withdraw permission":
                            callback(ZSError(errorType: .WITHDRAW_API_NO_PERMISSION, message: message), data)
                        case "nonce out of range":
                            callback(ZSError(errorType: .NONCE_EXCEED_LIMIT, message: message), data)
                        case "nonce not incremented":
                            callback(ZSError(errorType: .NONCE_NOT_INCREMENTED, message: message), data)
                        default:
                            callback(ZSError(errorType: .PROCESSING_ERROR, message: message), data)
                        }
                    } else {
                        callback(nil, data)
                    }
                }
            }
    }

    internal static let url = "https://api.zaif.jp/tapi"
}


internal class PublicResource {
    
    internal static func lastPrice(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        let url = [PublicResource.url, "last_price", currencyPair.rawValue].joined(separator: "/")
        self.get(url, callback: callback)
    }
    
    internal static func ticker(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        let url = [PublicResource.url, "ticker", currencyPair.rawValue].joined(separator: "/")
        self.get(url, callback: callback)
    }
    
    internal static func trades(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        let url = [PublicResource.url, "trades", currencyPair.rawValue].joined(separator: "/")
        self.get(url, callback: callback)
    }
    
    internal static func depth(_ currencyPair: CurrencyPair, callback: @escaping ZSCallback) {
        let url = [PublicResource.url, "depth", currencyPair.rawValue].joined(separator: "/")
        self.get(url, callback: callback)
    }

    private static func get(_ url: String, callback: @escaping ((_ err: ZSError?, _ res: JSON?) -> Void)) {
        Alamofire.request(PublicResource.url).responseJSON() { response in
            switch response.result {
            case .failure(_):
                callback(ZSError(errorType: .CONNECTION_ERROR), nil)
                return
            case .success:
                let data = JSON(response.result.value! as AnyObject)
                callback(nil, data)
            }
        }
    }
    
    internal static let url = "https://api.zaif.jp/api/1"
}


internal class StreamingResource {
    
    internal static func stream(_ currencyPair: CurrencyPair, openCallback: ZSCallback?=nil) -> Stream {
        let params = [
            "currency_pair": currencyPair.rawValue
        ]
        let query = makeQueryString(params)
        let url = [StreamingResource.url, query].joined(separator: "?")
        return Stream(url: url, openCallback: openCallback)
    }
    
    internal static let url = "ws://api.zaif.jp:8888/stream"
}
