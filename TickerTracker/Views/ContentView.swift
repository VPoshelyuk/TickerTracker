//
//  ContentView.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import SwiftUI
import SwiftUIPullToRefresh

class userInfo: NSObject, NSCoding {
    var name: String
    var bottom: Double
    var top: Double
    
    init(name: String, bottom: Double, top: Double) {
        self.name = name
        self.bottom = bottom
        self.top = top
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "name") as! String
        let bottom = aDecoder.decodeDouble(forKey: "bottom")
        let top = aDecoder.decodeDouble(forKey: "top")
        self.init(name: name, bottom: bottom, top: top)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(bottom, forKey: "bottom")
        aCoder.encode(top, forKey: "top")
    }
}

struct ContentView: View {
    @ObservedObject var networkManager = NetworkManager()
    @State var watchedStocks: [userInfo] = []
    var userDefaults = UserDefaults.standard
    @State var launchedBefore: Bool = UserDefaults.standard.bool(forKey: "launchedBefore")
    @State var showRefreshView: Bool = false
    
    var body: some View {
        VStack {
            launchedBefore ? Spacer() : nil
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(networkManager.stonks){ stock in
                        TickerButtonView(networkManager: self.networkManager, watchedStocks: self.$watchedStocks, ticker: stock.quote.symbol, price: stock.quote.latestPrice, color: Color(hex: stock.HEXColor))
                    }
                    Button(action: {
                        withAnimation {
                            self.alert()
                        }
                    }){
                        Text("+")
                            .font(.system(size: 55))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        }
                        .padding(.all)
                        .accentColor(.white)
                        .frame(width: 75, height: 75)
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .frame(width: CGFloat((networkManager.stonks.count + 1) * 85), height: 75)
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
        .onAppear{
            if self.launchedBefore  {
                let decoded = self.userDefaults.data(forKey: "watchedStocks")
                self.watchedStocks = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [userInfo]
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
            self.watchedStocks = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [userInfo]
            self.networkManager.updateNewsAndPrices(self.watchedStocks)
        }
    }
    
    private func alert() {
        let alert = UIAlertController(title: "Stock Information", message: "Enter Ticker that you want to follow and Price Range:", preferredStyle: .alert)
        alert.addTextField() { textField in
            textField.placeholder = "Enter Ticker"
        }
        alert.addTextField() { textField in
            textField.placeholder = "Limit Order"
        }
        alert.addTextField() { textField in
            textField.placeholder = "Stop Order"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [alert] (_) in
            if let newStock = alert.textFields![0].text?.uppercased(), let bottom = alert.textFields?[1].text!, let top = alert.textFields?[2].text! {
                let newFollowed = userInfo(name: newStock, bottom: Double((bottom as NSString).doubleValue), top: Double((top as NSString).doubleValue))
                self.watchedStocks.append(newFollowed)
                let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.watchedStocks)
                self.userDefaults.set(encodedData, forKey: "watchedStocks")
                if !self.launchedBefore {
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                    self.launchedBefore.toggle()
                }
                self.userDefaults.synchronize()
                self.networkManager.fetchNewsAndValues([newFollowed])
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        showAlert(alert: alert)
    }

    func showAlert(alert: UIAlertController) {
        if let controller = topMostViewController() {
            controller.present(alert, animated: true)
        }
    }

    private func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
        .filter {$0.activationState == .foregroundActive}
        .compactMap {$0 as? UIWindowScene}
        .first?.windows.filter {$0.isKeyWindow}.first
    }

    private func topMostViewController() -> UIViewController? {
        guard let rootController = keyWindow()?.rootViewController else {
            return nil
        }
        return topMostViewController(for: rootController)
    }

    private func topMostViewController(for controller: UIViewController) -> UIViewController {
        if let presentedController = controller.presentedViewController {
            return topMostViewController(for: presentedController)
        } else if let navigationController = controller as? UINavigationController {
            guard let topController = navigationController.topViewController else {
                return navigationController
            }
            return topMostViewController(for: topController)
        } else if let tabController = controller as? UITabBarController {
            guard let topController = tabController.selectedViewController else {
                return tabController
            }
            return topMostViewController(for: topController)
        }
        return controller
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
