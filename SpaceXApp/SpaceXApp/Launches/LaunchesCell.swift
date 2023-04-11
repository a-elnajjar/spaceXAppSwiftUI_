//
//  LaunchesCell.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import SwiftUI
import Kingfisher

struct LaunchesCell: View {
   private var presenters: LaunchesPresenter!
    
    init(presenters: LaunchesPresenter!) {
        self.presenters = presenters
    }
    
    var body: some View {
        HStack(alignment:.top,spacing:16){
            KFImage(URL(string: self.presenters.image))
                .cancelOnDisappear(true)
                .resizable()
                .frame( width: 128,height: 128)
            VStack(alignment: .leading, spacing:16){
                Text(presenters.name)
                Text(presenters.date)
        
            }
        }
    }
}

