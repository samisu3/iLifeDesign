//
//  VorhabenEditor.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.08.2024.
//

import SwiftUI
import SwiftData

struct OldVorhabenEditor_DEPRECATED: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var vorhaben: VorhabenModel
    var isNew = false 
   
    @Environment(\.dismiss) private var dismiss
    @State private var isDeleted = false
    @State private var editVorhaben = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 0) {
                    VorhabenDetailView(vorhaben: vorhaben, editVorhaben: editVorhaben || isNew)
                    
                    // Aufgaben Section
                    if !isNew || !editVorhaben {
                        VStack(spacing: 16) {
                            Divider()
                                .padding(.horizontal, 20)
                            
                            NavigationLink {
                                AufgabenListeView(vorhaben: vorhaben)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Aufgaben für \(vorhaben.viewPhase)")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.primary)
                                        
                                        Text(vorhaben.viewPhaseInfo)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                        
                                        HStack {
                                            Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt) von \(vorhaben.viewAktuelleAufgabenAnzahl) erledigt")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            
                                            Spacer()
                                            
                                            if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                                                ProgressView(value: Double(vorhaben.viewAktuelleAufgabenAnzahlErledigt), total: Double(vorhaben.viewAktuelleAufgabenAnzahl))
                                                    .frame(width: 60)
                                                    .tint(vorhaben.viewColor)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                .stroke(vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                                        }
                                }
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, 20)
                            
                            // Delete Button (nur wenn nicht neu)
                            if !isNew {
                                Button {
                                    showDeleteAlert = true
                                } label: {
                                    HStack {
                                        Image(systemName: "trash")
                                        Text("Vorhaben löschen")
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(.red.opacity(0.1))
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle(isNew ? "Neues Vorhaben" : vorhaben.bezeichnung)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem (placement: .cancellationAction) {
                    if isNew {
                        Button("Abbrechen") {
                            modelContext.delete(vorhaben)
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        editVorhaben.toggle()
                        if isNew { dismiss() }
                    } label: {
                        Text(editVorhaben || isNew ? "Speichern" : "Bearbeiten")
                            .fontWeight(.semibold)
                    }
                    .disabled(isNew && vorhaben.bezeichnung.isEmpty)
                }
            }
            .alert("Vorhaben löschen", isPresented: $showDeleteAlert) {
                Button("Löschen", role: .destructive) {
                    modelContext.delete(vorhaben)
                    dismiss()
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text("Dieses Vorhaben wird unwiderruflich gelöscht.")
            }
        }
    }
}


#Preview ("old"){
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)
    
    let vorhaben = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { vorhaben in
            vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    NavigationStack {
        OldVorhabenEditor_DEPRECATED(vorhaben: vorhaben[0])
    }
}


#Preview ("Preview 2"){
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)
    
    NavigationStack {
        OldVorhabenEditor_DEPRECATED(vorhaben: VorhabenModel.preview2)
            .modelContainer(container)
    }
}