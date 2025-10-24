//
//  LaunchesCell.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import SwiftUI
import Kingfisher

struct LaunchesCell: View {
    private let presenter: LaunchesPresenter
    @Binding var isParentGrid: Bool

    init(presenters: LaunchesPresenter, isParentGrid: Binding<Bool>) {
        self.presenter = presenters
        self._isParentGrid = isParentGrid
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            KFImage(URL(string: presenter.image))
                .cancelOnDisappear(true)
                .resizable()
                .scaledToFill()
                .frame(width: 128, height: 128)
                .clipped()

            if !isParentGrid {
                VStack(alignment: .leading, spacing: 8) {
                    Text(presenter.name)
                        .font(.headline)
                    Text(presenter.date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

