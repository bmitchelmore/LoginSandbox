//
//  PeerAdvertiserApp.swift
//  PeerAdvertiser
//
//  Created by Blair Mitchelmore on 2023-11-16.
//

import SwiftUI

@main
struct PeerAdvertiserApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(PeerAdvertiser())
        }
    }
}
