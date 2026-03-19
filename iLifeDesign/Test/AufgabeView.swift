//
//  AufgabeView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 04.08.2024.
//

import SwiftUI
import SwiftData

struct AufgabeView: View {
    @Bindable var aufgabe: AufgabeModel
    @State private var editAufgabe: Bool = false
   
    var body: some View {
       
        VStack(alignment: .leading){
            HStack (alignment: .top){
                Image(systemName: "\(aufgabe.sort).circle")
                            .font(.title2)
                Spacer()
                TextField("Aufgabe", text: $aufgabe.aufgabe, axis: .vertical)
                        .lineLimit(10)
                       
                }
            HStack{
                TextField("Antwort", text: $aufgabe.antwort, axis: .vertical)
                    .lineLimit(10)
                Button("", systemImage: aufgabe.viewErledigt) { 
                    aufgabe.erledigt.toggle() }
                
            }
                         
        }
        
    }
}



#Preview {
    let container = ExperimentModel.preview
    let experiments = try! container.mainContext.fetch(
        FetchDescriptor<ExperimentModel>(predicate: #Predicate { experiment in
            experiment.bezeichnung == "iLifeDesign"
        }))
    
    return AufgabeView(aufgabe: experiments[0].aufgaben![0])
}

