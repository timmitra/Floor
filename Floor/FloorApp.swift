//
//  FloorApp.swift
//  Floor
//
//  Created by Tim Mitra on 2023-12-16.
//

import SwiftUI

@main
struct FloorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
