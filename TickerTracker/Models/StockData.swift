//
//  StockData.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation

struct Stock: Decodable, Identifiable {
    var bottom: Double?
    var top: Double?
    let symbol: String
    var last: Last
    var HEXColor: String{
        if last.askprice >= top! {
            return "#00FF00"
        } else if last.askprice <= bottom! {
            return "#FF0000"
        }else {
            return "#A1CAF1"
        }
    }
    var id: String{
        return symbol
    }
}

struct Last: Decodable {
    var askprice: Double
}

extension Stock: Equatable {
    static func ==(lhs: Stock, rhs: Stock) -> Bool {
        return lhs.id == rhs.id && lhs.HEXColor == rhs.HEXColor
    }
}
