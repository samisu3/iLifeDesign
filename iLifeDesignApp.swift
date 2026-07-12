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

    let container: ModelContainer = {
        let schema = Schema([
            VorhabenModel.self,
            AufgabeModel.self,
            LebensbereichModel.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            // Falls das Schema inkompatibel ist, alten Store löschen und neu aufsetzen.
            // Das passiert nur einmal beim ersten Start nach einem grösseren Schema-Umbau.
            print("⚠️ ModelContainer konnte nicht geladen werden: \(error)")
            print("⚠️ Store wird zurückgesetzt.")
            let config2 = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            // Store-Datei manuell löschen und neu erstellen
            if let storeURL = URL.applicationSupportDirectory
                .appending(path: "default.store", directoryHint: .notDirectory) as URL? {
                try? FileManager.default.removeItem(at: storeURL)
                // Auch WAL und SHM Dateien löschen
                try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
                try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
            }
            return try! ModelContainer(for: schema, configurations: config2)
        }
    }()

    var body: some Scene {
        WindowGroup {
            TabView {
                VorhabenListeView()
                    .tabItem { Label("Liste", systemImage: "list.dash") }
                PhasenListeView()
                    .tabItem { Label("Phasen", systemImage: "infinity") }
                LebensbereicheView()
                    .tabItem { Label("Lebensbereiche", systemImage: "circle.hexagonpath") }
            }
        }
        .modelContainer(container)
    }
}
