//
//  AufgabeListeView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.06.2024.
//

import SwiftUI
import SwiftData


struct OldAufgabenListeView_DEPRECATED: View {
    var Vorhaben: VorhabenModel
    
    
    var body: some View {
        ScrollView{
            ForEach (Vorhaben.viewAktuellErledigteAufgaben) { aufgabe in
                AufgabeChatView (aufgabe: aufgabe)
            }
        }
       .navigationTitle("\(Vorhaben.bezeichnung) Phase: \(Vorhaben.viewPhase)")
       .navigationBarTitleDisplayMode(.inline)
        
        
        if Vorhaben.viewAktuelleAufgabenErledigt {
            Button("Nächste Phase") {
                if Vorhaben.phase < 8 {  Vorhaben.phase += 1
                } else {
                    Vorhaben.phase = 0
                }
            }
            .navigationTitle("\(Vorhaben.bezeichnung): \(Vorhaben.viewPhase)")
            
        } else {
            AufgabeNaechsteAufgabe(aufgabe: Vorhaben.viewAktuellNächsteAufgabe)
        }
        
    }
}

#Preview {
    let container = VorhabenModel.preview
    let Vorhabens = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { Vorhaben in
            Vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    return OldAufgabenListeView_DEPRECATED(Vorhaben: Vorhabens[0])
}

