//
//  launchesPresenter.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-01.
//

import Foundation

struct LaunchesPresenter: Identifiable {
    let id: String
    let image: String
    let name: String
    let date: String

    init(with model: Launch) {
        self.id = model.id
        self.image = model.links.patch.small ?? ""
        self.name = model.name ?? ""

        if let date = model.dateUTC {
            self.date = date.getFormattedDate(format: "yyyy-MM-dd HH:mm:ss")
        } else {
            self.date = ""
        }
    }
}

extension Date {
   func getFormattedDate(format: String) -> String {
       let dateformat = DateFormatter()
       dateformat.dateFormat = format
       return dateformat.string(from: self)
    }
}
