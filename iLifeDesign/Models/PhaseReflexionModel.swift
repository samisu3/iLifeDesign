//
//  PhaseReflexionModel.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 12.07.2026.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Model

@Model
class PhaseReflexionModel {
    /// Phasennummer 0–4, entspricht VorhabenModel.phase
    var phase: Int = 0
    /// Name der Phase zum Zeitpunkt der Speicherung (z.B. "Empathie")
    var phaseName: String = ""
    /// SF-Symbol-Name der Phase zum Zeitpunkt der Speicherung
    var phaseIcon: String = "circle"
    /// Farb-ID der Phase zum Zeitpunkt der Speicherung
    var phaseFarbeID: String = "blue"
    /// Die Abschlussfrage dieser Phase
    var frage: String = ""
    /// Die gespeicherte Antwort
    var antwort: String = ""
    /// Datum und Uhrzeit des Phasenwechsels
    var datum: Date = Date()

    var vorhaben: VorhabenModel?

    init(
        phase: Int,
        phaseName: String,
        phaseIcon: String,
        phaseFarbeID: String,
        frage: String,
        antwort: String,
        datum: Date = Date(),
        vorhaben: VorhabenModel? = nil
    ) {
        self.phase = phase
        self.phaseName = phaseName
        self.phaseIcon = phaseIcon
        self.phaseFarbeID = phaseFarbeID
        self.frage = frage
        self.antwort = antwort
        self.datum = datum
        self.vorhaben = vorhaben
    }
}

// MARK: - Computed Properties

extension PhaseReflexionModel {
    var viewFarbe: Color {
        Color.fromPhaseID(phaseFarbeID)
    }

    var viewDatum: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "de_CH")
        return formatter.string(from: datum)
    }
}
