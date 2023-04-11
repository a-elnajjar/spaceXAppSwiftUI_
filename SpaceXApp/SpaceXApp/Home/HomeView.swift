//
//  HomeView.swift
//  SpaceXLaunchersViewer
//
//  Created by Abdalla El Najjar on 2023-03-07.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView{
            LaunchesView()
                .tabItem{
                    Image(systemName: "burst")
                    Text("Launches")
                }.tag(0)
            RocketsView()
                .tabItem{
                    Image(systemName: "location.north")
                    Text("Rrockets")
                }.tag(1)
            RoadsterView()
                .tabItem{
                    Image(systemName: "star")
                    Text("Roadster")
                }.tag(2)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}



