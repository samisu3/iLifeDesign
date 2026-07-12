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

    // Phase 0 – Idee
    addFrage("Beschreibe in ein paar Sätzen, um was es geht",           phase: 0, sort: 1)
    addFrage("Notiere, was Du Dir davon erhoffst",                       phase: 0, sort: 2)
    addFrage("Halte fest, wen dieses Vorhaben betrifft",                 phase: 0, sort: 3)
    addFrage("Überlege Dir einen möglichen ersten Schritt",              phase: 0, sort: 4)
    addFrage("Formuliere Dein Ziel in einem einzigen Satz",             phase: 0, sort: 5, istAbschlussfrage: true)

    // Phase 1 – Empathie
    addFrage("Schreibe auf, was Dir bei diesem Vorhaben wirklich wichtig ist", phase: 1, sort: 1)
    addFrage("Spür nach und beschreibe, wie es sich heute anfühlt",     phase: 1, sort: 2)
    addFrage("Erkenne und notiere Deine Stärken dafür",                 phase: 1, sort: 3)
    addFrage("Frag jemanden, dem Du vertraust — und halte die Antwort fest", phase: 1, sort: 4)
    addFrage("Formuliere Deine wichtigste Erkenntnis aus dieser Phase", phase: 1, sort: 5, istAbschlussfrage: true)

    // Phase 2 – Fokus
    addFrage("Formuliere das Problem als 'Wie könnte ich…'-Frage",      phase: 2, sort: 1)
    addFrage("Finde und benenne den eigentlichen Kern des Problems",     phase: 2, sort: 2)
    addFrage("Schreibe auf, was Du selbst konkret verändern kannst",    phase: 2, sort: 3)
    addFrage("Prüfe: Was daran ist attraktiv und wirklich lösbar?",     phase: 2, sort: 4)
    addFrage("Verfasse Deine finale, klare Problemformulierung",        phase: 2, sort: 5, istAbschlussfrage: true)

    // Phase 3 – Inspiration
    addFrage("Sammle alle Ideen, die Dir spontan einfallen",            phase: 3, sort: 1)
    addFrage("Denke gross: Was würdest Du tun, wenn alles möglich wäre?", phase: 3, sort: 2)
    addFrage("Wähle die Idee, die sich ohne grosses Risiko umsetzen lässt", phase: 3, sort: 3)
    addFrage("Entscheide Dich für eine Idee und halte sie fest",        phase: 3, sort: 4)
    addFrage("Begründe, warum genau diese Lösung der richtige Weg ist", phase: 3, sort: 5, istAbschlussfrage: true)

    // Phase 4 – Überwindung
    addFrage("Reserviere jetzt konkret Zeit in Deinem Kalender",        phase: 4, sort: 1)
    addFrage("Suche und gewinne mindestens eine Verbündete Person",     phase: 4, sort: 2)
    addFrage("Lege eine konkrete Belohnung fest, wenn Du es durchziehst", phase: 4, sort: 3)
    addFrage("Plane, was Du tust, wenn Du blockiert bist",              phase: 4, sort: 4)
    addFrage("Schreibe auf, warum Du jetzt anfängst",                   phase: 4, sort: 5, istAbschlussfrage: true)

    // Phase 5 – Prototyping
    addFrage("Definiere den kleinsten möglichen ersten Schritt und tu ihn", phase: 5, sort: 1)
    addFrage("Beziehe Deine Verbündeten aktiv mit ein",                 phase: 5, sort: 2)
    addFrage("Hol Dir konkrete Hilfe — frag jemanden direkt",           phase: 5, sort: 3)
    addFrage("Lege fest, was Du tust, wenn Du nicht weiterkommst",      phase: 5, sort: 4)
    addFrage("Beschreibe, was Du konkret getan hast",                   phase: 5, sort: 5, istAbschlussfrage: true)

    // Phase 6 – Feedback
    addFrage("Beschreibe ehrlich, wie Du Dich dabei gefühlt hast",      phase: 6, sort: 1)
    addFrage("Halte fest, was gut geklappt hat",                        phase: 6, sort: 2)
    addFrage("Benenne, was nicht wie erhofft lief",                     phase: 6, sort: 3)
    addFrage("Hol Dir Rückmeldungen von anderen und notiere sie",       phase: 6, sort: 4)
    addFrage("Ziehe Dein ehrlichstes persönliches Fazit",               phase: 6, sort: 5, istAbschlussfrage: true)

    // Phase 7 – Lernen
    addFrage("Benenne, was Du genau gleich wieder tun würdest",         phase: 7, sort: 1)
    addFrage("Erkenne, was Du beim nächsten Mal anders machen würdest", phase: 7, sort: 2)
    addFrage("Formuliere Dein grösstes Lernmoment in einem Satz",       phase: 7, sort: 3)
    addFrage("Lege eine konkrete Verbesserung für die nächste Runde fest", phase: 7, sort: 4)
    addFrage("Halte Deine wichtigste Lektion dauerhaft fest",           phase: 7, sort: 5, istAbschlussfrage: true)

    // Phase 8 – Kontinuität
    addFrage("Bedanke Dich persönlich bei Deinen Verbündeten",          phase: 8, sort: 1)
    addFrage("Löse Deine Belohnung jetzt ein — Du hast es verdient",    phase: 8, sort: 2)
    addFrage("Feier Deinen Erfolg bewusst und mit Freude",              phase: 8, sort: 3)
    addFrage("Plane den nächsten Zyklus dieses Vorhabens",              phase: 8, sort: 4)
    addFrage("Schreibe auf, was dieses Vorhaben für Dich bedeutet",     phase: 8, sort: 5, istAbschlussfrage: true)
}




