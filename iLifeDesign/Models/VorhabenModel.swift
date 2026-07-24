//
//  VorhabenModel.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.06.2024.
//

import Foundation
import SwiftData
import SwiftUI
import UIKit


// MARK: - Verfügbare Icons für Vorhaben (SF-Symbol-Namen, wie bei Phasen & Lebensbereichen)
let VorhabenVerfügbareIcons: [String] = [
    // Alltag & Zuhause
    "target", "house", "sofa.fill", "hammer.fill", "key", "tshirt.fill", "clock.fill",
    // Bewegung & Gesundheit
    "figure.walk", "figure.dance", "figure.badminton", "bicycle", "lungs.fill", "moon.zzz.fill", "heart", "heart.fill",
    // Reisen & Natur
    "airplane", "car", "sailboat", "map", "mappin.and.ellipse", "binoculars",
    "tree.fill", "leaf.fill", "sun.max", "snow", "umbrella.fill", "pawprint.fill",
    // Freizeit & Kreativität
    "gamecontroller", "camera", "paintbrush.pointed.fill", "theatermasks.fill", "dice.fill",
    "book", "books.vertical.fill",
    // Arbeit & Lernen
    "briefcase", "graduationcap.fill", "building.columns.fill", "pencil", "iphone",
    "magnifyingglass", "paperplane",
    // Menschen & Feiern
    "person.3.fill", "figure.2.arms.open", "person.wave.2.fill", "birthday.cake", "gift.fill",
    "bubble", "phone",
    // Symbole & Energie
    "star", "star.fill", "crown.fill", "flame.fill", "bolt.fill", "drop.fill", "bell",
]

// Legacy-Dictionaries — Fallback, wenn kein PhaseModel geladen ist.
// Werden direkt aus den PhaseDefaults abgeleitet, damit es nur eine Quelle gibt.
let VorhabenPhase: [Int: String] = Dictionary(
    uniqueKeysWithValues: PhaseDefaults.map { ($0.sort, $0.name) }
)

let VorhabenPhaseIcon: [Int: String] = Dictionary(
    uniqueKeysWithValues: PhaseDefaults.map { ($0.sort, $0.icon) }
)

let VorhabenPhaseInfo: [Int: String] = Dictionary(
    uniqueKeysWithValues: PhaseDefaults.map { ($0.sort, $0.info) }
)

/// Gibt die Default-Farbe einer Phase anhand ihrer Sortiernummer zurück.
/// Wird als Fallback genutzt, solange kein `PhaseModel` aus der Datenbank geladen ist.
func phaseDefaultColor(_ sort: Int) -> Color {
    let farbeID = PhaseDefaults.first { $0.sort == sort }?.farbeID ?? "blue"
    return Color.fromPhaseID(farbeID)
}

/// Legacy-Dictionary – wird schrittweise durch `PhaseModel.viewFarbe` abgelöst.
/// Nutzt jetzt die gleichen Farb-IDs wie das neue `PhaseModel`.
let PhaseColor: [Int: Color] = Dictionary(
    uniqueKeysWithValues: PhaseDefaults.map { ($0.sort, Color.fromPhaseID($0.farbeID)) }
)

let Vorhabenpriority: [Int: String] =
[   0: "★",
    1: "★★",
    2: "★★★",
    3: "★★★★",
    4: "★★★★★"
]

// Legacy-Dictionaries — Fallback, wenn keine LebensbereichModel-Referenz gesetzt ist.
// Werden direkt aus den LebensbereichDefaults abgeleitet, damit es nur eine Quelle gibt.
let Lebensbereiche: [Int: String] = Dictionary(
    uniqueKeysWithValues: LebensbereichDefaults.map { ($0.sort, $0.name) }
)

let LebensbereicheIcon: [Int: String] = Dictionary(
    uniqueKeysWithValues: LebensbereichDefaults.map { ($0.sort, $0.icon) }
)

let LebensbereicheColor: [Int: Color] = Dictionary(
    uniqueKeysWithValues: LebensbereichDefaults.map { ($0.sort, Color.fromLebensbereichID($0.farbeID)) }
)



@Model
class VorhabenModel {
    var bezeichnung: String = ""
    /// SF-Symbol-Name des Icons
    var icon: String = "target"
    var phase: Int = 0
    var priority: Int = 0
    var beschreibung: String = ""
    /// Veraltetes Int-Feld – bleibt für Migration erhalten, wird aber nicht mehr aktiv genutzt.
    var lebensbereich: Int = 0
    /// Neue Beziehung zum LebensbereichModel
    @Relationship(deleteRule: .nullify, inverse: \LebensbereichModel.vorhaben)
    var lebensbereichRef: LebensbereichModel?
    @Relationship(deleteRule: .cascade, inverse: \AufgabeModel.vorhaben)
    var aufgaben: [AufgabeModel]? = []
    /// Abschluss-Reflexionen pro Phase — neueste zuerst anzeigen
    @Relationship(deleteRule: .cascade, inverse: \PhaseReflexionModel.vorhaben)
    var reflexionen: [PhaseReflexionModel]? = []
    
    init(bezeichnung: String = "", icon: String = "target", phase: Int = 0, priority: Int = 1, beschreibung: String = "", lebensbereich: Int = 0, lebensbereichRef: LebensbereichModel? = nil, aufgaben: [AufgabeModel] = []) {
        self.bezeichnung = bezeichnung
        self.icon = icon
        self.phase = phase
        self.priority = priority
        self.beschreibung = beschreibung
        self.lebensbereich = lebensbereich
        self.lebensbereichRef = lebensbereichRef
        self.aufgaben = aufgaben
    }
}


extension VorhabenModel {

    var viewLebensbereich: String {
        if let ref = lebensbereichRef { return ref.name }
        return Lebensbereiche[lebensbereich] ?? ""
    }
    
    var viewLebensbereichIcon: String {
        if let ref = lebensbereichRef { return ref.icon }
        return LebensbereicheIcon[lebensbereich] ?? "circle"
    }

    var viewLebensbereichFarbe: Color {
        if let ref = lebensbereichRef { return ref.viewFarbe }
        return LebensbereicheColor[lebensbereich] ?? .gray
    }
    
    var viewPhase: String {
        guard let thePhase = VorhabenPhase[phase] else {return "" }
        return thePhase
    }
    
    var viewPhaseIcon: String {
        guard let thePhaseIcon = VorhabenPhaseIcon[phase] else {return "" }
        return thePhaseIcon
    }
    
    var viewPhaseInfo: String {
        guard let thePhaseInfo = VorhabenPhaseInfo[phase] else {return "" }
        return thePhaseInfo
    }
    
    var viewPhaseNr: String {
        "\(phase).circle.fill"
    }
    
    var viewIcon: String {
        icon.isEmpty ? "target" : icon
    }
    
    /// Fallback-Farbe basierend auf den Default-Phasenfarben.
    /// Wenn ein `PhaseModel` verfügbar ist, besser `phaseModel.viewFarbe` verwenden.
    var viewColor: Color {
        phaseDefaultColor(phase)
    }
    
    var viewpriority: String {
        guard let thePriority = Vorhabenpriority[priority] else {return "" }
        return thePriority
    }
    
    var viewSortedAufgabenIdee: [AufgabeModel] {
        aufgaben?.filter {$0.phase == 0}.sorted{$0.sort < $1.sort} ?? []
    }
    
    var viewAktuelleAufgaben: [AufgabeModel] {
       aufgaben?.filter {$0.phase == phase}.sorted{$0.sort < $1.sort} ?? []
    }
    
    var viewAktuelleAufgabenAnzahl: Int {
        aufgaben?.filter {$0.phase == phase}.count ?? 0
    }
    
    var viewAktuelleAufgabenAnzahlErledigt: Int {
        aufgaben?.filter {$0.phase == phase && $0.erledigt == true}.count ?? 0
    }
    
    var viewAktuellNächsteAufgabe: AufgabeModel? {
        let aktuelleAufgaben = viewAktuelleAufgaben
        let erledigteAnzahl = viewAktuelleAufgabenAnzahlErledigt
        guard erledigteAnzahl < aktuelleAufgaben.count else { return nil }
        return aktuelleAufgaben[erledigteAnzahl]
    }
    
    var viewAktuellErledigteAufgaben: [AufgabeModel] {
        aufgaben?.filter {$0.phase == phase && $0.erledigt == true}.sorted{$0.sort < $1.sort} ?? []
    }
    
    var viewAktuelleAufgabenErledigt: Bool {
        aufgaben?.filter {$0.phase == phase && $0.erledigt == false}.count == 0
    }
    
}

extension VorhabenModel {
    @MainActor
    static var preview: ModelContainer {
        do {
            let container = try ModelContainer(
                for: VorhabenModel.self, LebensbereichModel.self, PhaseModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            // Standard-Lebensbereiche und -Phasen anlegen
            setupStandardLebensbereiche(context: container.mainContext)
            setupStandardPhasen(context: container.mainContext)

            let fetch = FetchDescriptor<LebensbereichModel>(sortBy: [SortDescriptor(\.sort)])
            let bereiche = (try? container.mainContext.fetch(fetch)) ?? []

            func bereich(_ sort: Int) -> LebensbereichModel? {
                bereiche.first { $0.sort == sort }
            }

            // Vorhabene
            let iLifeDesign = VorhabenModel(bezeichnung: "iLifeDesign", icon: "iphone", phase: 2, priority: 0, beschreibung: "Das iLifeDesign Tool machen", lebensbereich: 2, lebensbereichRef: bereich(2))
            container.mainContext.insert(iLifeDesign)
            addStandardAufgaben(vorhaben: iLifeDesign)

            let balkonEinrichten = VorhabenModel(bezeichnung: "Balkon Einrichten", icon: "house", phase: 1, priority: 1, beschreibung: "Den Balkon neu einrichten", lebensbereich: 4, lebensbereichRef: bereich(4))
            container.mainContext.insert(balkonEinrichten)
            addStandardAufgaben(vorhaben: balkonEinrichten)

            let neuJob = VorhabenModel(bezeichnung: "Neuen Job suchen", icon: "briefcase", phase: 0, priority: 2, beschreibung: "Neuen (guten) Job suchen", lebensbereich: 1, lebensbereichRef: bereich(1))
            container.mainContext.insert(neuJob)
            addStandardAufgaben(vorhaben: neuJob)

            let buchSchreiben = VorhabenModel(bezeichnung: "Buch Schreiben", icon: "book", phase: 4, priority: 3, beschreibung: "Buch über mein Leben schreiben", lebensbereich: 1, lebensbereichRef: bereich(1))
            container.mainContext.insert(buchSchreiben)
            addStandardAufgaben(vorhaben: buchSchreiben)

            let weltReise = VorhabenModel(bezeichnung: "Weltreise", icon: "sailboat", phase: 3, priority: 4, beschreibung: "Um die Welt in 80 Tagen", lebensbereich: 2, lebensbereichRef: bereich(2))
            container.mainContext.insert(weltReise)
            addStandardAufgaben(vorhaben: weltReise)

            let gartenPflegen = VorhabenModel(bezeichnung: "Garten pflegen", icon: "tree.fill", phase: 2, priority: 0, beschreibung: "Neue Wege anlegen", lebensbereich: 4, lebensbereichRef: bereich(4))
            container.mainContext.insert(gartenPflegen)
            addStandardAufgaben(vorhaben: gartenPflegen)

            let weiterBildung = VorhabenModel(bezeichnung: "Weiterbildung", icon: "graduationcap.fill", phase: 1, priority: 1, beschreibung: "Bachelor in Software Entwicklung", lebensbereich: 0, lebensbereichRef: bereich(0))
            container.mainContext.insert(weiterBildung)
            addStandardAufgaben(vorhaben: weiterBildung)

            return container
        } catch {
            return try! ModelContainer(
                for: VorhabenModel.self, LebensbereichModel.self, PhaseModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
    }
}


extension VorhabenModel {

        @MainActor
        static let preview2 = VorhabenModel(
            bezeichnung: "Test-Ziel",
            icon: "house",
            phase: 2,
            priority: 3,
            beschreibung: "Vorschauinhalt",
            lebensbereich: 1,
            aufgaben: []
        )
    }

