//
//  launchesViewModel.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import Foundation
import Combine

class LaunchesViewModel: NSObject,ObservableObject {
    
    private var task: Cancellable? = nil
    private var Launches: [Launch] = []
    @Published var presenters: [LaunchesPresenter] = []
    @Published var selectedViewModel: LaunchesDetailViewModel = LaunchesDetailViewModel()
    @Published var navigateToDetail: Bool = false 
    
    
    func onAppear(){
        self.task = Service.standard.get(path: .launches , responseType:[Launch].self)
            .map{[weak self] in
                self?.Launches = $0
                return $0.map{LaunchesPresenter(with: $0)}
            }
            .sink(receiveCompletion:{_ in },receiveValue:{  [weak self] presenters in
                self?.presenters = presenters
            })
    }
    
    func itemSelected(at item:LaunchesPresenter){
        guard let index = self.presenters.firstIndex(where:{$0.id == item.id}) else {
            return
        }
        self.selectedViewModel = LaunchesDetailViewModel(with: self.Launches[index])
        self.navigateToDetail = true 
    }
}
