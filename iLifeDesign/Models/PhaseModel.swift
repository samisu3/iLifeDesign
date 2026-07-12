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

// MARK: - Default-Daten

struct PhaseDefault {
    let sort: Int
    let name: String
    let info: String
    let icon: String
    let farbeID: String
}

let PhaseDefaults: [PhaseDefault] = [
    PhaseDefault(sort: 0, name: "Idee",        info: "Idee aufnehmen",                  icon: "pencil",           farbeID: "blue"),
    PhaseDefault(sort: 1, name: "Empathie",    info: "Wie fühlt es sich an?",           icon: "heart",            farbeID: "pink"),
    PhaseDefault(sort: 2, name: "Fokus",       info: "Was ist der Kern des Themas?",    icon: "magnifyingglass",  farbeID: "cyan"),
    PhaseDefault(sort: 3, name: "Inspiration", info: "Lösungsideen sammeln",            icon: "lightbulb.max",    farbeID: "yellow"),
    PhaseDefault(sort: 4, name: "Überwindung", info: "Einstieg einfach gestalten",      icon: "sunrise",          farbeID: "orange"),
    PhaseDefault(sort: 5, name: "Prototyping", info: "Erste Version ausprobieren",      icon: "play",             farbeID: "green"),
    PhaseDefault(sort: 6, name: "Feedback",    info: "Rückmeldungen sammeln.",          icon: "ear",              farbeID: "teal"),
    PhaseDefault(sort: 7, name: "Lernen",      info: "Was hast Du gelernt?",            icon: "book",             farbeID: "indigo"),
    PhaseDefault(sort: 8, name: "Kontinuität", info: "Neuen Versuch starten.",          icon: "party.popper",     farbeID: "purple"),
    PhaseDefault(sort: 9, name: "Abgebrochen", info: "Das Vorhaben bringt nichts.",     icon: "x.circle",         farbeID: "gray"),
]

// MARK: - SwiftData Model

@Model
class PhaseModel {
    /// Unveränderliche Nummer 0–9 — entspricht VorhabenModel.phase
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

/// Legt alle 10 Standard-Phasen in den ModelContext ein,
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

/// Hilfsfunktion: Alle 10 Phasen geordnet laden
@MainActor
func fetchAllePhasen(context: ModelContext) -> [PhaseModel] {
    let fetch = FetchDescriptor<PhaseModel>(sortBy: [SortDescriptor(\.sort)])
    return (try? context.fetch(fetch)) ?? []
}
