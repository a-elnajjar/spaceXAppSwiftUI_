//
//  RoadsterView.swift
//  SpaceXApp
//
//  Created by Abdalla El Najjar on 2023-03-13.
//

import SwiftUI
import Kingfisher
import AVKit

struct RoadsterView: View {
    @ObservedObject var viewModel:RoadsterViewModel = RoadsterViewModel()
    var body: some View {
        NavigationView {
            ScrollView{
                VStack {
                    if let roadster = self.viewModel.presenter {
                        Text(roadster.title!).bold()
                        KFImage(URL(string: roadster.image ?? ""))
                            .cancelOnDisappear(true)
                            .resizable()
                            .frame( width: 265,height: 265)
                       
                        Text("Speed in \(roadster.speed ?? 0.0 ) K/H").bold()
                        Text(roadster.detail  ?? "")
                            .padding()
                        VideoPlayer(player: AVPlayer(url: URL(string:"https://www.youtube.com/watch?v=wbSwFU6tY1c")!)).frame(height: 400)
                    } else {
                        Text("Can't load the data")
                    }

                   
                }
            }.navigationBarTitle("Roadster",displayMode:.inline)
                .onAppear(perform:{
                    self.viewModel.onAppear()
                })
       
        }
    }
}

struct RoadsterView_Previews: PreviewProvider {
    static var previews: some View {
        RoadsterView()
    }
}
