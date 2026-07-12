//
//  PhasenListeView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//  Updated by Sandra Sulzberger on 12.07.2026.
//

import SwiftUI
import SwiftData

struct PhasenListeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: \PhaseModel.sort) private var phasen: [PhaseModel]

    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    @State private var refresh = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(phasen) { phase in
                        PhasenGruppeView(phase: phase, refresh: refresh)
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
            // Sicherstellen, dass alle 10 Phasen vorhanden sind
            setupStandardPhasen(context: modelContext)
            refresh.toggle()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { refresh.toggle() }
        }
    }
}

// MARK: - Phasen-Gruppe

struct PhasenGruppeView: View {
    @Environment(\.modelContext) private var modelContext

    let phase: PhaseModel
    let refresh: Bool

    @State private var zeigeEditor = false

    private var vorhabens: [VorhabenModel] {
        let sort = phase.sort
        let predicate = #Predicate<VorhabenModel> { v in v.phase == sort }
        let fetch = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\VorhabenModel.priority, order: .reverse)]
        )
        return (try? modelContext.fetch(fetch)) ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: Phase Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(phase.viewFarbe.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: phase.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(phase.viewFarbe)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(phase.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(phase.viewFarbe)
                        Text("(\(vorhabens.count))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("Phase \(phase.sort + 1) von 10")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Edit-Button
                Button {
                    zeigeEditor = true
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.title3)
                        .foregroundStyle(phase.viewFarbe.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            // MARK: Vorhaben Liste
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
                        .stroke(
                            phase.viewFarbe.opacity(vorhabens.isEmpty ? 0.1 : 0.2),
                            lineWidth: 1
                        )
                }
        }
        .sheet(isPresented: $zeigeEditor) {
            PhaseEditor(phase: phase)
        }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: VorhabenModel.self, PhaseModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    setupStandardPhasen(context: container.mainContext)

    let vorhaben1 = VorhabenModel(bezeichnung: "iLifeDesign", icon: 23, phase: 2, priority: 4, beschreibung: "Tool entwickeln", lebensbereich: 7)
    let vorhaben2 = VorhabenModel(bezeichnung: "Balkon einrichten", icon: 2, phase: 2, priority: 2, beschreibung: "Schöner Balkon", lebensbereich: 5)
    container.mainContext.insert(vorhaben1)
    container.mainContext.insert(vorhaben2)
    addStandardAufgaben(vorhaben: vorhaben1)
    addStandardAufgaben(vorhaben: vorhaben2)

    return PhasenListeView()
        .modelContainer(container)
}
