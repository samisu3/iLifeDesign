//
//  ExpeditionView.swift
//  iLifeDesign
//
//  Kombinierte Ansicht: Vorhaben-Header + 5-Phasen-Akkordeon + Verlauf.
//  Wird über "Mein Leben" (Post-it-Tippen) oder den Expedition-Tab erreicht.
//

import SwiftUI
import SwiftData

// MARK: - Haupt-View

struct ExpeditionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AppState.self) private var appState

    @Query(sort: \PhaseModel.sort) private var phasen: [PhaseModel]
    @Query(sort: \VorhabenModel.priority, order: .reverse) private var alleVorhaben: [VorhabenModel]
    @Query(sort: \LebensbereichModel.sort) private var lebensbereiche: [LebensbereichModel]

    private enum AnsichtsModus { case neu, bearbeiten, anzeigen }
    @State private var modus: AnsichtsModus = .anzeigen
    @State private var zeigeSymbolPicker = false
    @State private var zeigeDeleteAlert = false
    @State private var zuLöschendesExperiment: VorhabenModel? = nil
    @State private var zeigeKonfetti = false
    @State private var erfolgsBotschaft = ""

    private var aktiveVorhaben: VorhabenModel? { appState.aktivesVorhaben }

    private var aktivePhaseColor: Color {
        guard let v = aktiveVorhaben else { return .blue }
        return phasen.first { $0.sort == v.phase }?.viewFarbe ?? phaseDefaultColor(v.phase)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                Group {
                    if phasen.isEmpty {
                        ContentUnavailableView("Keine Phasen", systemImage: "infinity",
                                               description: Text("Phasen werden beim Start angelegt."))
                    } else if alleVorhaben.isEmpty {
                        ContentUnavailableView(
                            "Noch kein Experiment",
                            systemImage: "map",
                            description: Text("Tippe auf + um dein erstes Experiment anzulegen.")
                        )
                    } else {
                        hauptAnsicht
                    }
                }

                if zeigeKonfetti {
                    KonfettiView()
                    VStack {
                        Text(erfolgsBotschaft)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(Capsule().fill(aktivePhaseColor))
                            .shadow(color: aktivePhaseColor.opacity(0.35), radius: 8, y: 4)
                            .padding(.top, 8)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .allowsHitTesting(false)
                }
            }
            .navigationTitle("Experiment")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if modus == .anzeigen {
                        Button {
                            appState.selectedTab = 0
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                    } else {
                        Button("Abbrechen") {
                            modus = .anzeigen
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if modus == .anzeigen {
                        if aktiveVorhaben != nil {
                            Button { modus = .bearbeiten } label: {
                                Image(systemName: "pencil")
                            }
                            Button {
                                zuLöschendesExperiment = aktiveVorhaben
                                zeigeDeleteAlert = true
                            } label: {
                                Image(systemName: "trash")
                            }
                            .tint(.red)
                        }
                    } else {
                        Button("Speichern") { modus = .anzeigen }
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .sheet(isPresented: $zeigeSymbolPicker) {
            if let v = aktiveVorhaben { SymbolPickerView(vorhaben: v) }
        }
        .alert("Experiment löschen", isPresented: $zeigeDeleteAlert, presenting: zuLöschendesExperiment) { v in
            Button("Löschen", role: .destructive) { deleteExperiment(v) }
            Button("Abbrechen", role: .cancel) { zuLöschendesExperiment = nil }
        } message: { v in
            if !v.bezeichnung.isEmpty {
                Text("\"\(v.bezeichnung)\" wird mit allen Phasen und dem Verlauf unwiderruflich gelöscht.")
            } else {
                Text("Dieses Experiment wird mit allen Phasen und dem Verlauf unwiderruflich gelöscht.")
            }
        }
        .onAppear {
            setupStandardPhasen(context: modelContext)
            autoSelectVorhaben()
        }
        .onChange(of: scenePhase) { _, neu in
            if neu == .active { setupStandardPhasen(context: modelContext) }
        }
        .onChange(of: alleVorhaben) { alt, neu in
            // Nur zurücksetzen wenn das aktive Vorhaben gelöscht wurde (Liste kürzer)
            if let aktiv = appState.aktivesVorhaben,
               neu.count <= alt.count,
               !neu.contains(where: { $0.persistentModelID == aktiv.persistentModelID }) {
                appState.aktivesVorhaben = nil
            }
            if appState.aktivesVorhaben == nil { autoSelectVorhaben() }
        }
        .onChange(of: appState.aktivesVorhaben?.persistentModelID) { _, _ in
            if let v = appState.aktivesVorhaben, v.bezeichnung.isEmpty {
                modus = .neu
            } else if modus == .bearbeiten {
                modus = .anzeigen
            }
        }
    }

    // MARK: Haupt-Ansicht

    @ViewBuilder
    private var hauptAnsicht: some View {
        if let vorhaben = aktiveVorhaben {
            ScrollView {
                VStack(spacing: 10) {
                    vorhabenKopf(vorhaben: vorhaben)
                    vorhabenDetailKarte(vorhaben: vorhaben)

                    ForEach(phasen) { phase in
                        PhasenBalkenView(
                            phase: phase,
                            vorhaben: vorhaben,
                            onNächstePhase: { handleNächstePhase(vorhaben: vorhaben) }
                        )
                    }

                    verlaufSection(vorhaben: vorhaben)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .sensoryFeedback(.impact(weight: .light), trigger: vorhaben.phase)
        }
    }

    // MARK: Vorhaben-Kopf

    private func vorhabenKopf(vorhaben: VorhabenModel) -> some View {
        HStack(spacing: 12) {
            let iconZirkel = ZStack {
                Circle()
                    .fill(aktivePhaseColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: vorhaben.viewIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(aktivePhaseColor)
            }

            if modus != .anzeigen {
                Button { zeigeSymbolPicker = true } label: {
                    iconZirkel
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(aktivePhaseColor)
                                .background(Color(.systemBackground).clipShape(Circle()))
                        }
                }
                .buttonStyle(.plain)
            } else {
                iconZirkel
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Aktives Experiment")
                    .font(.caption).foregroundStyle(.secondary)
                Text(vorhaben.bezeichnung.isEmpty ? "Unbenannt" : vorhaben.bezeichnung)
                    .font(.headline).foregroundStyle(.primary).lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        }
    }

    // MARK: Vorhaben-Detail-Karte

    @ViewBuilder
    private func vorhabenDetailKarte(vorhaben: VorhabenModel) -> some View {
        let b = Bindable(vorhaben)
        VStack(alignment: .leading, spacing: 12) {
            if modus != .anzeigen {
                // Bearbeiten / Neu
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Titel", text: b.bezeichnung)
                        .font(.title3.bold())

                    Divider()

                    TextField("Beschreibung", text: b.beschreibung, axis: .vertical)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2...4)

                    Divider()

                    HStack {
                        Text("Priorität")
                            .font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        HStack(spacing: 2) {
                            ForEach(0...4, id: \.self) { star in
                                Button {
                                    vorhaben.priority = star
                                } label: {
                                    Image(systemName: star <= vorhaben.priority ? "star.fill" : "star")
                                        .font(.subheadline)
                                        .foregroundStyle(star <= vorhaben.priority ? .orange : Color(.systemGray4))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Divider()

                    Menu {
                        ForEach(lebensbereiche.filter { $0.istAktiv }) { bereich in
                            Button {
                                vorhaben.lebensbereichRef = bereich
                                vorhaben.lebensbereich = bereich.sort
                            } label: {
                                HStack {
                                    Image(systemName: bereich.icon)
                                    Text(bereich.name)
                                    if vorhaben.lebensbereichRef?.id == bereich.id {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Lebensbereich")
                                .font(.caption).foregroundStyle(.secondary)
                            Spacer()
                            HStack(spacing: 5) {
                                Image(systemName: vorhaben.viewLebensbereichIcon)
                                    .foregroundStyle(vorhaben.viewLebensbereichFarbe)
                                Text(vorhaben.viewLebensbereich.isEmpty ? "Wählen…" : vorhaben.viewLebensbereich)
                                    .foregroundStyle(vorhaben.viewLebensbereich.isEmpty ? .secondary : vorhaben.viewLebensbereichFarbe)
                            }
                            .font(.caption)
                        }
                    }
                    .tint(.primary)
                }
            } else {
                // Anzeigen (read-only)
                if !vorhaben.beschreibung.isEmpty {
                    Text(vorhaben.beschreibung)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                    Divider()
                }

                HStack(spacing: 0) {
                    HStack(spacing: 3) {
                        ForEach(0...4, id: \.self) { star in
                            Image(systemName: star <= vorhaben.priority ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(star <= vorhaben.priority ? .orange : Color(.systemGray4))
                        }
                    }
                    Spacer()
                    Text("Iteration \(vorhaben.iteration)")
                        .font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    if let bereich = vorhaben.lebensbereichRef {
                        HStack(spacing: 5) {
                            Image(systemName: bereich.icon)
                                .font(.caption)
                                .foregroundStyle(bereich.viewFarbe)
                            Text(bereich.name)
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    } else if !vorhaben.viewLebensbereich.isEmpty {
                        Text(vorhaben.viewLebensbereich)
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
    }

    // MARK: Verlauf-Sektion

    @ViewBuilder
    private func verlaufSection(vorhaben: VorhabenModel) -> some View {
        let reflexionen = (vorhaben.reflexionen ?? []).sorted { $0.datum > $1.datum }
        if !reflexionen.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Verlauf")
                        .font(.footnote.bold().uppercaseSmallCaps())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(reflexionen.count)")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .padding(.top, 6)

                ForEach(reflexionen) { reflexion in
                    VerlaufKarte(reflexion: reflexion)
                }
            }
            .padding(.bottom, 8)
        }
    }

    // MARK: Auto-Selektion

    private func autoSelectVorhaben() {
        guard appState.aktivesVorhaben == nil else { return }
        appState.aktivesVorhaben = alleVorhaben.first(where: {
            !$0.viewAktuelleAufgabenErledigt && !$0.viewAktuelleAufgaben.isEmpty
        }) ?? alleVorhaben.first
    }

    private func deleteExperiment(_ v: VorhabenModel) {
        zeigeDeleteAlert = false
        zuLöschendesExperiment = nil
        let übrige = alleVorhaben.filter { $0.persistentModelID != v.persistentModelID }
        let nächstes = übrige.first(where: {
            !$0.viewAktuelleAufgabenErledigt && !$0.viewAktuelleAufgaben.isEmpty
        }) ?? übrige.first
        modelContext.delete(v)
        appState.aktivesVorhaben = nächstes
        modus = .anzeigen
    }

    // MARK: Phase abschliessen

    private func handleNächstePhase(vorhaben: VorhabenModel) {
        let fragen = vorhaben.viewAktuelleAufgaben
        let abschlussfrage = fragen.last(where: { $0.istAbschlussfrage })
        abschlussfrage?.erledigt = true

        let phaseFarbeID: String = {
            let aktuell = vorhaben.phase
            let fetch = FetchDescriptor<PhaseModel>(predicate: #Predicate { $0.sort == aktuell })
            return (try? modelContext.fetch(fetch))?.first?.farbeID ?? "blue"
        }()

        modelContext.insert(PhaseReflexionModel(
            phase: vorhaben.phase,
            phaseName: vorhaben.viewPhase,
            phaseIcon: vorhaben.viewPhaseIcon,
            phaseFarbeID: phaseFarbeID,
            frage: abschlussfrage?.aufgabe ?? "",
            antwort: abschlussfrage?.antwort ?? "",
            datum: Date(),
            vorhaben: vorhaben
        ))

        if vorhaben.phase == 3,
           let erkenntnisText = vorhaben.aufgaben?
               .first(where: { $0.phase == 3 && $0.sort == 1 })?.antwort
               .trimmingCharacters(in: .whitespacesAndNewlines),
           !erkenntnisText.isEmpty {
            modelContext.insert(ErkenntnisModel(
                text: erkenntnisText,
                quelle: vorhaben.bezeichnung,
                icon: vorhaben.viewLebensbereichIcon,
                farbeID: vorhaben.lebensbereichRef?.farbeID ?? "blue"
            ))
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            if vorhaben.phase >= PhaseDefaults.count - 1 {
                for a in vorhaben.aufgaben ?? [] { a.antwort = ""; a.erledigt = false }
                vorhaben.iteration += 1
                vorhaben.phase = 0
            } else {
                vorhaben.phase += 1
            }
        }

        erfolgsBotschaft = EntdeckerBotschaften.randomElement() ?? ""
        withAnimation(.spring(response: 0.4)) { zeigeKonfetti = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeOut(duration: 0.4)) { zeigeKonfetti = false }
        }
    }
}

// MARK: - Phasen-Balken (Akkordeon-Element)

struct PhasenBalkenView: View {

    private enum PhasenStatus { case abgeschlossen, aktiv, zukünftig }

    let phase: PhaseModel
    let vorhaben: VorhabenModel
    var onNächstePhase: () -> Void

    private var status: PhasenStatus {
        if phase.sort < vorhaben.phase { return .abgeschlossen }
        if phase.sort == vorhaben.phase { return .aktiv }
        return .zukünftig
    }

    private var aufgaben: [AufgabeModel] {
        (vorhaben.aufgaben ?? [])
            .filter { $0.phase == phase.sort }
            .sorted { $0.sort < $1.sort }
    }

    private var erledigtAnzahl: Int { aufgaben.filter { $0.erledigt }.count }
    private var alleErledigt: Bool { !aufgaben.isEmpty && erledigtAnzahl == aufgaben.count }

    private var abschlussAntwort: String? {
        let a = aufgaben.last(where: { $0.istAbschlussfrage })?.antwort
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return a.isEmpty ? nil : a
    }

    var body: some View {
        VStack(spacing: 0) {
            switch status {
            case .abgeschlossen: abgeschlossenView
            case .aktiv:         aktivView
            case .zukünftig:     zukünftigView
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            if status == .aktiv {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(phase.viewFarbe.opacity(0.35), lineWidth: 1.5)
            }
        }
        .shadow(
            color: status == .aktiv ? phase.viewFarbe.opacity(0.12) : .black.opacity(0.04),
            radius: 6, y: 2
        )
    }

    // MARK: Abgeschlossen

    private var abgeschlossenView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3).foregroundStyle(.green)
                VStack(alignment: .leading, spacing: 1) {
                    Text(phase.name)
                        .font(.subheadline).foregroundStyle(.secondary)
                    Text(phase.info)
                        .font(.caption2).foregroundStyle(.tertiary)
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 12)

            if let antwort = abschlussAntwort {
                Text(antwort)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                    .lineLimit(3)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
    }

    // MARK: Aktiv (aufgeklappt)

    private var aktivView: some View {
        VStack(spacing: 0) {

            // Phasen-Header mit Fortschrittsbalken
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(phase.viewFarbe.opacity(0.18))
                            .frame(width: 38, height: 38)
                        Image(systemName: phase.icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(phase.viewFarbe)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text(phase.name)
                            .font(.subheadline.bold()).foregroundStyle(phase.viewFarbe)
                        Text(phase.info)
                            .font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(erledigtAnzahl)/\(aufgaben.count)")
                        .font(.caption.bold()).foregroundStyle(.secondary).monospacedDigit()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color(.systemGray5)).frame(height: 5)
                        if aufgaben.count > 0 {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(alleErledigt ? Color.green : phase.viewFarbe)
                                .frame(
                                    width: geo.size.width * Double(erledigtAnzahl) / Double(aufgaben.count),
                                    height: 5
                                )
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: erledigtAnzahl)
                        }
                    }
                }
                .frame(height: 5)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(phase.viewFarbe.opacity(0.05))

            Divider().padding(.horizontal, 16)

            // Aufgaben-Zeilen
            VStack(spacing: 0) {
                ForEach(Array(aufgaben.enumerated()), id: \.element.persistentModelID) { idx, aufgabe in
                    AkkordeonAufgabeView(
                        aufgabe: aufgabe,
                        index: idx,
                        phaseColor: phase.viewFarbe
                    )
                    if idx < aufgaben.count - 1 {
                        Divider().padding(.horizontal, 16)
                    }
                }
            }

            // Phasen-Abschluss-Button
            if alleErledigt {
                Divider()
                Button { onNächstePhase() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: vorhaben.phase >= PhaseDefaults.count - 1
                              ? "arrow.counterclockwise.circle.fill"
                              : "arrow.right.circle.fill")
                        Text(vorhaben.phase >= PhaseDefaults.count - 1
                             ? "Neuer Loop starten"
                             : "Nächste Phase freischalten")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(phase.viewFarbe)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Zukünftig (gesperrt)

    private var zukünftigView: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 30, height: 30)
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(.systemGray3))
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(phase.name)
                    .font(.subheadline).foregroundStyle(Color(.systemGray3))
                Text(phase.info)
                    .font(.caption2).foregroundStyle(Color(.systemGray4))
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }
}

// MARK: - Aufgaben-Zeile (inline, aufklappbar)

struct AkkordeonAufgabeView: View {
    @Bindable var aufgabe: AufgabeModel
    let index: Int
    let phaseColor: Color

    @State private var istAusgeklappt = false
    @State private var xpPuls = false

    private var istBeantwortet: Bool {
        !aufgabe.antwort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Zeilen-Kopf
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    istAusgeklappt.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    aufgabeBadge
                        .scaleEffect(xpPuls ? 1.5 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.4), value: xpPuls)

                    Text(aufgabe.aufgabe)
                        .font(aufgabe.istAbschlussfrage ? .subheadline.bold() : .subheadline)
                        .foregroundStyle(
                            aufgabe.erledigt ? .secondary
                            : (aufgabe.istAbschlussfrage ? phaseColor : .primary)
                        )
                        .lineLimit(istAusgeklappt ? nil : 2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 4)

                    Image(systemName: istAusgeklappt ? "chevron.up" : "chevron.down")
                        .font(.caption2).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            // Aufgeklappt: Antwort-Feld
            if istAusgeklappt {
                VStack(alignment: .leading, spacing: 10) {
                    TextField(
                        aufgabe.istAbschlussfrage
                            ? "Deine Kernaussage für diese Phase…"
                            : "Was hast Du getan / erkannt…",
                        text: $aufgabe.antwort,
                        axis: .vertical
                    )
                    .textFieldStyle(.plain)
                    .font(.subheadline)
                    .lineLimit(2...5)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(phaseColor.opacity(0.3), lineWidth: 1)
                            }
                    }

                    // Dezenter Weiter-Button (wie in FrageCard)
                    if istBeantwortet {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { xpPuls = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                    withAnimation { xpPuls = false }
                                    withAnimation(.spring(response: 0.3)) { istAusgeklappt = false }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Weiter").fontWeight(.medium)
                                    Image(systemName: aufgabe.istAbschlussfrage
                                          ? "checkmark.circle" : "arrow.down.circle")
                                }
                                .font(.subheadline)
                                .foregroundStyle(phaseColor)
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                        .animation(.spring(response: 0.3), value: istBeantwortet)
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            aufgabe.erledigt ? phaseColor.opacity(0.06) : Color.clear
        )
        .onChange(of: aufgabe.antwort) { _, neu in
            aufgabe.erledigt = !neu.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    @ViewBuilder
    private var aufgabeBadge: some View {
        ZStack {
            Circle()
                .fill(
                    aufgabe.erledigt
                        ? (aufgabe.istAbschlussfrage ? phaseColor : .green)
                        : (aufgabe.istAbschlussfrage ? phaseColor.opacity(0.15) : Color(.systemGray5))
                )
                .frame(width: 28, height: 28)
            if aufgabe.erledigt {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
            } else if aufgabe.istAbschlussfrage {
                Image(systemName: "star.fill")
                    .font(.system(size: 9)).foregroundStyle(phaseColor)
            } else {
                Text("\(index + 1)")
                    .font(.system(size: 10, weight: .bold)).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ExpeditionView()
        .modelContainer(VorhabenModel.preview)
        .environment(AppState())
}
