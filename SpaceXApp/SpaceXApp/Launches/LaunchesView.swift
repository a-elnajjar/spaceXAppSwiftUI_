//
//  launchesView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import SwiftUI

struct LaunchesView: View {
    @ObservedObject var viewModel = LaunchesViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                launchesList
                navigationLink
            }
            .navigationBarTitle("Launches", displayMode: .inline)
        }
    }

    private var launchesList: some View {
        List(viewModel.presenters) { item in
            LaunchesCell(presenters: item)
                .onTapGesture {
                    viewModel.itemSelected(at: item)
                }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var navigationLink: some View {
        NavigationLink(
            destination: LaunchesDetailView(viewModel: viewModel.selectedViewModel),
            isActive: $viewModel.navigateToDetail,
            label: {
                EmptyView()
            }
        )
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchesView()
    }
}
