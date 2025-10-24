//
//  RoadsterView.swift
//  SpaceXApp
//
//  Created by Abdalla El Najjar on 2023-03-13.
//

import SwiftUI
import Kingfisher
import WebKit

struct RoadsterView: View {
    @StateObject private var viewModel = RoadsterViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let presenter = viewModel.presenter {
                        Text(presenter.title ?? "SpaceX Roadster")
                            .font(.title)
                            .bold()

                        KFImage(URL(string: presenter.image ?? ""))
                            .cancelOnDisappear(true)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 265, maxHeight: 265)
                            .cornerRadius(12)

                        Text(String(format: "Speed: %.0f km/h", presenter.speed ?? 0))
                            .font(.headline)

                        Text(presenter.detail ?? "")
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal)

                        if let videoURL = presenter.videoURL, !videoURL.isEmpty {
                            YouTubeView(youtubeURL: videoURL)
                                .frame(height: 240)
                                .padding()
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitle("Roadster", displayMode: .inline)
        }
        .onAppear {
            viewModel.loadRoadsterIfNeeded()
        }
    }
}


struct YouTubeView: UIViewRepresentable {
    let youtubeURL: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: youtubeURL) else { return }
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: url))
    }
}

struct RoadsterView_Previews: PreviewProvider {
    static var previews: some View {
        RoadsterView()
    }
}
