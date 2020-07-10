//
//  RefreshScrollView.swift
//  TickerTrackr
//
//  Created by Slava Pashaliuk on 7/9/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import UIKit
import SwiftUI

struct RefreshScrollView: UIViewRepresentable {
    var networkManager: NetworkManager
    var width: CGFloat
    var height: CGFloat
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl(sender:)), for: .valueChanged)
        let refreshVC = UIHostingController(rootView: ContentView(networkManager: networkManager))
        refreshVC.view.frame(x: 0 y: 0, width: width, height: height)
        scrollView.addSubview(refreshVC.view)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, networkManager: networkManager)
    }
    
    class Coordinator: NSObject {
        var refreshSV: RefreshScrollView
        var networkManager: NetworkManager
        
        init(_ refreshSV: RefreshScrollView, networkManager: NetworkManager){
            self.refreshSV = refreshSV
            self.networkManager = networkManager
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            sender.endRefreshing()
            networkManager.updateNews()
        }
    }
    
}
