//
//  LaunchesDetailView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-06.
//

import SwiftUI
import Kingfisher

struct LaunchesDetailView: View {
    @ObservedObject var viewModel:LaunchesDetailViewModel = LaunchesDetailViewModel()
    var body: some View {
        ScrollView{
            VStack(spacing: 16){
                KFImage(URL(string: self.viewModel.presenter?.image ?? "" ))
                    .cancelOnDisappear(true)
                    .resizable()
                    .frame( width: 265,height: 265)
                Text(self.viewModel.presenter?.title ?? "")
                Text(self.viewModel.presenter?.detail ?? "")
            }.padding(100)
        }
    }
}

struct LaunchesDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchesDetailView()
    }
}
