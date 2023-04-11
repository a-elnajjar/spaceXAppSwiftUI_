//
//  RokectView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-07.
//

import SwiftUI

struct RocketsView: View {
    @ObservedObject var viewModel:RocketsViewModel = RocketsViewModel()
    var body: some View {
        NavigationView {
            ZStack {
                List(self.viewModel.presenters){ item in
                    RocketCell(presenter: item)
                }.onAppear(perform:{
                    self.viewModel.onAppear()
                }).listStyle(PlainListStyle())
            }.navigationBarTitle("Rocket",displayMode:.inline)
        }
    }
}


struct RrocketView_Previews: PreviewProvider {
    static var previews: some View {
        RocketsView()
    }
}
