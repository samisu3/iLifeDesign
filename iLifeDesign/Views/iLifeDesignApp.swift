//
//  iLifeDesignApp.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 11.06.2024.
//  Modified by Sandra Sulzberger on 12.07.2026
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
            PhaseModel.self,
            PhaseReflexionModel.self,
            ErkenntnisModel.self,
        ])

        // Aktuelle Schema-Version als String (bei jedem inkompatiblen Umbau erhöhen)
        let currentSchemaVersion = "v13"
        let schemaVersionKey = "swiftdata_schema_version"

        if UserDefaults.standard.string(forKey: schemaVersionKey) != currentSchemaVersion {
            print("⚠️ Schema-Version geändert – SwiftData Store wird zurückgesetzt.")
            deleteSwiftDataStore()
            UserDefaults.standard.set(currentSchemaVersion, forKey: schemaVersionKey)
        }

        do {
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            print("❌ ModelContainer konnte nicht erstellt werden: \(error)")
            fatalError("ModelContainer-Fehler nach Store-Reset: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(container)
    }
}

// MARK: - Root View mit Setup

/// Separater View, damit modelContext beim onAppear zuverlässig verfügbar ist.
struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext

    /// Intro bei jedem Start zeigen, bis „Überspringen“ gewählt wird
    /// (in den Einstellungen wieder aktivierbar).
    @AppStorage("introBeimStart") private var introBeimStart = true
    @State private var zeigeIntro = false

    var body: some View {
        TabView {
            ExpeditionView()
                .tabItem { Label("Expedition", systemImage: "map") }
            LebensbereicheView()
                .tabItem { Label("Lebensbereiche", systemImage: "circle.hexagonpath") }
            LogbuchView()
                .tabItem { Label("Logbuch", systemImage: "trophy") }
            StatistikView()
                .tabItem { Label("Statistik", systemImage: "chart.bar.fill") }
        }
        .onAppear {
            // Standard-Daten genau einmal beim ersten Start anlegen.
            // Diese Funktionen prüfen intern ob Daten schon vorhanden sind.
            setupStandardLebensbereiche(context: modelContext)
            setupStandardPhasen(context: modelContext)

            if introBeimStart { zeigeIntro = true }
        }
        .fullScreenCover(isPresented: $zeigeIntro) {
            OnboardingView()
        }
    }
}

// MARK: - Store Reset Hilfsfunktion

private func deleteSwiftDataStore() {
    guard let appSupport = FileManager.default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .first else { return }

    let storeNames = ["default.store", "default.store-wal", "default.store-shm"]
    for name in storeNames {
        let url = appSupport.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: url)
    }
}
