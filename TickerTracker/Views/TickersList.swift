//
//  TickersList.swift
//  TickerTrackr
//
//  Created by Slava Pashaliuk on 7/9/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import SwiftUI

struct TickersList: View {
    @ObservedObject var networkManager: NetworkManager
    @Binding var watchedStocks: [UserInfo]
    @Binding var launchedBefore: Bool
    var userDefaults = UserDefaults.standard
    
    var body: some View {
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
                let newFollowed = UserInfo(name: newStock, bottom: Double((bottom as NSString).doubleValue), top: Double((top as NSString).doubleValue))
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

