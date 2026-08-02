//
//  LebensbereichModel.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 12.07.2026.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Verfügbare Icons für Lebensbereiche
let LebensbereichVerfügbareIcons: [String] = [
    // Menschen & Körper
    "bolt.heart.fill", "cross.fill", "heart.fill", "figure.walk", "person.2.fill", "figure.2.arms.open",
    "person.3.fill", "person.wave.2.fill", "figure.dance", "lungs.fill", "brain.fill",
    // Zuhause & Sicherheit
    "house.fill", "shield.fill", "lock.fill", "key.fill", "hammer.fill",
    "sofa.fill", "bed.double.fill", "bathtub.fill",
    // Arbeit & Bildung
    "briefcase.fill", "graduationcap.fill", "books.vertical.fill", "book.fill",
    "pencil", "doc.fill", "chart.bar.fill", "building.columns.fill",
    // Natur & Hobby
    "fork.knife",
    "leaf.fill", "tree.fill", "gamecontroller.fill", "paintbrush.pointed.fill",
    "camera.fill", "music.note", "theatermasks.fill", "bicycle", "figure.badminton",
    "sailboat.fill", "airplane", "map.fill",
    // Spiritualität & Wachstum
    "sparkles", "sun.max.fill", "moon.zzz.fill", "flame.fill", "drop.fill",
    "infinity.circle.fill", "star.fill", "crown.fill",
    // Kommunikation & Soziales
    "bubble.fill", "phone.bubble.left.fill", "gift.fill", "birthday.cake",
    "hands.sparkles.fill", "hand.thumbsup.fill"
]

// MARK: - Verfügbare Farben für Lebensbereiche
struct LebensbereichFarbe: Identifiable {
    let id: String
    let name: String
    let color: Color
}

let LebensbereichVerfügbareFarben: [LebensbereichFarbe] = [
    LebensbereichFarbe(id: "green",   name: "Grün",      color: .green),
    LebensbereichFarbe(id: "orange",  name: "Orange",    color: .orange),
    LebensbereichFarbe(id: "blue",    name: "Blau",      color: .blue),
    LebensbereichFarbe(id: "mint",    name: "Mint",      color: .mint),
    LebensbereichFarbe(id: "red",     name: "Rot",       color: .red),
    LebensbereichFarbe(id: "brown",   name: "Braun",     color: .brown),
    LebensbereichFarbe(id: "cyan",    name: "Cyan",      color: .cyan),
    LebensbereichFarbe(id: "teal",    name: "Türkis",    color: .teal),
    LebensbereichFarbe(id: "purple",  name: "Lila",      color: .purple),
    LebensbereichFarbe(id: "pink",    name: "Pink",      color: .pink),
    LebensbereichFarbe(id: "yellow",  name: "Gelb",      color: .yellow),
    LebensbereichFarbe(id: "indigo",  name: "Indigo",    color: .indigo),
    LebensbereichFarbe(id: "gray",    name: "Grau",      color: .gray),
]

// Hilfsfunktionen zur Konvertierung von Farb-IDs
extension Color {
    static func fromLebensbereichID(_ id: String) -> Color {
        LebensbereichVerfügbareFarben.first { $0.id == id }?.color ?? .blue
    }

    var lebensbereichID: String {
        // Einfacher Vergleich über die Farbnamen
        for farbe in LebensbereichVerfügbareFarben {
            if self == farbe.color { return farbe.id }
        }
        return "blue"
    }
}

// MARK: - Default-Daten: Die 7 Zimmer des Hauses
// Jeder Lebensbereich entspricht einem Zimmer im eigenen Haus —
// vom Dachboden (Träume & Visionen) bis zum Garten (Fundament & Umfeld).

struct LebensbereichDefault {
    let sort: Int
    let name: String
    let beschreibung: String
    let icon: String
    let farbeID: String
}

let LebensbereichDefaults: [LebensbereichDefault] = [
    LebensbereichDefault(sort: 0, name: "Dachboden",       beschreibung: "Grosse Lebensziele & Fernweh-Ideen",           icon: "sparkles",               farbeID: "brown"),
    LebensbereichDefault(sort: 1, name: "Arbeitszimmer",   beschreibung: "Beruf, Fokus & kreatives Handwerk",            icon: "briefcase.fill",         farbeID: "blue"),
    LebensbereichDefault(sort: 2, name: "Hobbyraum",       beschreibung: "Experimente & freie Entfaltung ohne Druck",    icon: "paintbrush.pointed.fill", farbeID: "orange"),
    LebensbereichDefault(sort: 3, name: "Wohnzimmer",      beschreibung: "Beziehungen, Werte & Gemeinschaft",            icon: "sofa.fill",              farbeID: "yellow"),
    LebensbereichDefault(sort: 4, name: "Badezimmer",      beschreibung: "Mentale Hygiene & Selbstfürsorge",             icon: "bathtub.fill",           farbeID: "mint"),
    LebensbereichDefault(sort: 5, name: "Küche",           beschreibung: "Vitalität, Energie & Ernährung",               icon: "fork.knife",             farbeID: "green"),
    LebensbereichDefault(sort: 6, name: "Garten & Veranda",beschreibung: "Zuhause, Umfeld & finanzielles Fundament",     icon: "leaf.fill",              farbeID: "teal"),
]

// MARK: - SwiftData Model

@Model
class LebensbereichModel {
    var name: String = ""
    var beschreibung: String = ""
    var icon: String = "circle.fill"
    var farbeID: String = "blue"
    var sort: Int = 0
    var istAktiv: Bool = true
    /// Selbsteinschätzung 1–10: Wie zufrieden bin ich aktuell in dieser Dimension?
    var einschaetzung: Int = 5

    var vorhaben: [VorhabenModel]? = []

    init(
        name: String = "",
        beschreibung: String = "",
        icon: String = "circle.fill",
        farbeID: String = "blue",
        sort: Int = 0,
        istAktiv: Bool = true,
        einschaetzung: Int = 5
    ) {
        self.name = name
        self.beschreibung = beschreibung
        self.icon = icon
        self.farbeID = farbeID
        self.sort = sort
        self.istAktiv = istAktiv
        self.einschaetzung = einschaetzung
    }
}

// MARK: - Computed Properties

extension LebensbereichModel {

    var viewFarbe: Color {
        Color.fromLebensbereichID(farbeID)
    }

    var viewVorhabenAnzahl: Int {
        vorhaben?.count ?? 0
    }
}

// MARK: - Standard-Lebensbereiche anlegen

/// Legt alle Standard-Lebensbereiche in den ModelContext ein,
/// falls noch keine vorhanden sind.
@MainActor
func setupStandardLebensbereiche(context: ModelContext) {
    let fetch = FetchDescriptor<LebensbereichModel>()
    let vorhandene = (try? context.fetch(fetch)) ?? []
    guard vorhandene.isEmpty else { return }

    for default_ in LebensbereichDefaults {
        let bereich = LebensbereichModel(
            name: default_.name,
            beschreibung: default_.beschreibung,
            icon: default_.icon,
            farbeID: default_.farbeID,
            sort: default_.sort
        )
        context.insert(bereich)
    }
}
