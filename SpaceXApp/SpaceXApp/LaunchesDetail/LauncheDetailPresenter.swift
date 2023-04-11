//
//  LauncheDetailPresenter.swift.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-06.
//

struct LauncheDetailPresenter{
    let image:String
    let title:String
    let detail:String
    
    init(with model:Launch) {
        self.image = model.links.patch.large ?? ""
        self.title = model.name ?? ""
        self.detail = model.details ?? ""
    }
}
