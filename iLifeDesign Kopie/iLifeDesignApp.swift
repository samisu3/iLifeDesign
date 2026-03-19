//
//  iLifeDesignApp.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 11.06.2024.
//

import SwiftUI
import SwiftData

@main
struct iLifeDesignApp: App {
    var body: some Scene {
        WindowGroup {
            TabView{
               
                VorhabenListeView()
                    .tabItem {Label("Liste", systemImage: "list.dash")}
                VorhabenPhasenView()
                    .tabItem{Label("Phasen", systemImage: "infinity")}
                LebensbereicheView()
                    .tabItem{Label("Lebensbereiche", systemImage: "circle.hexagonpath")}
            }
          // .tabViewStyle(.page)
        }
        .modelContainer(for: VorhabenModel.self)
    }
}
