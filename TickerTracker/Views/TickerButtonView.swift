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
    @ObservedObject var networkManager: NetworkManager
    @State var watchedStocks: [userInfo] = []
    var userDefaults = UserDefaults.standard
    var ticker: String
    var price: Double
    var color: Color
    var stringPrice: String {
        return String(price)
    }
    @State var showingName = true
    
    var body: some View {
        Button(action: {}){
            VStack {
                Text(showingName ? ticker : stringPrice)
                    .fontWeight(.bold)
                .onTapGesture {
                    withAnimation {
                        self.showingName.toggle()
                    }
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    self.alert(self.ticker)
                }
            }
            }
            .frame(width: 75, height: 75)
            .accentColor(.white)
            .background(color)
            .cornerRadius(37.5)
    }
    
    private func update(_ tickerName: String) {
        let decoded = self.userDefaults.data(forKey: "watchedStocks")
        watchedStocks = NSKeyedUnarchiver.unarchiveObject(with: decoded!) as! [userInfo]
        watchedStocks = watchedStocks.filter { $0.name != tickerName }
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: watchedStocks)
        userDefaults.set(encodedData, forKey: "watchedStocks")
        networkManager.removeTicker(withName: tickerName)
    }
    
    private func alert(_ tickerName: String) {
        let alert = UIAlertController(title: "Sup", message: "Delete this ticker from tracked?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default){ _ in
            self.update(tickerName)
        })
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
