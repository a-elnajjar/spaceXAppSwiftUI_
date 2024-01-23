//
//  RoadstarPresenter.swift
//  SpaceXApp
//
//  Created by Abdalla El Najjar on 2023-03-13.
//

import Foundation

struct RoadstarPresenter {

    
    let image:String?
    let title:String?
    let detail:String?
    let speed:Double?
    let videoURL:String?

    init(with model:RoadsterModel) {
        self.image = model.flickrImages.first ?? ""
        self.title = model.name 
        self.detail = model.details 
        self.speed = model.speedKph 
        self.videoURL =  model.video 
    }
}
