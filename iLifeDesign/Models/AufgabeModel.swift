//
//  AufgabeModel.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.06.2024.
//

import Foundation
import SwiftData
import SwiftUI



@Model
class AufgabeModel {
    var aufgabe: String = ""
    var phase: Int = 0
    var sort: Int = 0
    var antwort: String = ""
    /// Wird automatisch gesetzt, sobald antwort nicht leer ist — nicht manuell.
    var erledigt: Bool = false
    /// Die letzte Frage jeder Phase — ihre Antwort wird beim Phasenwechsel als History gespeichert.
    var istAbschlussfrage: Bool = false
    var vorhaben: VorhabenModel?

    init(aufgabe: String = "", phase: Int = 0, sort: Int = 1, antwort: String = "", erledigt: Bool = false, istAbschlussfrage: Bool = false, vorhaben: VorhabenModel? = nil) {
        self.aufgabe = aufgabe
        self.phase = phase
        self.sort = sort
        self.antwort = antwort
        self.erledigt = erledigt
        self.istAbschlussfrage = istAbschlussfrage
        self.vorhaben = vorhaben
    }
}


func addStandardAufgaben(vorhaben: VorhabenModel) {
    vorhaben.aufgaben = []

    func addFrage(_ text: String, phase: Int, sort: Int, istAbschlussfrage: Bool = false) {
        vorhaben.aufgaben?.append(AufgabeModel(
            aufgabe: text,
            phase: phase,
            sort: sort,
            istAbschlussfrage: istAbschlussfrage,
            vorhaben: vorhaben
        ))
    }

    // Phase 0 – Der Kompass (Fokus & Ausrichtung)
    addFrage("Bedürfnis-Check: Welcher echte Wunsch liegt hinter Deinem Vorhaben?",       phase: 0, sort: 1)
    addFrage("Hürden-Check: Welche Bedenken oder Glaubenssätze wollen Dich stoppen?",     phase: 0, sort: 2)
    addFrage("Fokus-Satz: Formuliere Deinen Experiment-Fokus in einem klaren Satz",       phase: 0, sort: 3, istAbschlussfrage: true)

    // Phase 1 – Der Entwurf (Ideation & Vorbereitung)
    addFrage("Brainstorming: Sammle drei schnelle Umsetzungsvarianten",                   phase: 1, sort: 1)
    addFrage("Prototyp-Wahl: Wähle die kleinste, am schnellsten testbare Version",        phase: 1, sort: 2)
    addFrage("Rucksack packen: Welche Ressourcen, Tools oder Kontakte brauchst Du?",      phase: 1, sort: 3)
    addFrage("Start-Termin: Lege fest, wann Dein Test konkret beginnt",                   phase: 1, sort: 4, istAbschlussfrage: true)

    // Phase 2 – Der Test Run (Prototyping im Feld)
    addFrage("Ausführung: Führe Deinen Prototyp im echten Leben durch",                   phase: 2, sort: 1)
    addFrage("Gefühls-Snapshot: Wie fühlt sich die Umsetzung an?",                        phase: 2, sort: 2)
    addFrage("Beweis sichern: Halte einen Beleg fest — Foto, Text oder Notiz",            phase: 2, sort: 3, istAbschlussfrage: true)

    // Phase 3 – Das Logbuch (Auswertung & Erkenntnis)
    addFrage("Erkenntnis-Check: Was hat überrascht, gefehlt oder anders funktioniert?",   phase: 3, sort: 1)
    addFrage("Feedback: Hol Dir Rückmeldung von aussen oder schätze Dich selbst ein",     phase: 3, sort: 2)
    addFrage("Keep or Drop: Was behältst Du, was veränderst Du, was verwirfst Du?",       phase: 3, sort: 3, istAbschlussfrage: true)

    // Phase 4 – Der Schub (Kontinuität & Nächste Runde)
    addFrage("Verankerung: Welche Micro-Gewohnheit übernimmst Du in Deinen Alltag?",      phase: 4, sort: 1)
    addFrage("Energiemessung: Wie gross ist Deine Motivation für die nächste Runde?",     phase: 4, sort: 2)
    addFrage("Next Loop: Neue Runde mit Anpassung (Entwurf) oder neues Thema (Kompass)?", phase: 4, sort: 3, istAbschlussfrage: true)
}




