//
//  Stream.swift
//  ZaifSwift
//
//  Created by 渡部郷太 on 7/9/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftWebSocket
import SwiftyJSON


public class Stream {
    internal init(url: String, openCallback: ZSCallback?=nil) {
        self.socket = WebSocket(url)
        self._onOpen = openCallback
    
        self.socket.event.open = {
            if let cb = self._onOpen {
                cb(err: nil, res: nil)
            }
        }
        self.socket.event.close = { (code, reason, wasClean) in
            if let cb = self._onClose {
                cb(err: nil, res: JSON(["reason": reason]))
            }
        }
        self.socket.event.message = { (res: Any) in
            if let cb = self._onData {
                cb(err: nil, res: JSON(res as! AnyObject))
            }
        }
        self.socket.event.error = { (err: ErrorType) in
            let e = err as! WebSocketError
            if let cb = self._onError {
                cb(err: ZSError(errorType: .UNKNOWN_ERROR, message: e.description), res: nil)
            }
        }
        self.socket.open()
    }
    
    public func close() {
        self.socket.close()
    }
    
    public func onClose(callback: ZSCallback?) {
        self._onClose = callback
    }
    
    public func onData(callback: ZSCallback?) {
        self._onData = callback
    }
    
    public func onError(callback: ZSCallback?) {
        self._onError = callback
    }
    
    private let socket: WebSocket!
    private var _onOpen: ZSCallback?
    private var _onClose: ZSCallback?
    private var _onData: ZSCallback?
    private var _onError: ZSCallback?
}