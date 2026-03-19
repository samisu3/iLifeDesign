//
//  AufgabenListeView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.06.2024.
//

import SwiftUI
import SwiftData


struct OldAufgabenListeView_VORHABEN_DEPRECATED: View {
    var vorhaben: VorhabenModel
    
    
    var body: some View {
        ScrollView{
            ForEach (vorhaben.viewAktuellErledigteAufgaben) { aufgabe in
                AufgabeChatView (aufgabe: aufgabe)
            }
        }
       .navigationTitle("\(vorhaben.bezeichnung) Phase: \(vorhaben.viewPhase)")
       .navigationBarTitleDisplayMode(.inline)
        
        
        if vorhaben.viewAktuelleAufgabenErledigt {
            Button("Nächste Phase") {
                if vorhaben.phase < 8 {  vorhaben.phase += 1
                } else {
                    vorhaben.phase = 0
                }
            }
            .navigationTitle("\(vorhaben.bezeichnung): \(vorhaben.viewPhase)")
            
        } else {
            AufgabeNaechsteAufgabe(aufgabe: vorhaben.viewAktuellNächsteAufgabe)
        }
        
    }
}

#Preview {
    let container = VorhabenModel.preview
    let vorhaben = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { vorhaben in
            vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    OldAufgabenListeView_VORHABEN_DEPRECATED(vorhaben: vorhaben[0])
}