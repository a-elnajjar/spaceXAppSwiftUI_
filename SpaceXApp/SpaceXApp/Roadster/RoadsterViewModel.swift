//
//  RoadsterViewModel.swift
//  SpaceXApp
//
//  Created by Abdalla El Najjar on 2023-03-13.
//

import Foundation
import Combine
import ClearCoreSDK
import SwiftUI



final class RoadsterViewModel: NSObject,ObservableObject {
    private var task: Cancellable? = nil
    private var roadster: RoadsterModel? = nil
    @Published var presenter: RoadstarPresenter? = nil

    func onAppear(){
        
        self.task = Service.standard.get(path: .roadster , responseType:RoadsterModel.self)
            .map{[weak self] in
                self?.roadster = $0
                guard let roadster = self?.roadster  else {
                    return nil
                }

                return RoadstarPresenter(with: roadster)
            }
            .sink(receiveCompletion:{_ in },receiveValue:{  [weak self] presenter in
                self?.presenter = presenter

            })
    }
}
