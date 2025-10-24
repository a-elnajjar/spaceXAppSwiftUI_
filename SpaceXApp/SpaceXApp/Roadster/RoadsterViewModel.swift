//
//  RoadsterViewModel.swift
//  SpaceXApp
//
//  Created by Abdalla El Najjar on 2023-03-13.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class RoadsterViewModel: ObservableObject {
    private var task: AnyCancellable?
    private var hasLoaded = false

    @Published var presenter: RoadstarPresenter?

    init(presenter: RoadstarPresenter? = nil) {
        self.presenter = presenter
    }

    func loadRoadsterIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true

        task = Service.standard.get(path: .roadster, responseType: RoadsterModel.self)
            .map { RoadstarPresenter(with: $0) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.hasLoaded = false
                }
            }, receiveValue: { [weak self] presenter in
                self?.presenter = presenter
            })
    }

    deinit {
        task?.cancel()
    }
}
