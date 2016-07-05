# ZaifSwift
Zaif API wrappers for Swift

## Requirement
* Swift 2.0 or later  
* Alamofire 3.4 or later
* CryptoSwift 0.5 or later
* SwiftyJSON

## Private APIs
* Create private api instance

Private api requires your own API keys. If you don't have keys, visit Zaif site(https://zaif.jp/) and generate your keys.

```swift
let privateApi = PrivateApi(apiKey: my_key, secretKey: my_secret)
```

* get_info
```swift
privateApi.getInfo() { (err, res) in
  if let info = res {
    let jpy = info["return"]["deposit"]["jpy"].doubleValue
    let btc = info["return"]["deposit"]["btc"].doubleValue
    let mona = info["return"]["deposit"]["mona"].doubleValue
  }
}
```
Where, res is JSON object of SwiftyJSON. So are res values of all other ZaifSwift callbacks bellow. 

* trade

There are factories to create orders for each currency pair.
```swift
// buy bitcoin in yen
let buyBtcOrder = Trade.Buy.Btc.In.Jpy.createOrder(60000, amount: 0.0001)
privateApi.trade(buyBtcOrder) { (err, res) in
  // process responce
}

// sell bitcoin for yen
let sellBtcOrder = Trade.Sell.Btc.For.Jpy.createOrder(80000, amount: 0.0001)
privateApi.trade(sellBtcOrder)

// buy monacoin in yen
let buyMonaOrder = Trade.Buy.Mona.In.Jpy.createOrder(5.0, amount: 1)
privateApi.trade(buyMonaOrder)

// sell monacoin for yen
let sellMonaOrder = Trade.Sell.Mona.For.Jpy.createOrder(7.0, amount: 1)
privateApi.trade(sellMonaOrder)

// buy monacoin in bitcoin
let buyMonaBtcOrder = Trade.Buy.Mona.In.Btc.createOrder(0.00000001, amount: 1)
privateApi.trade(buyMonaBtcOrder)

// sell monacoin for bitcoin
let sellMonaBtcOrder = Trade.Sell.Mona.For.Btc.createOrder(6.0, amount: 1)
privateApi.trade(sellMonaBtcOrder)
```
These nested namespaces will work to make clear which currency pair you're ordering and prevent miss orders.
If you feel they are redundant, you can call constructors for each order directly.
```swift
// buy bitcoin in yen
let buyBtcOrder = BuyBtcInJpyOrder(price: 60000, amount: 0.0001, limit: 60005)
privateApi.trade(buyBtcOrder)

// sell bitcoin for yen
let sellBtcOrder = SellBtcForJpyOrder(price: 80000, amount: 0.0001)
privateApi.trade(sellBtcOrder)

// buy monacoin in yen
let buyMonaOrder = BuyMonaInJpyOrder(price: 5.0, amount: 1)
privateApi.trade(buyMonaOrder)

// sell monacoin for yen
let sellMonaOrder = SellMonaForJpyOrder(price: 7.0, amount: 1)
privateApi.trade(sellMonaOrder)

// buy monacoin in bitcoin
let buyMonaBtcOrder = BuyMonaInBtcOrder(price: 0.00000001, amount: 1)
privateApi.trade(buyMonaBtcOrder)

// sell monacoin for bitcoin
let sellMonaBtcOrder = SellMonaForBtcOrder(price: 6.0, amount: 1)
privateApi.trade(sellMonaBtcOrder)
```
* trade_history

```swift
let query = HistoryQuery(currencyPair: .BTC_JPY, order: .ASC, from: 0, count: 10)
privateApi.tradeHistory(query) { (err, res) in
  print(res)
}
/*
Optional({
  "return" : {
    "6366798" : {
      "currency_pair" : "btc_jpy",
      "action" : "ask",
      "amount" : 0.017,
      "your_action" : "bid",
      "price" : 75500,
      "bonus" : 0.1,
      "fee" : 0,
      "fee_amount" : 0,
      "timestamp" : "1465831143",
      "comment" : ""
    },
*/    
```

* active_orders
* cancel_order
* withdraw
* deposit_history
* withdraw_history

## Public APIs
* last_price
```swift
// btc_jpy
PublicApi.lastPrice(.BTC_JPY) { (err, res) in
  print(res)
}
/*
Optional({
  "last_price" : 67775
})
*/

// mona_jpy
PublicApi.lastPrice(.MONA_JPY) { (err, res) in
  print(res)
}

// mona_btc
PublicApi.lastPrice(.MONA_BTC) { (err, res) in
  print(res)
}

// xem_jpy
PublicApi.lastPrice(.XEM_JPY) { (err, res) in
  print(res)
}
```



* ticker

```swift
// btc_jpy
PublicApi.ticker(.BTC_JPY) { (err, res) in
  print(res)
}
/*
Optional({
  "last" : 70015,
  "bid" : 70015,
  "low" : 66560,
  "volume" : 6171.2024,
  "ask" : 70040,
  "vwap" : 68672.34390000001,
  "high" : 70670
})
*/

// mona_jpy
PublicApi.ticker(.MONA_JPY) { (err, res) in
  print(res)
}

// mona_btc
PublicApi.ticker(.MONA_BTC) { (err, res) in
  print(res)
}

// xem_jpy
PublicApi.ticker(.XEM_JPY) { (err, res) in
  print(res)
}
```
