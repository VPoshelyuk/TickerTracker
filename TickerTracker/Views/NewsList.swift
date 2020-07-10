//
//  NewsList.swift
//  TickerTrackr
//
//  Created by Slava Pashaliuk on 7/9/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import SwiftUI
import SwiftUIPullToRefresh

struct NewsList: View {
    @ObservedObject var networkManager: NetworkManager
    @Binding var showRefreshView: Bool
    @Binding var watchedStocks: [UserInfo]
    var body: some View {
        RefreshableList(showRefreshView: $showRefreshView, action:{
            self.networkManager.updateNews(self.watchedStocks)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showRefreshView = false
            }
        }){
            VStack(spacing: 10) {
                ForEach(self.networkManager.posts){ post in
                        NewsBubbleView(imageURL: post.image, name: post.headline, postURL: post.url)
                }
            }
            .frame(width: UIScreen.main.bounds.size.width - 40, height: CGFloat((self.networkManager.posts.count) * 160))
        }
    }
}
