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

        let predicate = #Predicate<VorhabenModel> { vorhaben in
            vorhaben.bezeichnung.contains(searchText)
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
            Group {
                if Vorhabens.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("Keine Vorhaben vorhanden")
                                .font(.title2)
                                .fontWeight(.medium)
                            
                            Text("Fügen Sie Ihr erstes Vorhaben mit dem + hinzu")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(Vorhabens){ vorhaben in
                            NavigationLink {
                                VorhabenEditor(vorhaben: vorhaben)
                                // refresh.toggle()
                            } label: {
                                VorhabenView(vorhaben: vorhaben)
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
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Vorhaben")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                Button("", systemImage: "arrow.clockwise") {
                    refresh.toggle()
                }
                Button("", systemImage: "plus") {
                    newVorhaben = VorhabenModel()
                    modelContext.insert(newVorhaben)
                    addStandardAufgaben(vorhaben: newVorhaben)
                    isNewVorhaben = true
                    refresh.toggle()
                }
               
            }
            .onChange(of: searchText) {
                //  refresh.toggle()
            }
            .id(refresh)
        }
        .alert("Vorhaben löschen", isPresented: $showDeleteAlert) {
            Button("Löschen", role: .destructive) {
                deleteItems(vorhaben: VorhabenToDelete!)
                showDeleteAlert = false
            }
            Button("Abbrechen", role: .cancel) {
                showDeleteAlert = false
            }
        } message: {
            Text("Soll das Vorhaben wirklich gelöscht werden")
        }
        .sheet(isPresented: $isNewVorhaben){
            VorhabenEditor(vorhaben: newVorhaben, isNew: true)
        }
        .onAppear(){
            refresh.toggle()
        }
    }
    
    func deleteItems(vorhaben: VorhabenModel) {
        modelContext.delete(vorhaben)
    }
    
}


#Preview ("Container"){
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: VorhabenModel.self, configurations: config)

        return VorhabenListeView()
            .modelContainer(container)
    } catch {
        return Text("Preview nicht verfügbar: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}

#Preview ("Preview 2"){
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: VorhabenModel.self, configurations: config)

        let example = VorhabenModel.preview2
        container.mainContext.insert(example)

        return VorhabenListeView()
            .modelContainer(container)
    } catch {
        return Text("Preview nicht verfügbar: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}

