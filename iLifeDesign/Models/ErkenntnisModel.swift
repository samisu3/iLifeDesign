//
//  ErkenntnisModel.swift
//  iLifeDesign
//
//  Der Erkenntnis-Speicher: Beim Abschluss der Logbuch-Phase wird die
//  Antwort auf den Erkenntnis-Check dauerhaft gesichert — als persönlicher
//  Wissensschatz für zukünftige Experimente. Bewusst ohne Relationship,
//  damit Erkenntnisse auch gelöschte Vorhaben überleben.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class ErkenntnisModel {
    /// Die Erkenntnis selbst (Antwort auf den Erkenntnis-Check)
    var text: String = ""
    /// Name des Vorhabens, aus dem die Erkenntnis stammt (Snapshot)
    var quelle: String = ""
    /// Icon der Dimension zum Zeitpunkt der Speicherung
    var icon: String = "lightbulb"
    /// Farb-ID der Dimension zum Zeitpunkt der Speicherung
    var farbeID: String = "blue"
    var datum: Date = Date()

    init(
        text: String = "",
        quelle: String = "",
        icon: String = "lightbulb",
        farbeID: String = "blue",
        datum: Date = Date()
    ) {
        self.text = text
        self.quelle = quelle
        self.icon = icon
        self.farbeID = farbeID
        self.datum = datum
    }
}

extension ErkenntnisModel {
    var viewFarbe: Color {
        Color.fromLebensbereichID(farbeID)
    }

    var viewDatum: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "de_CH")
        return formatter.string(from: datum)
    }
}
