//
//  VorhabenListeView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.06.2024.
// Inspred by Xopyright © 2023 Big Mountain Studio.
// All rights reserved. Twitter: @BigMtnStudio
//

import SwiftUI
import SwiftData


struct VorhabenListeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var refresh = true
    @State private var sortOrder = SortOrder.forward
    @State private var searchText = ""
    @State private var sortBy = [
        SortDescriptor(\VorhabenModel.priority, order: .reverse),
        SortDescriptor(\VorhabenModel.phase)
    ]
    
    // Neue Preiew Variable, die nil sein kann
    var previewVorhabens: [VorhabenModel]? = nil
    
    private var Vorhabens: [VorhabenModel] {
        if let previewVorhabens = previewVorhabens {
            return previewVorhabens
        }

        let predicate = #Predicate<VorhabenModel> { Vorhaben in
            Vorhaben.bezeichnung.contains(searchText)
        }
        let fetch = FetchDescriptor(
            predicate: searchText.isEmpty ? nil : predicate,
            sortBy: sortBy
        )
        return (try? modelContext.fetch(fetch)) ?? []
    }
    
    
    @State private var VorhabenToDelete: VorhabenModel?
    @State private var newVorhaben = VorhabenModel()
    @State private var showDeleteAlert = false
    @State private var isNewVorhaben = false
    
    var body: some View {
        NavigationStack {
            
            List {
                ForEach(Vorhabens){ Vorhaben in
                    NavigationLink {
                        ModernVorhabenEditor(Vorhaben: Vorhaben)
                        // refresh.toggle()
                    } label: {
                        VorhabenView(Vorhaben: Vorhaben)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 2)
                }
                .onDelete{ indexSet in
                    let theIndex = indexSet.first
                    VorhabenToDelete = Vorhabens[theIndex!]
                    showDeleteAlert.toggle()
                }
            }
            .listStyle(.plain)
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .searchable(text: $searchText)
            .alert(isPresented: $showDeleteAlert){
                Alert(
                    title: Text("Vorhaben löschen"),
                    message: Text("Soll das Vorhaben wirklich gelöscht werden"),
                    primaryButton: .destructive(Text("Löschen")) {
                        deleteItems(Vorhaben: VorhabenToDelete!)
                        showDeleteAlert.toggle()
                    },
                    secondaryButton: .cancel(Text("Abbrechen")) {
                        showDeleteAlert.toggle()
                    }
                    
                )
            }
            
            .navigationTitle("Ziele")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("", systemImage: "arrow.clockwise") {
                    refresh.toggle()
                }
                Button("", systemImage: "plus") {
                    newVorhaben = VorhabenModel()
                    modelContext.insert(newVorhaben)
                    addStandardAufgaben(Vorhaben: newVorhaben)
                    isNewVorhaben = true
                    refresh.toggle()
                }
               
            }
            .onChange(of: searchText) {
                //  refresh.toggle()
            }
            .id(refresh)
            
        }
        .sheet(isPresented: $isNewVorhaben){
            ModernVorhabenEditor(Vorhaben: newVorhaben, isNew: true)
        }
        .onAppear(){
            refresh.toggle()
        }
    }
    
    func deleteItems(Vorhaben: VorhabenModel) {
        modelContext.delete(Vorhaben)
    }
    
}


#Preview ("Container"){
    /* VorhabenListeView()
        .modelContainer(VorhabenModel.preview) */
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)

        return VorhabenListeView()
            .modelContainer(container)
    
}





#Preview ("Preview 2"){
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)

        let example = VorhabenModel.preview2
        container.mainContext.insert(example)

        return VorhabenListeView()
            .modelContainer(container)
    }

