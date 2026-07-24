//
//  PhaseModel.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 12.07.2026.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Verfügbare Icons für Phasen

let PhaseVerfügbareIcons: [String] = [
    // Kompass & Loop
    "safari", "safari.fill", "map.fill", "figure.run", "arrow.triangle.2.circlepath",
    // Prozess & Idee
    "pencil", "lightbulb.max", "lightbulb.fill", "brain.fill", "sparkles",
    // Herz & Empathie
    "heart", "heart.fill", "hand.raised.fill", "hands.sparkles.fill", "ear.fill",
    // Suche & Fokus
    "magnifyingglass", "scope", "target", "arrow.down.to.line", "checkmark.seal.fill",
    // Start & Überwindung
    "sunrise", "sun.max.fill", "bolt.fill", "flame.fill", "figure.wave",
    // Prototyping & Aktion
    "play", "play.fill", "hammer.fill", "wrench.and.screwdriver.fill", "gearshape.fill",
    // Feedback & Kommunikation
    "ear", "bubble.fill", "phone.bubble.left.fill", "megaphone.fill", "person.wave.2.fill",
    // Lernen & Wachstum
    "book", "book.fill", "graduationcap.fill", "books.vertical.fill", "chart.line.uptrend.xyaxis",
    // Feier & Kontinuität
    "party.popper", "party.popper.fill", "star.fill", "crown.fill", "trophy.fill",
    // Abschluss & Stop
    "x.circle", "x.circle.fill", "stop.fill", "archivebox.fill", "checkmark.circle.fill",
]

// MARK: - Farben (identisch mit Lebensbereichen)

struct PhaseFarbe: Identifiable {
    let id: String
    let name: String
    let color: Color
}

let PhaseVerfügbareFarben: [PhaseFarbe] = [
    PhaseFarbe(id: "blue",   name: "Blau",    color: .blue),
    PhaseFarbe(id: "green",  name: "Grün",    color: .green),
    PhaseFarbe(id: "orange", name: "Orange",  color: .orange),
    PhaseFarbe(id: "mint",   name: "Mint",    color: .mint),
    PhaseFarbe(id: "red",    name: "Rot",     color: .red),
    PhaseFarbe(id: "brown",  name: "Braun",   color: .brown),
    PhaseFarbe(id: "cyan",   name: "Cyan",    color: .cyan),
    PhaseFarbe(id: "teal",   name: "Türkis",  color: .teal),
    PhaseFarbe(id: "purple", name: "Lila",    color: .purple),
    PhaseFarbe(id: "pink",   name: "Pink",    color: .pink),
    PhaseFarbe(id: "yellow", name: "Gelb",    color: .yellow),
    PhaseFarbe(id: "indigo", name: "Indigo",  color: .indigo),
    PhaseFarbe(id: "gray",   name: "Grau",    color: .gray),
]

extension Color {
    static func fromPhaseID(_ id: String) -> Color {
        PhaseVerfügbareFarben.first { $0.id == id }?.color ?? .blue
    }
}

// MARK: - Default-Daten: Der 5-Phasen-Expeditions-Loop
// Schlankes, dynamisches Modell — nach der letzten Phase startet der Kreislauf neu.

struct PhaseDefault {
    let sort: Int
    let name: String
    let info: String
    let icon: String
    let farbeID: String
}

let PhaseDefaults: [PhaseDefault] = [
    PhaseDefault(sort: 0, name: "Der Kompass",  info: "Standort bestimmen & Fokus schärfen",   icon: "safari",                       farbeID: "blue"),
    PhaseDefault(sort: 1, name: "Der Entwurf",  info: "Ideen sammeln & Experiment planen",     icon: "lightbulb.max",                farbeID: "yellow"),
    PhaseDefault(sort: 2, name: "Der Test Run", info: "Ausprobieren im echten Alltag",         icon: "figure.run",                   farbeID: "green"),
    PhaseDefault(sort: 3, name: "Das Logbuch",  info: "Bilanz ziehen & Erkenntnisse sichern",  icon: "book",                         farbeID: "indigo"),
    PhaseDefault(sort: 4, name: "Der Schub",    info: "Verankern & nächste Runde starten",     icon: "arrow.triangle.2.circlepath",  farbeID: "purple"),
]

// MARK: - SwiftData Model

@Model
class PhaseModel {
    /// Unveränderliche Nummer 0–4 — entspricht VorhabenModel.phase
    var sort: Int = 0
    var name: String = ""
    var info: String = ""
    var icon: String = "circle.fill"
    var farbeID: String = "blue"

    init(sort: Int = 0, name: String = "", info: String = "", icon: String = "circle.fill", farbeID: String = "blue") {
        self.sort = sort
        self.name = name
        self.info = info
        self.icon = icon
        self.farbeID = farbeID
    }
}

// MARK: - Computed Properties

extension PhaseModel {
    var viewFarbe: Color {
        Color.fromPhaseID(farbeID)
    }
}

// MARK: - Standard-Phasen anlegen

/// Legt alle 5 Standard-Phasen in den ModelContext ein,
/// falls noch keine vorhanden sind.
@MainActor
func setupStandardPhasen(context: ModelContext) {
    let fetch = FetchDescriptor<PhaseModel>()
    let vorhandene = (try? context.fetch(fetch)) ?? []
    guard vorhandene.isEmpty else { return }

    for default_ in PhaseDefaults {
        let phase = PhaseModel(
            sort: default_.sort,
            name: default_.name,
            info: default_.info,
            icon: default_.icon,
            farbeID: default_.farbeID
        )
        context.insert(phase)
    }
}

/// Hilfsfunktion: Alle 5 Phasen geordnet laden
@MainActor
func fetchAllePhasen(context: ModelContext) -> [PhaseModel] {
    let fetch = FetchDescriptor<PhaseModel>(sortBy: [SortDescriptor(\.sort)])
    return (try? context.fetch(fetch)) ?? []
}
