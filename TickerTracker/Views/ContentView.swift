//
//  ContentView.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import SwiftUI

struct Stock: Identifiable {
    var id = UUID()
    var name: String
    var color: Color
}

struct ContentView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    @State private var alertInput = ""
    @State var trackedStocks = [Stock(name: "UONE",color: Color.red),Stock(name: "SRNE",color: Color.green),Stock(name: "JPM",color: Color.red),Stock(name: "GRPN",color: Color.red),Stock(name: "PLAY",color: Color.red),Stock(name: "PLUG",color: Color.green),Stock(name: "AAPL",color: Color.red),Stock(name: "F",color: Color.red),Stock(name: "LIVX",color: Color.red),Stock(name: "CYRX",color: Color.red)]
    
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    ForEach(trackedStocks) { stock in
                        Text(stock.name)
                            .frame(width: 75)
                            .background(
                                Circle()
                                    .foregroundColor(stock.color)
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
                .frame(width: CGFloat((self.trackedStocks.count + 1) * 85), height: 75)
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
            }
        }
    }
    
    
    private func alert() {
        let alert = UIAlertController(title: "title", message: "message", preferredStyle: .alert)
        alert.addTextField() { textField in
            textField.placeholder = "Enter some text"
        }
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
