//
//  launchesView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import SwiftUI

struct LaunchesView: View {
    @StateObject private var viewModel = LaunchesViewModel()
    @State private var isGridView = false

    var body: some View {
        NavigationView {
            ZStack {
                if isGridView {
                    launchesGridView
                } else {
                    launchesListView
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
            .onAppear {
                viewModel.loadLaunchesIfNeeded()
            }
        }
    }

    private var launchesListView: some View {
        List(viewModel.presenters) { item in
            LaunchesCell(presenters: item, isParentGrid: $isGridView )
                .onTapGesture {
                    viewModel.itemSelected(at: item)
                }
        }
    }

    private var launchesGridView: some View {
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
    }

    private var navigationLink: some View {
        NavigationLink(
            destination: LaunchesDetailView(viewModel: viewModel.selectedViewModel),
            isActive: Binding(
                get: { viewModel.navigateToDetail },
                set: { viewModel.navigateToDetail = $0 }
            ),
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
