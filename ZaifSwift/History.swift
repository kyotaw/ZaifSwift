//
//  History.swift
//  ZaifSwift
//
//  Created by 渡部郷太 on 6/29/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


public enum SortOrder : String {
    case ASC = "ASC"
    case DESC = "DESC"
    
}


public class HistoryQuery {
    init(
        from: Int?=nil, // nil means 0
        count: Int?=nil, // nil means 1000
        fromId: Int?=nil, // nil means 0
        endId: Int?=nil, // nil means "infinity"
        order: SortOrder?=nil, // nil means "DESC"
        since: Int?=nil, // nil means 0
        end: Int?=nil, // nil means "infinity"
        currencyPair: CurrencyPair?=nil // nil means "all pairs"
    ) {
        self.from = from
        self.count = count
        self.fromId = fromId
        self.endId = endId
        self.order = order
        self.since = since
        self.end = end
        self.currencyPair = currencyPair
    }
    
    public let from: Int?
    public let count: Int?
    public let fromId: Int?
    public let endId: Int?
    public let order: SortOrder?
    public let since: Int?
    public let end: Int?
    public let currencyPair: CurrencyPair?
}