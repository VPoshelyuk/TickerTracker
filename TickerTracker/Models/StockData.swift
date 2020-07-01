//
//  StockData.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation

//iexcloud.com
struct Stock: Decodable, Identifiable {
    var quote: Quote
    let news: [NewsPiece]
    var top: Double?
    var bottom: Double?
    var HEXColor: String{
        if quote.latestPrice >= top! {
            return "#00FF00"
        } else if quote.latestPrice <= bottom! {
            return "#FF0000"
        }else {
            return "#A1CAF1"
        }
    }
    var id: String{
        return quote.symbol
    }
}

struct Quote: Decodable {
    let symbol: String
    let companyName: String
    var latestPrice: Double
}

struct NewsPiece: Decodable, Identifiable{
    let datetime: Int
    let headline: String
    let url: String
    let image: String
    var id: String{
        return url
    }
}

extension Stock: Equatable {
    static func ==(lhs: Stock, rhs: Stock) -> Bool {
        return lhs.id == rhs.id && lhs.HEXColor == rhs.HEXColor
    }
}

//polygon.io
//struct Stock: Decodable, Identifiable {
//    var bottom: Double?
//    var top: Double?
//    let symbol: String
//    var last: Last
//    var HEXColor: String{
//        if last.askprice >= top! {
//            return "#00FF00"
//        } else if last.askprice <= bottom! {
//            return "#FF0000"
//        }else {
//            return "#A1CAF1"
//        }
//    }
//    var id: String{
//        return symbol
//    }
//}
//
//struct Last: Decodable {
//    var askprice: Double
//}
//
//extension Stock: Equatable {
//    static func ==(lhs: Stock, rhs: Stock) -> Bool {
//        return lhs.id == rhs.id && lhs.HEXColor == rhs.HEXColor
//    }
//}
