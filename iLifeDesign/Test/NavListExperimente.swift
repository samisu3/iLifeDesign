//
//  NavListExperimente.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 01.09.2024.
//

import SwiftUI
import SwiftData

struct NavListExperimente: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedExperiment: ExperimentModel?
    
    @State private var sortOrder = SortOrder.forward
    
    @State private var refresh = false
    @State private var searchText = ""
    @State private var sortBy = [
        SortDescriptor(\ExperimentModel.phase),
        SortDescriptor(\ExperimentModel.priority),
    ]
 
    private var experiments: [ExperimentModel] {
        let predicate = #Predicate<ExperimentModel> { experiment in
            experiment.bezeichnung.contains(searchText) }
        let fetch = FetchDescriptor(predicate: searchText.count == 0 ? nil : predicate, sortBy: sortBy)
        return try! modelContext.fetch(fetch)
    }

    
    var body: some View {

        NavigationSplitView {
            List {
                ForEach(experiments){ experiment in
                    ExperimentView(experiment: experiment)
                    
                }
            }
            .navigationTitle("Ziele")
        } content: {
            if selectedExperiment == nil {
                Text("Bitte Ziel auswählen")
            } else {
                Text("Some Experiment Found")
                // ExperimentHeaderView(experiment: experiment!)
            }
        }
    detail: {
        if selectedExperiment == nil {
            Text("Bitte Ziel auswählen")
        } else {
            Text("Some Experiment Found")
            // ExperimentHeaderView(experiment: experiment!)
        }
        
    }
  
    }
}

#Preview {
    NavListExperimente()
        .modelContainer(ExperimentModel.preview)
}
