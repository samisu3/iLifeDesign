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
    addFrage("Um was geht es?",                         phase: 0, sort: 1)
    addFrage("Was erhoffst Du Dir davon?",              phase: 0, sort: 2)
    addFrage("Wen betrifft es?",                        phase: 0, sort: 3)
    addFrage("Was wäre ein erster Schritt?",            phase: 0, sort: 4)
    addFrage("Was ist Dein Ziel in einem Satz?",        phase: 0, sort: 5, istAbschlussfrage: true)

    // Phase 1 – Empathie
    addFrage("Was ist Dir dabei wichtig?",              phase: 1, sort: 1)
    addFrage("Wie fühlt es sich heute an?",             phase: 1, sort: 2)
    addFrage("Welche Stärken hast Du dafür?",           phase: 1, sort: 3)
    addFrage("Was würde jemand, dem Du vertraust, dazu sagen?", phase: 1, sort: 4)
    addFrage("Was ist Deine wichtigste Erkenntnis?",    phase: 1, sort: 5, istAbschlussfrage: true)

    // Phase 2 – Fokus
    addFrage("Formuliere das Problem mit 'Wie könnte ich…'?", phase: 2, sort: 1)
    addFrage("Was ist der Kern davon?",                 phase: 2, sort: 2)
    addFrage("Was kannst Du selbst verändern?",         phase: 2, sort: 3)
    addFrage("Was ist daran attraktiv und lösbar?",     phase: 2, sort: 4)
    addFrage("Deine finale Problemformulierung?",       phase: 2, sort: 5, istAbschlussfrage: true)

    // Phase 3 – Inspiration
    addFrage("Was sind Deine ersten Ideen?",            phase: 3, sort: 1)
    addFrage("Was würdest Du tun, wenn alles möglich wäre?", phase: 3, sort: 2)
    addFrage("Was lässt sich ohne grosses Risiko umsetzen?", phase: 3, sort: 3)
    addFrage("Welche eine Idee nimmst Du weiter?",      phase: 3, sort: 4)
    addFrage("Warum diese Lösung?",                     phase: 3, sort: 5, istAbschlussfrage: true)

    // Phase 4 – Überwindung
    addFrage("Hast Du Zeit reserviert?",                phase: 4, sort: 1)
    addFrage("Hast Du Verbündete gefunden?",            phase: 4, sort: 2)
    addFrage("Was ist Deine Belohnung, wenn Du es durchziehst?", phase: 4, sort: 3)
    addFrage("Was tust Du, wenn Du blockiert bist?",    phase: 4, sort: 4)
    addFrage("Ich fange an, weil…",                    phase: 4, sort: 5, istAbschlussfrage: true)

    // Phase 5 – Prototyping
    addFrage("Was ist der erste kleine Schritt?",       phase: 5, sort: 1)
    addFrage("Hast Du Verbündete einbezogen?",          phase: 5, sort: 2)
    addFrage("Gibt es jemanden, der Dir hilft?",        phase: 5, sort: 3)
    addFrage("Was machst Du, wenn Du nicht weiterkommst?", phase: 5, sort: 4)
    addFrage("Was habe ich konkret getan?",             phase: 5, sort: 5, istAbschlussfrage: true)

    // Phase 6 – Feedback
    addFrage("Wie hast Du Dich gefühlt?",               phase: 6, sort: 1)
    addFrage("Was hat gut geklappt?",                   phase: 6, sort: 2)
    addFrage("Was war nicht wie erhofft?",              phase: 6, sort: 3)
    addFrage("Was sagen andere dazu?",                  phase: 6, sort: 4)
    addFrage("Mein ehrlichstes Fazit?",                 phase: 6, sort: 5, istAbschlussfrage: true)

    // Phase 7 – Lernen
    addFrage("Was würdest Du genau gleich machen?",     phase: 7, sort: 1)
    addFrage("Was würdest Du anders machen?",           phase: 7, sort: 2)
    addFrage("Was hast Du gelernt?",                    phase: 7, sort: 3)
    addFrage("Was verbesserst Du in der nächsten Runde?", phase: 7, sort: 4)
    addFrage("Meine wichtigste Lektion?",               phase: 7, sort: 5, istAbschlussfrage: true)

    // Phase 8 – Kontinuität
    addFrage("Hast Du Dich bei Deinen Verbündeten bedankt?", phase: 8, sort: 1)
    addFrage("Hast Du Deine Belohnung eingelöst?",      phase: 8, sort: 2)
    addFrage("Hast Du gefeiert?",                       phase: 8, sort: 3)
    addFrage("Was ist der nächste Zyklus?",             phase: 8, sort: 4)
    addFrage("Was bedeutet dieses Vorhaben für mich?",  phase: 8, sort: 5, istAbschlussfrage: true)

    // Phase 9 – Abgebrochen
    addFrage("Was hat zum Abbruch geführt?",            phase: 9, sort: 1)
    addFrage("Was hast Du dabei gelernt?",              phase: 9, sort: 2)
    addFrage("Was machst Du stattdessen?",              phase: 9, sort: 3)
    addFrage("Was nehme ich mit?",                      phase: 9, sort: 4, istAbschlussfrage: true)
}




