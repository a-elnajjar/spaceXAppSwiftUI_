//
//  launchesViewModel.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import Foundation
import Combine

@MainActor
final class LaunchesViewModel: ObservableObject {

    private var task: AnyCancellable?
    private var launches: [Launch] = []
    private var hasLoaded = false

    @Published var presenters: [LaunchesPresenter] = []
    @Published var selectedViewModel: LaunchesDetailViewModel = LaunchesDetailViewModel()
    @Published var navigateToDetail: Bool = false

    func loadLaunchesIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true

        task = Service.standard.get(path: .launches, responseType: [Launch].self)
            .map { launches -> (launches: [Launch], presenters: [LaunchesPresenter]) in
                let presenters = launches.map { LaunchesPresenter(with: $0) }
                return (launches, presenters)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.hasLoaded = false
                }
            }, receiveValue: { [weak self] output in
                self?.launches = output.launches
                self?.presenters = output.presenters
            })
    }

    func itemSelected(at item: LaunchesPresenter) {
        guard let index = presenters.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        selectedViewModel = LaunchesDetailViewModel(with: launches[index])
        navigateToDetail = true
    }

    deinit {
        task?.cancel()
    }
}
