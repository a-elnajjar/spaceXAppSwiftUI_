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
    @Binding var isParentGrid: Bool
    
    // Initialize all stored properties in the init method
    init(presenters: LaunchesPresenter, isParentGrid: Binding<Bool>) {
        self.presenters = presenters
        self._isParentGrid = isParentGrid
    }
    
    var body: some View {
        HStack(alignment:.top,spacing:16){
            KFImage(URL(string: self.presenters.image))
                .cancelOnDisappear(true)
                .resizable()
                .frame( width: 128,height: 128)
            if !isParentGrid {
                // Show or hide VStack based on isParentGrid
                VStack {
                    Text(presenters.name)
                    Text(presenters.date)
                }
            } 
        }
    }
}

