//
//  TickerButtonView.swift
//  TickerTrackr
//
//  Created by Slava Pashaliuk on 7/4/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation
import SwiftUI

struct TickerButtonView: View {
    var ticker: String
    var price: Double
    var color: Color
    var stringPrice: String {
        return String(price)
    }
    @State var showingName = true
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.showingName.toggle()
            }
        }){
            Text(showingName ? ticker : stringPrice)
                .fontWeight(.bold)
            }
            .accentColor(.white)
            .frame(width: 75, height: 75)
            .accentColor(.white)
            .background(color)
            .cornerRadius(37.5)
    }
}
