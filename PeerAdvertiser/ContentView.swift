//
//  ContentView.swift
//  PeerAdvertiser
//
//  Created by Blair Mitchelmore on 2023-11-16.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var peerAdvertiser: PeerAdvertiser
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            peerAdvertiser.start()
        }
    }
}

#Preview {
    ContentView()
}
