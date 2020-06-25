//
//  WebView.swift
//  HackerNws_SwiftUI
//
//  Created by Slava Pashaliuk on 4/2/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    
    let urlString: String?
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let safeStr = urlString {
            if let url = URL(string: safeStr) {
                let req = URLRequest(url: url)
                uiView.load(req)
            }
        }
    }
}
