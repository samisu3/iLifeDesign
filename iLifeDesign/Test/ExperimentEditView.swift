//
//  ExperimentEditView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 23.06.2024
//  Based on Code by  © 2024 Big Mountain Studio. All rights reserved. Twitter: @BigMtnStudio
//

import SwiftData
import SwiftUI

struct ExperimentEditView: View {
    @Bindable var experiment: ExperimentModel
    @State private var editExperiment: Bool = false
    
    var body: some View {
        ExperimentHeaderView(experiment: experiment)
        List{
            ForEach (experiment.viewAktuellErledigteAufgaben) { aufgabe in
                AufgabeChatView (aufgabe: aufgabe)
            }
        }
        
        
        if experiment.viewAktuelleAufgabenErledigt {
            Button("Nächste Phase") {
                if experiment.phase < 8 {  experiment.phase += 1
                } else {
                    experiment.phase = 0
                }
            }
            .navigationTitle("\(experiment.bezeichnung): \(experiment.viewPhase)")
            
        } else {
            AufgabeNaechsteAufgabe(aufgabe: experiment.viewAktuellNächsteAufgabe)
        }
    }
}

#Preview {
    let container = ExperimentModel.preview
    let experiments = try! container.mainContext.fetch(FetchDescriptor<ExperimentModel>())
    
    return NavigationStack {
        ExperimentEditView(experiment: experiments[0])
    }
}

