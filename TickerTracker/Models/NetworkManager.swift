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
    
    func fetchNewsAndValues(_ tickers: [userInfo]) {
        for ticker in tickers {
            fetchAll(with: createStringURL(name: ticker.name), ticker: ticker)
        }
    }
    
    func updateNews(_ tickers: [userInfo]) {
        for ticker in tickers {
            checkNews(with: createStringURL(name: ticker.name), ticker: ticker)
        }
    }
    
    func updateNewsAndPrices(_ tickers: [userInfo]) {
        for ticker in tickers {
            checkNewsAndPrices(with: createStringURL(name: ticker.name), ticker: ticker)
        }
    }
    
    func createStringURL(name: String) -> String{
        return "https://cloud.iexapis.com/stable/stock/\(name)/batch?types=quote,news&token=pk_871ea244ab314546a2c5c16427f7e86f"
    }
    
    func fetchAll(with urlString: String, ticker: userInfo) {
        if let url = URL(string: urlString) {
            let task = NetworkManager.session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                            let decoder = JSONDecoder()
                            if let safeData = data {
                                do {
                                    var result = try decoder.decode(Stock.self, from: safeData)
                                    DispatchQueue.main.async {
                                        for i in 0 ..< result.news.count {
                                            if !self.posts.contains(where: { $0.id == result.id}) {
                                                result.news[i].associatedStock = result.quote.symbol
                                                self.posts.append(result.news[i])
                                            }
                                        }
                                        self.posts.sort { (lhs, rhs) in
                                            lhs.datetime > rhs.datetime
                                        }
                                        result.bottom = ticker.bottom
                                        result.top = ticker.top
                                        self.stonks.append(result)
                                        NetworkManager.self.globalStonks.append(result)
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
    
    func removeTicker(withName ticker: String) {
        print(self.stonks, self.posts, ticker)
        self.posts.removeAll(where: {post in
            post.associatedStock == ticker
        })
        if let index = self.stonks.firstIndex(where: {$0.id == ticker}) {
            self.stonks.remove(at: index)
        }
        print(self.stonks, self.posts, ticker)
    }
    
    func checkNews(with urlString: String, ticker: userInfo) {
        if let url = URL(string: urlString) {
            let task = NetworkManager.session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            var result = try decoder.decode(Stock.self, from: safeData)
                            DispatchQueue.main.async {
                                for index in 0..<result.news.count {
                                    if(!self.posts.contains{ $0.url == result.news[index].url}){
                                        result.news[index].associatedStock = result.quote.symbol
                                        self.posts.append(result.news[index])
                                    }
                                }
                                self.posts.sort { (lhs, rhs) in
                                    lhs.datetime > rhs.datetime
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
    
    func checkNewsAndPrices(with urlString: String, ticker: userInfo) {
        if let url = URL(string: urlString) {
            let task = NetworkManager.session.dataTask(with: url) { (data, response, error) in
                if error == nil {
                    let decoder = JSONDecoder()
                    if let safeData = data {
                        do {
                            var result = try decoder.decode(Stock.self, from: safeData)
                            DispatchQueue.main.async {
                                for index in 0..<result.news.count {
                                    if(!self.posts.contains{ $0.url == result.news[index].url}){
                                        result.news[index].associatedStock = result.quote.symbol
                                        self.posts.append(result.news[index])
                                    }
                                }
                                self.posts.sort { (lhs, rhs) in
                                    lhs.datetime > rhs.datetime
                                }
                                for index in 0 ..< self.stonks.count {
                                    if self.stonks[index].id == result.id {
                                        self.stonks[index].quote.latestPrice = result.quote.latestPrice
                                        NetworkManager.self.globalStonks[index].quote.latestPrice = result.quote.latestPrice
                                    }
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
