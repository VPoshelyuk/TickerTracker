//
//  ContentView.swift
//  TickerTracker
//
//  Created by Slava Pashaliuk on 6/25/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var networkManager = NetworkManager()
    @State var test = 1
    @State var trackedStocks: [(String, Color)] = [
        ("UONE", Color.red), ("SRNE", Color.green),
        ("UONE", Color.red), ("UONE", Color.red),
        ("UONE", Color.red), ("UONE", Color.red),
        ("UONE", Color.red), ("UONE", Color.red),
        ("UONE", Color.red), ("UONE", Color.red),
        ("UONE", Color.red), ("UONE", Color.red),
        ("UONE", Color.red), ("UONE", Color.red),
        ("UONE", Color.red), ("UONE", Color.red),
        ("UONE", Color.red), ("UONE", Color.red)
    ]
    
    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    Group {
                        Text("UONE")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                        Text("SRNE")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.green)
                                .frame(width: 75, height: 75)
                            )
                        Text("JPM")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                        Text("GRPN")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                        Text("PLAY")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                        Text("AAPL")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                        Text("PLUG")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.green)
                                .frame(width: 75, height: 75)
                            )
                        Text("F")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                        Text("LIVX")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                        Text("CYRX")
                            .frame(width: 75)
                            .background(
                                Circle()
                                .foregroundColor(Color.red)
                                .frame(width: 75, height: 75)
                            )
                    }
                    Group {
                       Text("UONE")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.red)
                               .frame(width: 75, height: 75)
                           )
                       Text("SRNE")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.green)
                               .frame(width: 75, height: 75)
                           )
                       Text("JPM")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.red)
                               .frame(width: 75, height: 75)
                           )
                       Text("GRPN")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.red)
                               .frame(width: 75, height: 75)
                           )
                       Text("PLAY")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.red)
                               .frame(width: 75, height: 75)
                           )
                       Text("AAPL")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.red)
                               .frame(width: 75, height: 75)
                           )
                       Text("PLUG")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.green)
                               .frame(width: 75, height: 75)
                           )
                       Text("F")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.red)
                               .frame(width: 75, height: 75)
                           )
                       Text("LIVX")
                           .frame(width: 75)
                           .background(
                               Circle()
                               .foregroundColor(Color.red)
                               .frame(width: 75, height: 75)
                           )
                        Button(action: {
                            self.trackedStocks.append(("UIJ", Color.black))
                            print(self.trackedStocks)
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
                }
                    .frame(width: 1700, height: 75)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
