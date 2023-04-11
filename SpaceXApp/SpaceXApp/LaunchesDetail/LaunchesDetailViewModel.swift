//
//  LaunchesDetailView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-06.
//

import Foundation

final class LaunchesDetailViewModel: ObservableObject{
    @Published var presenter: LauncheDetailPresenter?

    init(){
        
    }
    
    init(with model: Launch) {
        self.presenter = LauncheDetailPresenter(with: model)
    }
}
