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


struct NewsBubbleView: View {
    @ObservedObject var remoteImageURL: RemoteImageURL
    @State var presentingModal = false
    var name: String
    var postURL: String
    
    init(imageURL: String, name: String, postURL: String) {
        remoteImageURL = RemoteImageURL(imageURL: imageURL)
        self.name = name
        self.postURL = postURL
    }
    
    var body: some View {
        Button(action: {
            withAnimation {
                self.presentingModal = true
            }
        }){
//            VStack {
//                Image(uiImage: (remoteImageURL.data.isEmpty) ? UIImage(imageLiteralResourceName: "kitten") : UIImage(data: remoteImageURL.data)!)
//                    .renderingMode(.original)
                Text(name)
                    .fontWeight(.bold)
//                }
            }
            .padding(.all)
            .accentColor(.white)
            .frame(width: UIScreen.main.bounds.size.width - 20, height: 250)
            .background(Color.gray)
            .cornerRadius(20)
            .sheet(isPresented: $presentingModal) { ModalView(presentedAsModal: self.$presentingModal, postURL: self.postURL, name: self.name) }
    }
}

struct NewsBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        NewsBubbleView(imageURL: "https://pngimg.com/uploads/cat/cat_PNG50538.png", name: "dfdsfsdfsd", postURL: "https://pngimg.com/uploads/cat/cat_PNG50538.png")
    }
}

class RemoteImageURL: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(imageURL: String) {
        guard let url = URL(string: imageURL) else {return}
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {return}
            
            DispatchQueue.main.async {
                self.data = data
            }
        }.resume()
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
            DetailView(url: postURL)
        }
    }
}
