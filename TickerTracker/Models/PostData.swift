//
//  PostData.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation

struct Results: Decodable {
    let articles: [Post]
}

struct Post: Decodable, Identifiable {
    let title: String
    let description: String
    let image: String?
    let url: String?
    let source: Source
    
    var id: String{
        return title
    }
}

struct Source: Decodable {
    let name: String
    let url: String?
}
