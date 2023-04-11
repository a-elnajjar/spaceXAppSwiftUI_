//
//  RockectsViewModel.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-07.
//

import Foundation
import Combine

class RocketsViewModel: NSObject,ObservableObject {
    private var task: Cancellable? = nil
    private var rockets: [RocketModel] = []
    @Published var presenters: [RocketPresenter] = []
    
    func onAppear(){
        self.task = Service.standard.get(path: .rockets , responseType:[RocketModel].self)
            .map{[weak self] in
                self?.rockets = $0
                return $0.map{RocketPresenter(with: $0)}
            }
            .sink(receiveCompletion:{_ in },receiveValue:{  [weak self] presenters in
                self?.presenters = presenters
            })
    }
}
