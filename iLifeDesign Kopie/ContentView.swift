//
//  ContentView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 11.06.2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: ExperimentModel.preview)
}
