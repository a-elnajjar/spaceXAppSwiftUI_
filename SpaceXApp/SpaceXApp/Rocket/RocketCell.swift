//
//  RockectCell.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-07.
//

import SwiftUI
import Kingfisher

struct RocketCell:View {
    private var presenter :RocketPresenter!
    
    
    init(presenter:RocketPresenter ){
        self.presenter = presenter
    }
    
    var body: some View {
        VStack(spacing: 16){
            KFImage(URL(string:self.presenter.image!))
                .cancelOnDisappear(true)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame( width: 600,height: 200)
            Text(self.presenter.name!)
        }
    }
}
