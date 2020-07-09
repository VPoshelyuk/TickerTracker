//
//  Link.swift
//  TickerTrackr
//
//  Created by Slava Pashaliuk on 7/9/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

//import SwiftUI
//
//class Link: ObservableObject {
//    @Published private var networkManager: NetworkManager = Link.launch()
//    
//    static func launch() -> NetworkManager {
//        NetworkManager()
//    }
//    
//    var posts: Array<NewsPiece> {
//        networkManager.posts
//    }
//    
//    var stonks: Array<Stock> {
//        networkManager.stonks
//    }
//    
//    func fetchNewsAndValues(_ tickers: [userInfo]) {
//        for i in 0..<networkManager.stonks.count {
//            print(networkManager.stonks[i].id)
//        }
//        networkManager.fetchNewsAndValues(tickers)
//    }
//    
//    func removeTicker(withName ticker: String) {
//        networkManager.removeTicker(withName: ticker)
//    }
//}
