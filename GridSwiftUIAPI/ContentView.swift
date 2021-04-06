//
//  ContentView.swift
//  GridSwiftUIAPI
//
//  Created by Анастасия Ларина on 05.04.2021.


import SwiftUI
//{
//    "feed": {
//
//        "results": [
//            {
//
//                "releaseDate": "2015-04-07",
//                "name": "HBO Max: Stream TV & Movies",
//                "copyright": "© 2020 WarnerMedia Direct, LLC. All Rights Reserved.",
//                "artworkUrl100": "https://is3-ssl.mzstatic.com/image/thumb/Purple124/v4/b4/03/76/b40376f7-832f-1ce0-cd27-4c7e5b2870e4/AppIconHBOMAX-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/200x200bb.png",
//
//                "url": "https://apps.apple.com/us/app/hbo-max-stream-tv-movies/id971265422"

struct RSS: Decodable {
    let feed: Feed
}

struct Feed: Decodable {
    let results:[Result]
}

struct Result: Decodable, Hashable {
    let artworkUrl100, name, releaseDate, copyright: String
}


class GridViewModel: ObservableObject {
    @Published var items = 0..<5
    
    @Published var results = [Result]()
    init() {
        //json decoding simulation
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (_) in
                    self.items = 0..<15
                }
        
        guard let url = URL(string: "https://rss.itunes.apple.com/api/v1/gb/ios-apps/new-apps-we-love/all/25/explicit.json") else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            // check response status and err
            guard let data = data else { return }
            do {
                let rss = try JSONDecoder().decode(RSS.self, from: data)
                 print(rss)
                self.results = rss.feed.results
            } catch {
                print("Failed to decode: \(error)")
            }
        }.resume()
    }
}
import Kingfisher

struct ContentView: View {
    @ObservedObject var vm = GridViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 100, maximum: 200), spacing: 16),
                    GridItem(.flexible(minimum: 100, maximum: 200), spacing: 16),
                ],alignment: .leading
                ,spacing: 16, content: {
                    ForEach(vm.results, id: \.self) { app in
                        AppInfo(app: app)
                    }
                }).padding(.horizontal, 12)
            }.navigationTitle("Grid API")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct AppInfo: View {
    let app: Result
    var body: some View {
       VStack(alignment: .leading, spacing: 5) {
                
                KFImage(URL(string: app.artworkUrl100))
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(22)

                Text(app.name)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.top, 4)
                Text(app.releaseDate)
                    .font(.system(size: 11, weight: .regular))
                Text(app.copyright)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
                Spacer()
            }
    }
}
