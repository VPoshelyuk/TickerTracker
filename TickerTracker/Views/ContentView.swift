//
//  ContentView.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import SwiftUI
import SwiftUIPullToRefresh

struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()
    @State var watchedStocks: [UserInfo] = []
    var userDefaults = UserDefaults.standard
    @State var launchedBefore: Bool = UserDefaults.standard.bool(forKey: "launchedBefore")
    @State var showRefreshView: Bool = false
    
    var body: some View {
        VStack {
            launchedBefore ? Spacer() : nil
            ScrollView(.horizontal, showsIndicators: false) {
                TickersList(networkManager: networkManager,watchedStocks: $watchedStocks, launchedBefore: $launchedBefore)
            }
            if !launchedBefore {
                Text("Hello, Future Billionaire!\nWelcome to TickerTracker📈\nTo start using the app simply press on Plus sign, enter the ticker you want to monitor and Limit & Stop prices!\nEnjoy the app!")
                    .font(.custom("Futura Medium", size: UIScreen.main.bounds.size.width/18))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: UIScreen.main.bounds.size.width - 40, height: 300)
                    .background(NotSoRoundedRectangle(topLeft: 0, topRight: 30, bottomLeft: 30, bottomRight: 30).fill(Color.orange))
                Spacer()
            } else {
                Spacer()
                NewsList(networkManager: networkManager, showRefreshView: $showRefreshView, watchedStocks: $watchedStocks)
            }
        }
        .onAppear{
            if self.launchedBefore  {
                let decoded = self.userDefaults.data(forKey: "watchedStocks")
                self.watchedStocks = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [UserInfo]
            } else {
                print("First launch, setting UserDefault.")
                self.watchedStocks = []
            }
            self.networkManager.fetchNewsAndValues(self.watchedStocks)
            self.update()
        }
    }
    
    private func update() {
        Timer.scheduledTimer(withTimeInterval: 60 * 60, repeats: true) { timer in //3600 for testing purposes
            let decoded = self.userDefaults.data(forKey: "watchedStocks")
            self.watchedStocks = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [UserInfo]
            self.networkManager.updateNewsAndPrices(self.watchedStocks)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
