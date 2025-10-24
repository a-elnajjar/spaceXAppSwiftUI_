//
//  RokectView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-07.
//

import SwiftUI

struct RocketsView: View {
    @StateObject private var viewModel = RocketsViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                List(viewModel.presenters) { item in
                    RocketCell(presenter: item)
                }
                .listStyle(.plain)
            }
            .navigationBarTitle("Rocket", displayMode: .inline)
        }
        .onAppear {
            viewModel.loadRocketsIfNeeded()
        }
    }
}


struct RrocketView_Previews: PreviewProvider {
    static var previews: some View {
        RocketsView()
    }
}
