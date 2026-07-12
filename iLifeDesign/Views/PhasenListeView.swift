//
//  PhasenListeView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//  Updated by Sandra Sulzberger on 12.07.2026.
//

import SwiftUI
import SwiftData

// MARK: - Haupt-View

struct PhasenListeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: \PhaseModel.sort) private var phasen: [PhaseModel]

    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    @State private var bearbeitetePhase: PhaseModel?
    @State private var zeigeLeerePhase = true

    /// Phasen filtern: leere Phasen ausblenden wenn zeigeLeerePhase == false
    private var sichtbarePhasen: [PhaseModel] {
        guard !zeigeLeerePhase else { return phasen }
        return phasen.filter { phase in
            let sort = phase.sort
            let predicate = #Predicate<VorhabenModel> { v in v.phase == sort }
            let fetch = FetchDescriptor(predicate: predicate)
            let anzahl = (try? modelContext.fetchCount(fetch)) ?? 0
            return anzahl > 0
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if phasen.isEmpty {
                    ContentUnavailableView(
                        "Keine Phasen",
                        systemImage: "infinity",
                        description: Text("Die Phasen werden beim Start automatisch angelegt.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sichtbarePhasen) { phase in
                                PhasenGruppeView(phase: phase) {
                                    bearbeitetePhase = phase
                                } onNeuesVorhaben: {
                                    let vorhaben = VorhabenModel(phase: phase.sort)
                                    modelContext.insert(vorhaben)
                                    addStandardAufgaben(vorhaben: vorhaben)
                                    newVorhaben = vorhaben
                                    isNewVorhaben = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Phasen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Auge: leere Phasen ein-/ausblenden
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation { zeigeLeerePhase.toggle() }
                    } label: {
                        Image(systemName: zeigeLeerePhase ? "eye.fill" : "eye.slash")
                            .foregroundStyle(zeigeLeerePhase ? .primary : .secondary)
                    }
                    .help(zeigeLeerePhase ? "Leere Phasen ausblenden" : "Leere Phasen einblenden")
                }
                // Plus: neues Vorhaben
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let vorhaben = VorhabenModel()
                        modelContext.insert(vorhaben)
                        addStandardAufgaben(vorhaben: vorhaben)
                        newVorhaben = vorhaben
                        isNewVorhaben = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isNewVorhaben) {
            VorhabenEditor(vorhaben: newVorhaben, isNew: true)
                .interactiveDismissDisabled()
        }
        .sheet(item: $bearbeitetePhase) { phase in
            PhaseEditor(phase: phase)
        }
        .onAppear {
            setupStandardPhasen(context: modelContext)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { setupStandardPhasen(context: modelContext) }
        }
    }
}

// MARK: - Phasen-Gruppen-Karte

struct PhasenGruppeView: View {
    @Environment(\.modelContext) private var modelContext

    let phase: PhaseModel
    var onBearbeiten: () -> Void
    var onNeuesVorhaben: () -> Void

    @State private var istAusgeklappt = true

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
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    istAusgeklappt.toggle()
                }
            } label: {
                HStack(spacing: 12) {

                    // Icon
                    ZStack {
                        Circle()
                            .fill(phase.viewFarbe.opacity(0.18))
                            .frame(width: 30, height: 30)
                        Image(systemName: phase.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(phase.viewFarbe)
                    }

                    // Texte
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(phase.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(phase.viewFarbe)
                            Text("(\(vorhabens.count))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !phase.info.isEmpty {
                            Text(phase.info)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Aktionen
                    HStack(spacing: 8) {
                        // Bearbeiten
                        Button {
                            onBearbeiten()
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.title3)
                                .foregroundStyle(phase.viewFarbe.opacity(0.7))
                        }
                        .buttonStyle(.plain)

                        // Neues Vorhaben
                        Button {
                            onNeuesVorhaben()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(phase.viewFarbe)
                        }
                        .buttonStyle(.plain)

                        // Aufklapp-Pfeil
                        Image(systemName: "chevron.down")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(istAusgeklappt ? 0 : -90))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            // MARK: Vorhaben-Liste
            if istAusgeklappt {
                Divider()
                    .padding(.horizontal, 14)

                if vorhabens.isEmpty {
                    HStack {
                        Image(systemName: "tray")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Noch keine Vorhaben")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                } else {
                    VStack(spacing: 6) {
                        ForEach(vorhabens) { vorhaben in
                            VorhabenZeile(vorhaben: vorhaben, showPhase: false, phaseColor: phase.viewFarbe)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(
                            phase.viewFarbe.opacity(vorhabens.isEmpty ? 0.15 : 0.3),
                            lineWidth: 1
                        )
                }
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
