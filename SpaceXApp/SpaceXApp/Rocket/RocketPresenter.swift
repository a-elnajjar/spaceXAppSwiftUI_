//
//  RockectPresenter.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-07.
//

import Foundation
struct RocketPresenter:Identifiable{
    let id = UUID()
    let image:String?
    let name:String?
    
    
    init(with model: RocketModel) {
        self.image  = model.flickrImages.first ?? ""
        self.name =  model.name ?? ""
    }
}
