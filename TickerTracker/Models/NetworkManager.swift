//
//  NetworkManager.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation

class NetworkManager: ObservableObject {
    
    @Published var posts = [NewsPiece]()
    @Published var stonks = [Stock]()
    static var globalStonks = [Stock]()
    static let session = URLSession(configuration: .default)
    
//    func fetchData() {
//        if let url = URL(string: "https://gnews.io/api/v3/search?q=sorrento%20therapeutics&token=15eb0bf587f3dc7e82d1a57dd853ed89") {
//            let task = NetworkManager.session.dataTask(with: url) { (data, response, error) in
//                if error == nil {
//                    let decoder = JSONDecoder()
//                    if let safeData = data {
//                        do {
//                            let results = try decoder.decode(Results.self, from: safeData)
//                            DispatchQueue.main.async {
//                                self.posts = results.articles                            }
//                        }catch {
//                            print(error)
//                        }
//                    }
//                }
//            }
//            task.resume()
//        }
//    }
    
    func fetchNewsAndValues(_ tickers: [userInfo]) {
        for ticker in tickers {
            if let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(ticker.name)/batch?types=quote,news&token=pk_871ea244ab314546a2c5c16427f7e86f") {
                let task = NetworkManager.session.dataTask(with: url) { (data, response, error) in
                    if error == nil {
                        let decoder = JSONDecoder()
                        if let safeData = data {
                            do {
                                var result = try decoder.decode(Stock.self, from: safeData)
                                DispatchQueue.main.async {
                                    if(!self.posts.containsAll(array: result.news)){
                                        self.posts.append(contentsOf: result.news)
                                    }else{
                                        for i in 0 ..< result.news.count {
                                            if !self.posts.contains(where: { $0.id == result.id}) {
                                                self.posts.append(result.news[i])
                                            }
                                        }
                                    }
                                    self.posts.sort { (lhs:NewsPiece, rhs:NewsPiece) in
                                        return lhs.datetime > rhs.datetime
                                    }
                                    if self.stonks.contains(where: { $0.id == result.id}) {
                                        for index in 0 ..< self.stonks.count {
                                            if self.stonks[index].id == result.id {
                                                self.stonks[index].quote.latestPrice = result.quote.latestPrice
                                                NetworkManager.self.globalStonks[index].quote.latestPrice = result.quote.latestPrice
                                            }
                                        }
                                        print(self.stonks)
                                    }else {
                                        result.bottom = ticker.bottom
                                        result.top = ticker.top
                                        self.stonks.append(result)
                                        NetworkManager.self.globalStonks.append(result)
                                    }
                                }
                            }catch {
                                print(error)
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }

    
//    func fetchStocksData(_ tickers: [userInfo]) {
//        for ticker in tickers {
//            if let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(ticker.name)batch?types=quote,news&token=pk_871ea244ab314546a2c5c16427f7e86f") {
//                let task = NetworkManager.session.dataTask(with: url) { (data, response, error) in
//                    if error == nil {
//                        let decoder = JSONDecoder()
//                        if let safeData = data {
//                            do {
//                                var result = try decoder.decode(Stock.self, from: safeData)
//                                DispatchQueue.main.async {
//                                    if self.stonks.contains(where: { $0.id == result.id}) {
//                                        for index in 0 ..< self.stonks.count {
//                                            if self.stonks[index].id == result.id {
//                                                self.stonks[index].last.askprice = result.last.askprice
//                                                NetworkManager.self.globalStonks[index].last.askprice = result.last.askprice
//                                            }
//                                        }
//                                        print(self.stonks)
//                                    }else {
//                                        result.bottom = ticker.bottom
//                                        result.top = ticker.top
//                                        self.stonks.append(result)
//                                        NetworkManager.self.globalStonks.append(result)
//                                    }
//                                }
//                            }catch {
//                                print(error)
//                            }
//                        }
//                    }
//                }
//                task.resume()
//            }
//        }
//    }
    
    static func globalStocksFetch(_ tickers: [userInfo]) {
        for ticker in tickers {
            if let url = URL(string: "https://api.polygon.io/v1/last_quote/stocks/\(ticker.name)?apiKey=B5_f8CsVoyXFLajXMC1t1avFaSB9oEe3fiPTF9") {
                let task = NetworkManager.session.dataTask(with: url) { (data, response, error) in
                    if error == nil {
                        let decoder = JSONDecoder()
                        if let safeData = data {
                            do {
                                let result = try decoder.decode(Stock.self, from: safeData)
                                DispatchQueue.main.async {
                                    NetworkManager.self.globalStonks = [result]
                                }
                            }catch {
                                print(error)
                            }
                        }
                    }
                }
                task.resume()
            }
        }
    }
}


extension Array where Element: Equatable {
    func containsAll(array: [Element]) -> Bool {
        for item in array {
            if !self.contains(item) { return false }
        }
        return true
    }
}
