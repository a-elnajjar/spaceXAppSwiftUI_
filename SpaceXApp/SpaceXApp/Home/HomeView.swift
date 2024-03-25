import SwiftUI

struct HomeView: View {
    enum Tab: Int {
        case launches, rockets, roadster
    }
    
    var body: some View {
        TabView {
            LaunchesView()
                .tabItem {
                    TabItemView(imageName: "burst", text: "Launches")
                }.tag(Tab.launches.rawValue)
            
            RocketsView()
                .tabItem {
                    TabItemView(imageName: "location.north", text: "Rockets")
                }.tag(Tab.rockets.rawValue)
            
            RoadsterView()
                .tabItem {
                    TabItemView(imageName: "star", text: "Roadster")
                }.tag(Tab.roadster.rawValue)
        }
    }
}

struct TabItemView: View {
    let imageName: String
    let text: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
            Text(text)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}



