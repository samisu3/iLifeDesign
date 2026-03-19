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
    var erledigt: Bool = false 
    var vorhaben: VorhabenModel?
    
    init(aufgabe: String = "", phase: Int = 0, sort: Int = 1, antwort: String = "", erledigt: Bool = false, vorhaben: VorhabenModel? = nil) {
        self.aufgabe = aufgabe
        self.phase = phase
        self.sort = sort
        self.antwort = antwort
        self.erledigt = erledigt
        self.vorhaben = vorhaben
    }
}

extension AufgabeModel {
    
    var viewErledigt: String {
        if erledigt { return "checkmark.square" }
        else { return "square" }
    }
}


func addStandardAufgaben(vorhaben: VorhabenModel) {
    // Zuerst mal die Aufgaben leeren
    vorhaben.aufgaben = []
    
    // Sichere Funktion zum Hinzufügen von Aufgaben
    func addAufgabe(_ text: String, phase: Int, sort: Int) {
        if vorhaben.aufgaben == nil {
            vorhaben.aufgaben = []
        }
        vorhaben.aufgaben?.append(AufgabeModel(aufgabe: text, phase: phase, sort: sort, vorhaben: vorhaben))
    }
    
    // Phase Idee = 0
    addAufgabe("Um was geht es?", phase: 0, sort: 1)
    addAufgabe("Erste Ideen zum Vorhaben?", phase: 0, sort: 2)
    
    
    // Phase Empathie = 1
    addAufgabe("Was ist Dir wichtig?", phase: 1, sort: 1)
    addAufgabe("Wie ist es heute?", phase: 1, sort: 2)
    addAufgabe("Hast Du so etwas schon mal erlebt?", phase: 1, sort: 3)
    addAufgabe("Wie hast Du es damals gelöst?", phase: 1, sort: 4)
    addAufgabe("Welche Stärken hast Du, um damit umzugehen?", phase: 1, sort: 5)
    addAufgabe("Was würde Dein*e Superheld*in tun?", phase: 1, sort: 6)
    addAufgabe("Wichtigste Erkentnisse aus dieser Phase?", phase: 1, sort: 7)

    
    // Phase Fokus = 2
    addAufgabe("Formuliere das Problem mit 'Wie könnte ich?'", phase: 2, sort: 1)
    addAufgabe("Was ist der Kern des Problems?", phase: 2, sort: 2)
    addAufgabe("Welchen Teil davon kannst Du selbst ändern?", phase: 2, sort: 3)
    addAufgabe("Was ist interessant und attraktiv daran?", phase: 2, sort: 4)
    addAufgabe("Wie lautet die finale, attraktive und lösbare Problemformulierung?", phase: 2, sort: 5)
    
    // Phase Inspiration = 3
    addAufgabe("Was sind Deine ersten Lösungsideen?", phase: 3, sort: 1)
    addAufgabe("Was würdest Du tun, wenn Geld und Zeit keine Rolle spielen?", phase: 3, sort: 2)
    addAufgabe("Wie wäre es, wenn das Problem schon gelöst wäre?", phase: 3, sort: 3)
    addAufgabe("Was kannst Du ohne grosses Risiko umsetzen?", phase: 3, sort: 4)
    addAufgabe("Wähle eine verrückte Lösung", phase: 3, sort: 5)
    addAufgabe("Wähle eine einfach umsetzbare Lösung", phase: 3, sort: 6)
    addAufgabe("Für welche Lösung möchtest Du ein erstes Vorhaben machen?", phase: 3, sort: 7)
    
    // Phase Überwindung = 4
    addAufgabe("Hast Du Dir Zeit reserviert für das Vorhaben?", phase: 4, sort: 1)
    addAufgabe("Hast Du das Umfeld so gestaltet, dass du einfach loslegen kannst?", phase: 4, sort: 2)
    addAufgabe("Hast Du Dir Verbündete gesucht? Wen?", phase: 4, sort: 3)
    addAufgabe("Welche Belohnung bekommst Du, wenn Du das durchziehst?", phase: 4, sort: 4)
    addAufgabe("Hast Du alles Material, das Du brauchst?", phase: 4, sort: 5)
    addAufgabe("Hast Du eine Notfall-Planung, wenn Du mal blockiert bist?", phase: 4, sort: 6)
    addAufgabe("Hast Du Erinnerungen daran (mit Bild) aufgehängt?", phase: 4, sort: 7)
    
    // Phase Prototyping = 5
    addAufgabe("Was ist der erste kleine Schritt?", phase: 5, sort: 1)
    addAufgabe("Hast Du Deine Verbündeten mit einbezogen?", phase: 5, sort: 2)
    addAufgabe("Machst Du auch mal Pause?", phase: 5, sort: 3)
    addAufgabe("Probierst Du etwas anderes, wenn Du blockiert bist?", phase: 5, sort: 4)
    addAufgabe("Gibt es jemanden, der Dir hilft dabei?", phase: 5, sort: 5)
    addAufgabe("Stellst Du Dir vor, wie stolz Du bist, wenn Du es durchgezogen hast?", phase: 5, sort: 6)
    
    // Phase Feedback = 6
    addAufgabe("Wie hast Du Dich gefühlt?", phase: 6, sort: 1)
    addAufgabe("Was hat gut geklappt?", phase: 6, sort: 2)
    addAufgabe("Was war nicht wie erwünscht?", phase: 6, sort: 3)
    addAufgabe("Was haben andere dazu gesagt?", phase: 6, sort: 4)
    addAufgabe("Welche Ergebnisse hast Du erziehlt?", phase: 6, sort: 5)
    
    // Phase Lernen = 7
    addAufgabe("Was würdest Du wieder genau gleich machen?", phase: 7, sort: 1)
    addAufgabe("Was würdest Du anders machen?", phase: 7, sort: 2)
    addAufgabe("Was hast Du dabei gelernt?", phase: 7, sort: 3)
    addAufgabe("Was würdest Du in einer neuen Runde verbessern?", phase: 7, sort: 4)
    
    // Phase Kontinuität = 8
    addAufgabe("Bedanken bei allen, die Dich unterstützt haben", phase: 8, sort: 1)
    addAufgabe("Belohnung einkassieren (siehe Phase 4, Überwindung)", phase: 8, sort: 2)
    addAufgabe("Feiern", phase: 8, sort: 3)
    addAufgabe("Abschliessen und aufräumen", phase: 8, sort: 4)
    addAufgabe("Vorhaben Version 2 neu aufnehmen", phase: 8, sort: 5)
 
    // Phase Abgebrochen = 9
    addAufgabe("Aufräumen und abschliessen", phase: 9, sort: 1)
    addAufgabe("Neue Vorhabene stattdessen planen", phase: 9, sort: 2)
    addAufgabe("Vergeben und vergessen", phase: 9, sort: 3)
    
    
}




