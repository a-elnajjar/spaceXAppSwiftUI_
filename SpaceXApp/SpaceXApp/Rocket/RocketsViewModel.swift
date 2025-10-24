//
//  RockectsViewModel.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-07.
//

import Foundation
import Combine

@MainActor
final class RocketsViewModel: ObservableObject {
    private var task: AnyCancellable?
    private var rockets: [RocketModel] = []
    private var hasLoaded = false

    @Published var presenters: [RocketPresenter] = []

    func loadRocketsIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true

        task = Service.standard.get(path: .rockets, responseType: [RocketModel].self)
            .map { rockets -> (rockets: [RocketModel], presenters: [RocketPresenter]) in
                let presenters = rockets.map { RocketPresenter(with: $0) }
                return (rockets, presenters)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.hasLoaded = false
                }
            }, receiveValue: { [weak self] output in
                self?.rockets = output.rockets
                self?.presenters = output.presenters
            })
    }

    deinit {
        task?.cancel()
    }
}
