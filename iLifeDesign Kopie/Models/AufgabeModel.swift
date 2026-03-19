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
    var Vorhaben: VorhabenModel?
    
    init(aufgabe: String = "", phase: Int = 0, sort: Int = 1, antwort: String = "", erledigt: Bool = false, Vorhaben: VorhabenModel? = nil) {
        self.aufgabe = aufgabe
        self.phase = phase
        self.sort = sort
        self.antwort = antwort
        self.erledigt = erledigt
        self.Vorhaben = Vorhaben
    }
}

extension AufgabeModel {
    
    var viewErledigt: String {
        if erledigt { return "checkmark.square" }
        else { return "square" }
    }
}


func addStandardAufgaben(Vorhaben: VorhabenModel) {
    // Zuerst mal die Aufgaben leeren
    Vorhaben.aufgaben = []
    
    // Phase Idee = 0
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Um was geht es?", phase: 0, sort: 1, Vorhaben: Vorhaben ))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Erste Ideen zum Vorhaben?", phase: 0, sort: 2, Vorhaben: Vorhaben ))
    
    
    // Phase Empathie = 1
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Was ist Dir wichtig?", phase: 1, sort: 1, Vorhaben: Vorhaben ))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Wie ist es heute?", phase: 1, sort: 2, Vorhaben: Vorhaben ))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Hast Du so etwas schon mal erlebt?", phase: 1, sort: 3, Vorhaben: Vorhaben ))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Wie hast Du es damals gelöst?", phase: 1, sort: 4, Vorhaben: Vorhaben ))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Welche Stärken hast Du, um damit umzugehen?", phase: 1, sort: 5, Vorhaben: Vorhaben ))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Was würde Dein*e Superheld*in tun?", phase: 1, sort: 6, Vorhaben: Vorhaben ))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe:"Wichtigste Erkentnisse aus dieser Phase?", phase: 1, sort: 7, Vorhaben: Vorhaben ))

    
    // Phase Fokus = 2
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Formuliere das Problem mit 'Wie könnte ich?'", phase: 2, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was ist der Kern des Problems?", phase: 2, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Welchen Teil davon kannst Du selbst ändern?", phase: 2, sort: 3, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was ist interessant und attraktiv daran?", phase: 2, sort: 4, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Wie lautet die finale, attraktive und lösbare Problemformulierung?", phase: 2, sort: 5, Vorhaben: Vorhaben))
    
    // Phase Inspiration = 3
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was sind Deine ersten Lösungsideen?", phase: 3, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was würdest Du tun, wenn Geld und Zeit keine Rolle spielen?", phase: 3, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Wie wäre es, wenn das Problem schon gelöst wäre?", phase: 3, sort: 3, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was kannst Du ohne grosses Risiko umsetzen?", phase: 3, sort: 4, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Wähle eine verrückte Lösung", phase: 3, sort: 5, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Wähle eine einfach umsetzbare Lösung", phase: 3, sort: 6, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Für welche Lösung möchtest Du ein erstes Vorhaben machen?", phase: 3, sort: 7, Vorhaben: Vorhaben))
    
    
    // Phase Überwindung = 4
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Hast Du Dir Zeit reserviert für das Vorhaben?", phase: 4, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Hast Du das Umfeld so gestaltet, dass du einfach loslegen kannst?", phase: 4, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Hast Du Dir Verbündete gesucht? Wen?", phase: 4, sort: 3, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Welche Belohnung bekommst Du, wenn Du das durchziehst?", phase: 4, sort: 4, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Hast Du alles Material, das Du brauchst?", phase: 4, sort: 5, Vorhaben: Vorhaben))
    
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Hast Du eine Notfall-Planung, wenn Du mal blockiert bist?", phase: 4, sort: 6, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Hast Du Erinnerungen daran (mit Bild) aufgehängt?", phase: 4, sort: 7, Vorhaben: Vorhaben))
    
    
    // Phase Prototyping = 5
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was ist der erste kleine Schritt?", phase: 5, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Hast Du Deine Verbündeten mit einbezogen?", phase: 5, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Machst Du auch mal Pause?", phase: 5, sort: 3, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Probierst Du etwas anderes, wenn Du blockiert bist?", phase: 5, sort: 4, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Gibt es jemanden, der Dir hilft dabei?", phase: 5, sort: 5, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Stellst Du Dir vor, wie stolz Du bist, wenn Du es durchgezogen hast?", phase: 5, sort: 6, Vorhaben: Vorhaben))
    
    // Phase Feedback = 6
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Wie hast Du Dich gefühlt?", phase: 6, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was hat gut geklappt?", phase: 6, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was war nicht wie erwünscht?", phase: 6, sort: 3, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was haben andere dazu gesagt?", phase: 6, sort: 4, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Welche Ergebnisse hast Du erziehlt?", phase: 6, sort: 5, Vorhaben: Vorhaben))
    
    // Phase Lernen = 7
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was würdest Du wieder genau gleich machen?", phase: 7, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was würdest Du anders machen?", phase: 7, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was hast Du dabei gelernt?", phase: 7, sort: 3, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Was würdest Du in einer neuen Runde verbessern?", phase: 7, sort: 4, Vorhaben: Vorhaben))
    
    // Phase Kontinuität = 8
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Bedanken bei allen, die Dich unterstützt haben", phase: 8, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Belohnung einkassieren (siehe Phase 4, Überwindung)", phase: 8, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Feiern", phase: 8, sort: 3, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Abschliessen und aufräumen", phase: 8, sort: 4, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Vorhaben Version 2 neu aufnehmen", phase: 8, sort: 5, Vorhaben: Vorhaben))
 
    // Phase Abgebrochen = 9
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Aufräumen und abschliessen", phase: 9, sort: 1, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Neue Vorhabene stattdessen planen", phase: 9, sort: 2, Vorhaben: Vorhaben))
    Vorhaben.aufgaben!.append(AufgabeModel(aufgabe: "Vergeben und vergessen", phase: 9, sort: 3, Vorhaben: Vorhaben))
    
    
}




