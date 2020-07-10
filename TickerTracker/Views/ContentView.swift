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
                    .background(RoundedCorners(tl: 0, tr: 30, bl: 30, br: 30).fill(Color.orange))
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


extension Color {
    init(hex: String) {
        var string: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }

        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }

        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }

        // Scanner creation
        let scanner = Scanner(string: string)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        if string.count == 2 {
            let mask = 0xFF

            let g = Int(color) & mask

            let gray = Double(g) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)

        } else if string.count == 4 {
            let mask = 0x00FF

            let g = Int(color >> 8) & mask
            let a = Int(color) & mask

            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)

        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)

        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask

            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0

            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)

        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let w = rect.size.width
        let h = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}
