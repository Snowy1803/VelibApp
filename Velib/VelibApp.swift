//
//  VelibApp.swift
//  Velib
//
//  Created by Emil Pedersen on 14/06/2022.
//

import SwiftUI

@main
struct VelibApp: App {
    @StateObject var fetcher = VelibFetcher()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(fetcher)
        }
    }
}
