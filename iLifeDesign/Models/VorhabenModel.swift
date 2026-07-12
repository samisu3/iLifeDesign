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


let VorhabenIcons: [Int: String] =
[ 0: "pencil",
  1: "phone",
  2: "house",
  3: "bicycle",
  4: "car",
  5: "sailboat",
  6: "sun.max",
  7: "snow",
  8: "paperplane",
  9: "figure.walk",
  10: "bell",
  11: "magnifyingglass",
  12: "bubble",
  13: "camera",
  14: "birthday.cake",
  15: "scooter",
  16: "gamecontroller",
  17: "airplane",
  18: "figure.2.arms.open",
  19: "figure.badminton",
  20: "heart",
  21: "star",
  22: "book",
  23: "iphone",
  24: "briefcase",
  25: "tree.fill",
  26: "key",
  27: "figure.dance",
  28: "map",
  29: "binoculars",
  30: "theatermasks.fill",
  31: "ladybug.fill",
  32: "books.vertical.fill",
  33: "moon.zzz.fill",
  34: "umbrella.fill",
  35: "paintbrush.pointed.fill",
  36: "leaf.fill",
  37: "clock.fill",
  38: "gift.fill",
  39: "graduationcap.fill",
  40: "heart.rectangle.fill",
  41: "phone.bubble.left.fill",
  42: "cloud.rain.fill",
  43: "building.columns.fill",
  44: "person.3.fill",
  45: "bell.fill",
  46: "hammer.fill",
  47: "star.fill",
  48: "crown.fill",
  49: "briefcase.fill",
  50: "speaker.wave.3.fill",
  51: "tshirt.fill",
  52: "exclamationmark.triangle.fill",
  53: "pawprint.fill",
  54: "heart.slash.fill",
  55: "infinity.circle.fill",
  56: "dice.fill",
  57: "heart.fill",
  58: "map.fill",
  59: "figure.wave",
  60: "mappin.and.ellipse",
  61: "facemask.fill",
  62: "smoke.fill",
  63: "eye.fill",
  64: "person.wave.2.fill",
  65: "mouth.fill",
  66: "trash.fill",
  67: "eyebrow",
  68: "shift.fill",
  69: "sun.max.fill",
  70: "lungs.fill",
  71: "hand.raised.fill",
  72: "ear.fill",
  73: "hand.thumbsup.fill",
  74: "hand.thumbsdown.fill",
  75: "hands.clap.fill",
  76: "hands.sparkles.fill",
  77: "flame.fill",
  78: "bolt.fill",
  79: "drop.fill",
  80: "hare.fill",
  81: "tortoise.fill",
  82: "ant.fill",
  83: "arrow.triangle.swap"
]

let VorhabenPhase: [Int: String] =
[ 0: "Idee",
  1: "Emphathie",
  2: "Fokus",
  3: "Inspiration",
  4: "Überwindung",
  5: "Prototyping",
  6: "Feedback",
  7: "Lernen",
  8: "Kontinuität",
  9: "Abgebrochen"
]

let VorhabenPhaseIcon: [Int: String] =
[ 0: "pencil",
  1: "heart",
  2: "magnifyingglass",
  3: "lightbulb.max",
  4: "sunrise",
  5: "play",
  6: "ear",
  7: "book",
  8: "party.popper",
  9: "x.circle"
]

let VorhabenPhaseInfo: [Int: String] =
[ 0: "Idee aufnehmen",
  1: "Wie fühlt es sich an?",
  2: "Was ist der Kern des Themas?",
  3: "Lösungsideen sammeln",
  4: "Einstieg einfach gestalten",
  5: "Erste Version ausprobieren",
  6: "Rückmeldungen sammeln.",
  7: "Was hast Du gelernt?",
  8: "Neuen Versuch starten.",
  9: "Das Vorhaben bringt nichts."
]

let PhaseColor: [Int: Color] =
[ 0: Color.colorIdee,
  1: Color.colorEmpathie,
  2: Color.colorFokus,
  3: Color.colorInspiration,
  4: Color.colorÜberwindung,
  5: Color.colorPrototyping,
  6: Color.colorFeedback,
  7: Color.colorLernen,
  8: Color.colorKontinuität,
  9: Color.colorAbgebrochen
]

let Vorhabenpriority: [Int: String] =
[   0: "★",
    1: "★★",
    2: "★★★",
    3: "★★★★",
    4: "★★★★★"
]

let Lebensbereiche: [Int: String] =
[ 0: "Gesundheit",
  1: "Soziales",
  2: "Sicherheit",
  3: "Arbeit",
  4: "Partnerschaft",
  5: "Wohnen",
  6: "Entwicklung",
  7: "Hobby",
  8: "Spiritualität",
]

let LebensbereicheIcon: [Int: String] =
[ 0: "cross.fill",                    // Gesundheit
  1: "person.2.fill",                 // Soziales
  2: "shield.fill",                   // Sicherheit
  3: "briefcase.fill",                // Arbeit
  4: "heart.fill",                    // Partnerschaft
  5: "house.fill",                    // Wohnen
  6: "graduationcap.fill",            // Entwicklung
  7: "gamecontroller.fill",           // Hobby
  8: "leaf.fill",                     // Spiritualität
]

let LebensbereicheColor: [Int: Color] =
[ 0: Color.green,
  1: Color.orange,
  2: Color.blue,
  3: Color.mint,
  4: Color.red,
  5: Color.brown,
  6: Color.cyan,
  7: Color.teal,
  8: Color.purple,
]



@Model
class VorhabenModel {
    var bezeichnung: String = ""
    var icon: Int = 0
    var phase: Int = 0
    var priority: Int = 0
    var beschreibung: String = ""
    /// Veraltetes Int-Feld – bleibt für Migration erhalten, wird aber nicht mehr aktiv genutzt.
    var lebensbereich: Int = 0
    /// Neue Beziehung zum LebensbereichModel
    var lebensbereichRef: LebensbereichModel?
    @Relationship(deleteRule: .cascade, inverse: \AufgabeModel.vorhaben)
    var aufgaben: [AufgabeModel]? = []
    
    init(bezeichnung: String = "", icon: Int = 0, phase: Int = 0, priority: Int = 1, beschreibung: String = "", lebensbereich: Int = 0, lebensbereichRef: LebensbereichModel? = nil, aufgaben: [AufgabeModel] = []) {
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
        guard let theIcon = VorhabenIcons[icon] else {return "" }
        return theIcon
    }
    
    var viewColor: Color {
        guard let theColor = PhaseColor[phase] else {return Color.red}
        return theColor
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
                for: VorhabenModel.self, LebensbereichModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            // Standard-Lebensbereiche anlegen
            setupStandardLebensbereiche(context: container.mainContext)

            let fetch = FetchDescriptor<LebensbereichModel>(sortBy: [SortDescriptor(\.sort)])
            let bereiche = (try? container.mainContext.fetch(fetch)) ?? []

            func bereich(_ sort: Int) -> LebensbereichModel? {
                bereiche.first { $0.sort == sort }
            }

            // Vorhabene
            let iLifeDesign = VorhabenModel(bezeichnung: "iLifeDesign", icon: 23, phase: 2, priority: 0, beschreibung: "Das iLifeDesign Tool machen", lebensbereich: 7, lebensbereichRef: bereich(7))
            container.mainContext.insert(iLifeDesign)
            addStandardAufgaben(vorhaben: iLifeDesign)

            let balkonEinrichten = VorhabenModel(bezeichnung: "Balkon Einrichten", icon: 2, phase: 1, priority: 1, beschreibung: "Den Balkon neu einrichten", lebensbereich: 5, lebensbereichRef: bereich(5))
            container.mainContext.insert(balkonEinrichten)
            addStandardAufgaben(vorhaben: balkonEinrichten)

            let neuJob = VorhabenModel(bezeichnung: "Neuen Job suchen", icon: 24, phase: 0, priority: 2, beschreibung: "Neuen (guten) Job suchen", lebensbereich: 3, lebensbereichRef: bereich(3))
            container.mainContext.insert(neuJob)
            addStandardAufgaben(vorhaben: neuJob)

            let buchSchreiben = VorhabenModel(bezeichnung: "Buch Schreiben", icon: 22, phase: 4, priority: 3, beschreibung: "Buch über mein Leben schreiben", lebensbereich: 3, lebensbereichRef: bereich(3))
            container.mainContext.insert(buchSchreiben)
            addStandardAufgaben(vorhaben: buchSchreiben)

            let weltReise = VorhabenModel(bezeichnung: "Weltreise", icon: 5, phase: 6, priority: 4, beschreibung: "Um die Welt in 80 Tagen", lebensbereich: 7, lebensbereichRef: bereich(7))
            container.mainContext.insert(weltReise)
            addStandardAufgaben(vorhaben: weltReise)

            let gartenPflegen = VorhabenModel(bezeichnung: "Garten pflegen", icon: 24, phase: 5, priority: 0, beschreibung: "Neue Wege anlegen", lebensbereich: 5, lebensbereichRef: bereich(5))
            container.mainContext.insert(gartenPflegen)
            addStandardAufgaben(vorhaben: gartenPflegen)

            let weiterBildung = VorhabenModel(bezeichnung: "Weiterbildung", icon: 29, phase: 3, priority: 1, beschreibung: "Bachelor in Software Entwicklung", lebensbereich: 6, lebensbereichRef: bereich(6))
            container.mainContext.insert(weiterBildung)
            addStandardAufgaben(vorhaben: weiterBildung)

            return container
        } catch {
            return try! ModelContainer(
                for: VorhabenModel.self, LebensbereichModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
    }
}


extension VorhabenModel {

        @MainActor
        static let preview2 = VorhabenModel(
            bezeichnung: "Test-Ziel",
            icon: 2,
            phase: 2,
            priority: 3,
            beschreibung: "Vorschauinhalt",
            lebensbereich: 1,
            aufgaben: []
        )
    }

