//
//  ExpeditionView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//  Updated by Sandra Sulzberger on 12.07.2026.
//
//  Alle Ideen auf ihrer Expedition durch den 5-Phasen-Loop —
//  wahlweise als Liste (untereinander) oder als Kanban-Board (Spalten).
//

import SwiftUI
import SwiftData

// MARK: - Haupt-View

struct ExpeditionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @Query(sort: \PhaseModel.sort) private var phasen: [PhaseModel]

    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    @State private var bearbeitetePhase: PhaseModel?
    @State private var zeigeLeerePhase = true
    @State private var zeigeQuickIdea = false
    @State private var zeigeEinstellungen = false
    /// Ansicht wählbar: Liste (untereinander) oder Kanban (Spalten) — wird gemerkt
    @AppStorage("expeditionKanban") private var kanbanAnsicht = false
    @State private var refreshID = 0

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
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                Group {
                    if phasen.isEmpty {
                        ContentUnavailableView(
                            "Keine Phasen",
                            systemImage: "infinity",
                            description: Text("Die Phasen werden beim Start automatisch angelegt.")
                        )
                    } else if kanbanAnsicht {
                        kanbanAnsichtView
                    } else {
                        listenAnsichtView
                    }
                }
            }
            .navigationTitle("Expedition")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Auge: leere Phasen ein-/ausblenden
                    Button {
                        withAnimation { zeigeLeerePhase.toggle() }
                    } label: {
                        Image(systemName: zeigeLeerePhase ? "eye.fill" : "eye.slash")
                            .foregroundStyle(zeigeLeerePhase ? .primary : .secondary)
                    }
                    .help(zeigeLeerePhase ? "Leere Phasen ausblenden" : "Leere Phasen einblenden")

                    // Ansicht umschalten: Liste ↔ Kanban
                    Button {
                        withAnimation { kanbanAnsicht.toggle() }
                    } label: {
                        Image(systemName: kanbanAnsicht ? "list.bullet" : "rectangle.split.3x1")
                    }
                    .help(kanbanAnsicht ? "Als Liste anzeigen" : "Als Kanban-Board anzeigen")

                    // Zahnrad: Einstellungen (Intro & Erinnerungen)
                    Button {
                        zeigeEinstellungen = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .help("Einstellungen")
                }
                // Plus: schnelle Idee festhalten (2-Minuten-Regel)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        zeigeQuickIdea = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help("Neue Idee festhalten")
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
        .sheet(isPresented: $zeigeQuickIdea) {
            QuickIdeaView()
        }
        .sheet(isPresented: $zeigeEinstellungen) {
            EinstellungenView()
        }
        .onAppear {
            setupStandardPhasen(context: modelContext)
            refreshID += 1
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { setupStandardPhasen(context: modelContext) }
        }
    }

    // MARK: Ansichten

    /// Klassische Liste: Phasen-Gruppen untereinander
    private var listenAnsichtView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(sichtbarePhasen) { phase in
                    PhasenGruppeView(phase: phase, refreshID: refreshID) {
                        bearbeitetePhase = phase
                    } onNeuesVorhaben: {
                        neuesVorhaben(in: phase)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    /// Kanban-Board: Phasen als horizontale Spalten
    private var kanbanAnsichtView: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 12) {
                    ForEach(sichtbarePhasen) { phase in
                        PhasenSpalteView(phase: phase, refreshID: refreshID) {
                            bearbeitetePhase = phase
                        } onNeuesVorhaben: {
                            neuesVorhaben(in: phase)
                        }
                        .frame(width: 300, height: geo.size.height - 16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }

    private func neuesVorhaben(in phase: PhaseModel) {
        let vorhaben = VorhabenModel(phase: phase.sort)
        modelContext.insert(vorhaben)
        addStandardAufgaben(vorhaben: vorhaben)
        newVorhaben = vorhaben
        isNewVorhaben = true
    }
}

// MARK: - Phasen-Gruppen-Karte

struct PhasenGruppeView: View {
    @Environment(\.modelContext) private var modelContext

    let phase: PhaseModel
    let refreshID: Int
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
                            .fill(phase.viewFarbe.opacity(0.15))
                            .frame(width: 30, height: 30)
                        Image(systemName: phase.icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(phase.viewFarbe)
                    }

                    // Texte
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(phase.name)
                                .fontWeight(.regular)
                                .foregroundStyle(phase.viewFarbe)
                            Text("(\(vorhabens.count))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if !phase.info.isEmpty {
                            Text(phase.info)
                                .font(.caption)
                                .foregroundStyle(phase.viewFarbe)
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
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            // MARK: Vorhaben-Liste
            if istAusgeklappt {
                Divider()
                    .padding(.horizontal, 16)

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
                    .padding(.vertical, 12)
                } else {
                    VStack(spacing: 8) {
                        ForEach(vorhabens) { vorhaben in
                            NavigationLink {
                                VorhabenEditor(vorhaben: vorhaben)
                            } label: {
                                VorhabenZeile(vorhaben: vorhaben, showPhase: false, phaseColor: phase.viewFarbe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        }
    }
}

// MARK: - Kanban-Spalte

struct PhasenSpalteView: View {
    @Environment(\.modelContext) private var modelContext

    let phase: PhaseModel
    let refreshID: Int
    var onBearbeiten: () -> Void
    var onNeuesVorhaben: () -> Void

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
        VStack(spacing: 0) {

            // MARK: Spalten-Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(phase.viewFarbe.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: phase.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(phase.viewFarbe)
                }

                VStack(alignment: .leading, spacing: 1) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(phase.name)
                            .fontWeight(.medium)
                            .foregroundStyle(phase.viewFarbe)
                        Text("(\(vorhabens.count))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if !phase.info.isEmpty {
                        Text(phase.info)
                            .font(.caption2)
                            .foregroundStyle(phase.viewFarbe.opacity(0.8))
                            .lineLimit(1)
                    }
                }

                Spacer()

                Button {
                    onBearbeiten()
                } label: {
                    Image(systemName: "pencil.circle")
                        .font(.title3)
                        .foregroundStyle(phase.viewFarbe.opacity(0.7))
                }
                .buttonStyle(.plain)

                Button {
                    onNeuesVorhaben()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(phase.viewFarbe)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()
                .padding(.horizontal, 14)

            // MARK: Karten
            ScrollView {
                VStack(spacing: 8) {
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
                        .padding(.vertical, 12)
                    } else {
                        ForEach(vorhabens) { vorhaben in
                            VorhabenZeile(vorhaben: vorhaben, showPhase: false, phaseColor: phase.viewFarbe)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        }
    }
}

// MARK: - Preview

@MainActor
private func expeditionPreviewContainer() -> ModelContainer {
    let container = try! ModelContainer(
        for: VorhabenModel.self, PhaseModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    setupStandardPhasen(context: container.mainContext)
    let vorhaben1 = VorhabenModel(bezeichnung: "iLifeDesign", icon: "iphone", phase: 2, priority: 4, beschreibung: "Tool entwickeln", lebensbereich: 2)
    let vorhaben2 = VorhabenModel(bezeichnung: "Balkon einrichten", icon: "house", phase: 2, priority: 2, beschreibung: "Schöner Balkon", lebensbereich: 4)
    container.mainContext.insert(vorhaben1)
    container.mainContext.insert(vorhaben2)
    addStandardAufgaben(vorhaben: vorhaben1)
    addStandardAufgaben(vorhaben: vorhaben2)
    return container
}

#Preview("Liste") {
    UserDefaults.standard.set(false, forKey: "expeditionKanban")
    return ExpeditionView()
        .modelContainer(expeditionPreviewContainer())
}

#Preview("Kanban") {
    UserDefaults.standard.set(true, forKey: "expeditionKanban")
    return ExpeditionView()
        .modelContainer(expeditionPreviewContainer())
}
