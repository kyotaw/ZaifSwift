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
        
        self.socket.event.open = {
            if let cb = self._onOpen {
                cb(nil, nil)
            }
        }
        self.socket.event.close = { (code, reason, wasClean) in
            if let cb = self._onClose {
                cb(nil, JSON(["reason": reason]))
            }
        }
        self.socket.event.message = { (res: Any) in
            if let cb = self._onData {
                cb(nil, JSON(res as! AnyObject))
            }
        }
        self.socket.event.error = { (err: Error) in
            let e = err as! WebSocketError
            if let cb = self._onError {
                cb(ZSError(errorType: .UNKNOWN_ERROR, message: e.description), nil)
            }
        }
        self.open(callback: openCallback)
    }
    
    public func open(callback: ZSCallback?=nil) {
        self.onOpen(callback: callback)
        self.socket.open() // do nothing if socket already opened otherwise reopen.
    }
    
    public func close(callback: ZSCallback?=nil) {
        self.onClose(callback: callback)
        self.socket.close()
    }
    
    public func onOpen(callback: ZSCallback?=nil) {
        self._onOpen = callback
    }
    
    public func onClose(callback: ZSCallback?=nil) {
        self._onClose = callback
    }
    
    public func onData(callback: ZSCallback?=nil) {
        self._onData = callback
    }
    
    public func onError(callback: ZSCallback?=nil) {
        self._onError = callback
    }
    
    private let socket: WebSocket!
    private var _onOpen: ZSCallback?
    private var _onClose: ZSCallback?
    private var _onData: ZSCallback?
    private var _onError: ZSCallback?
}
