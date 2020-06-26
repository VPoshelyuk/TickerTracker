//
//  ContentView.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import SwiftUI

struct userInfo {
    var name: String
    var bottom: Double
    var top: Double
}

struct ContentView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    @State var watchedStocks: [userInfo] = [userInfo(name: "SRNE", bottom: 6.00, top: 7.00), userInfo(name: "AAPL", bottom: 365, top: 367)]
    let timer = Timer.publish(every: 10, on: .current, in: .common).autoconnect()
    
//    Stock(name: "UONE",color: Color.red),Stock(name: "SRNE",color: Color.green),Stock(name: "JPM",color: Color.red),Stock(name: "GRPN",color: Color.red),Stock(name: "PLAY",color: Color.red),Stock(name: "PLUG",color: Color.green),Stock(name: "AAPL",color: Color.red),Stock(name: "F",color: Color.red),Stock(name: "LIVX",color: Color.red),Stock(name: "CYRX",color: Color.red)
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(networkManager.stonks){ stock in
                        Text(stock.symbol)
                            .frame(width: 75)
                            .background(
                                Circle()
                                    .foregroundColor(Color(hex: stock.HEXColor))
                                    .frame(width: 75, height: 75)
                            )
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
            NavigationView {
                List(networkManager.posts){post in
                    NavigationLink(destination: DetailView(url: post.url)){
                        HStack {
                            Text(post.title)
                        }
                    }
                }
                .navigationBarTitle("Tracked Stocks News:")
            }
            .onAppear{
                self.networkManager.fetchData()
                self.networkManager.fetchStocksData(self.watchedStocks)
                self.update()
            }
        }
    }
    
    private func update() {
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            self.networkManager.fetchStocksData(self.watchedStocks)
        }
    }
    
    private func alert() {
        let alert = UIAlertController(title: "title", message: "message", preferredStyle: .alert)
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
                self.networkManager.fetchStocksData([newFollowed])
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
