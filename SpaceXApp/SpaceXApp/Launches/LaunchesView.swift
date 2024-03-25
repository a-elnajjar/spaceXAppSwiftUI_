//
//  launchesView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import SwiftUI

struct LaunchesView: View {
    @ObservedObject var viewModel = LaunchesViewModel()
    @State private var isGridView = false

    var body: some View {
        NavigationView {
            ZStack {
                if isGridView {
                    LaunchesGridView
                } else {
                    LaunchesListView
                }
                navigationLink
            }
            .navigationBarTitle("Launches", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isGridView.toggle() }) {
                        Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                    }
                }
            }
        }
    }

    private var LaunchesListView: some View {
        List(viewModel.presenters) { item in
            LaunchesCell(presenters: item, isParentGrid: $isGridView )
                .onTapGesture {
                    viewModel.itemSelected(at: item)
                }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var LaunchesGridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(), count: 2)) {
                ForEach(viewModel.presenters) { item in
                    LaunchesCell(presenters: item, isParentGrid: $isGridView)
                        .onTapGesture {
                            viewModel.itemSelected(at: item)
                        }
                }
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
