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
    "cross.fill", "heart.fill", "figure.walk", "person.2.fill", "figure.2.arms.open",
    "person.3.fill", "person.wave.2.fill", "figure.dance", "lungs.fill", "brain.fill",
    // Zuhause & Sicherheit
    "house.fill", "shield.fill", "lock.fill", "key.fill", "hammer.fill",
    "sofa.fill", "bed.double.fill", "bathtub.fill",
    // Arbeit & Bildung
    "briefcase.fill", "graduationcap.fill", "books.vertical.fill", "book.fill",
    "pencil", "doc.fill", "chart.bar.fill", "building.columns.fill",
    // Natur & Hobby
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

// MARK: - Default-Daten für Lebensbereiche

struct LebensbereichDefault {
    let sort: Int
    let name: String
    let beschreibung: String
    let icon: String
    let farbeID: String
    let priorität: Int
}

let LebensbereichDefaults: [LebensbereichDefault] = [
    LebensbereichDefault(sort: 0, name: "Gesundheit",     beschreibung: "Körper, Geist und Wohlbefinden", icon: "cross.fill",            farbeID: "green",  priorität: 3),
    LebensbereichDefault(sort: 1, name: "Soziales",       beschreibung: "Freunde, Familie und Netzwerk",  icon: "person.2.fill",         farbeID: "orange", priorität: 3),
    LebensbereichDefault(sort: 2, name: "Sicherheit",     beschreibung: "Finanzen, Schutz und Stabilität",icon: "shield.fill",           farbeID: "blue",   priorität: 3),
    LebensbereichDefault(sort: 3, name: "Arbeit",         beschreibung: "Beruf, Karriere und Leistung",   icon: "briefcase.fill",        farbeID: "mint",   priorität: 3),
    LebensbereichDefault(sort: 4, name: "Partnerschaft",  beschreibung: "Liebe, Beziehung und Intimität", icon: "heart.fill",            farbeID: "red",    priorität: 3),
    LebensbereichDefault(sort: 5, name: "Wohnen",         beschreibung: "Zuhause, Umgebung und Raum",     icon: "house.fill",            farbeID: "brown",  priorität: 3),
    LebensbereichDefault(sort: 6, name: "Entwicklung",    beschreibung: "Lernen, Wachstum und Bildung",   icon: "graduationcap.fill",    farbeID: "cyan",   priorität: 3),
    LebensbereichDefault(sort: 7, name: "Hobby",          beschreibung: "Freizeit, Spass und Kreativität",icon: "gamecontroller.fill",   farbeID: "teal",   priorität: 3),
    LebensbereichDefault(sort: 8, name: "Spiritualität",  beschreibung: "Sinn, Werte und innere Stärke",  icon: "leaf.fill",             farbeID: "purple", priorität: 3),
]

// MARK: - SwiftData Model

@Model
class LebensbereichModel {
    var name: String = ""
    var beschreibung: String = ""
    var icon: String = "circle.fill"
    var farbeID: String = "blue"
    var priorität: Int = 3
    var sort: Int = 0
    var istAktiv: Bool = true

    @Relationship(deleteRule: .nullify, inverse: \VorhabenModel.lebensbereichRef)
    var vorhaben: [VorhabenModel]? = []

    init(
        name: String = "",
        beschreibung: String = "",
        icon: String = "circle.fill",
        farbeID: String = "blue",
        priorität: Int = 3,
        sort: Int = 0,
        istAktiv: Bool = true
    ) {
        self.name = name
        self.beschreibung = beschreibung
        self.icon = icon
        self.farbeID = farbeID
        self.priorität = priorität
        self.sort = sort
        self.istAktiv = istAktiv
    }
}

// MARK: - Computed Properties

extension LebensbereichModel {

    var viewFarbe: Color {
        Color.fromLebensbereichID(farbeID)
    }

    var viewPrioritätSterne: String {
        String(repeating: "★", count: priorität) + String(repeating: "☆", count: 5 - priorität)
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
            priorität: default_.priorität,
            sort: default_.sort
        )
        context.insert(bereich)
    }
}
