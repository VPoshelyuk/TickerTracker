//
//  NewsBubbleView.swift
//  TickerTrackr
//
//  Created by Slava Pashaliuk on 7/4/20.
//  Copyright © 2020 Viachaslau Pashaliuk. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import URLImage


struct NewsBubbleView: View {
    @State var presentingModal = false
    var imageURL: String
    var image: URL {
        print(Color(UIColor.systemBackground))
        return URL(string: imageURL)!
    }
    var name: String
    var postURL: String
    var body: some View {
        HStack {
            URLImage(image,
            delay: 1,
            processors: [ Resize(size: CGSize(width: 150, height: 150), scale: UIScreen.main.scale)],
            content:  {
                $0.image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
            })
                .frame(width: 150, height: 150, alignment: .center)
            Spacer()
            Text(name)
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding()
                .frame(width: UIScreen.main.bounds.size.width - 180, height: 150)
        }
            .accentColor(.white)
            .frame(width: UIScreen.main.bounds.size.width - 20, height: 150)
            .background(LinearGradient(gradient: Gradient(colors: [.white, .orange]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(20)
            .onTapGesture {
                withAnimation {
                    self.presentingModal = true
                }
            }
            .sheet(isPresented: $presentingModal) { ModalView(presentedAsModal: self.$presentingModal, postURL: self.postURL, name: self.name) }
    }
}

struct NewsBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        NewsBubbleView(imageURL: "https://pngimg.com/uploads/cat/cat_PNG50538.png", name: "dfdsfsdfsd", postURL: "https://pngimg.com/uploads/cat/cat_PNG50538.png")
    }
}

struct ModalView: View {
    @Binding var presentedAsModal: Bool
    var postURL: String
    var name: String
    var body: some View {
        VStack {
            HStack{
                Text(name)
                Button("Back") { self.presentedAsModal = false }
            }
            .frame(maxHeight: 50.0)
            .padding()
            DetailView(url: postURL)
        }
    }
}

