//
//  PhasenListeView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//

import SwiftUI
import SwiftData

struct PhasenListeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var refresh = false
    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(0...9, id: \.self) { phase in
                        PhasenGruppeView(phase: phase)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .navigationTitle("Phasen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("", systemImage: "arrow.clockwise") {
                        refresh.toggle()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("", systemImage: "plus") {
                        newVorhaben = VorhabenModel()
                        modelContext.insert(newVorhaben)
                        addStandardAufgaben(vorhaben: newVorhaben)
                        isNewVorhaben = true
                        refresh.toggle()
                    }
                }
            }
            .id(refresh)
        }
        .sheet(isPresented: $isNewVorhaben) {
            VorhabenEditor(vorhaben: newVorhaben, isNew: true)
        }
        .onAppear {
            refresh.toggle()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refresh.toggle()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refresh.toggle()
            }
        }
    }
    }


struct PhasenGruppeView: View {
    @Environment(\.modelContext) private var modelContext
    let phase: Int
    
    private var sortDescriptors: [SortDescriptor<VorhabenModel>] {
        [SortDescriptor(\VorhabenModel.priority, order: .reverse)]
    }
    
    private var vorhabens: [VorhabenModel] {
        let predicate = #Predicate<VorhabenModel> { vorhaben in
            vorhaben.phase == phase
        }
        let fetch = FetchDescriptor(predicate: predicate, sortBy: sortDescriptors)
        return (try? modelContext.fetch(fetch)) ?? []
    }
    
    private var phaseColor: Color {
        PhaseColor[phase] ?? .gray
    }
    
    private var phaseIcon: String {
        VorhabenPhaseIcon[phase] ?? "circle"
    }
    
    private var phaseName: String {
        VorhabenPhase[phase] ?? "Phase \(phase + 1)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Phase Header (immer anzeigen)
            HStack(spacing: 12) {
                // Phase Icon
                ZStack {
                    Circle()
                        .fill(phaseColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: phaseIcon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(phaseColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(phaseName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(phaseColor)
                        
                        Text("(\(vorhabens.count))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Phase \(phase + 1) von 10")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Vorhaben Liste (nur wenn vorhanden)
            if !vorhabens.isEmpty {
                VStack(spacing: 6) {
                    ForEach(vorhabens) { vorhaben in
                        NavigationLink {
                            VorhabenEditor(vorhaben: vorhaben)
                        } label: {
                            CompactVorhabenCard(vorhaben: vorhaben, showPhase: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("Keine Vorhaben")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.leading, 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(phaseColor.opacity(vorhabens.isEmpty ? 0.1 : 0.2), lineWidth: 1)
                }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)
    
    // Beispieldaten hinzufügen
    let vorhaben1 = VorhabenModel(bezeichnung: "iLifeDesign", icon: 23, phase: 2, priority: 4, beschreibung: "Tool entwickeln", lebensbereich: 7)
    let vorhaben2 = VorhabenModel(bezeichnung: "Balkon einrichten", icon: 2, phase: 2, priority: 2, beschreibung: "Schöner Balkon", lebensbereich: 5)
    
    container.mainContext.insert(vorhaben1)
    container.mainContext.insert(vorhaben2)
    addStandardAufgaben(vorhaben: vorhaben1)
    addStandardAufgaben(vorhaben: vorhaben2)
    
    return PhasenListeView()
        .modelContainer(container)
}