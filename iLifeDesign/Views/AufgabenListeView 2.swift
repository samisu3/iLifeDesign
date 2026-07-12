//
//  AufgabenListeView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//  Überarbeitet: Sandra Sulzberger, 12.07.2026
//

import SwiftUI
import SwiftData

struct AufgabenListeView: View {
    @Bindable var vorhaben: VorhabenModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    /// Index der aktuell fokussierten Frage (nil = keine)
    @State private var aktiverIndex: Int? = nil
    /// Scrollposition
    @State private var scrollProxy: ScrollViewProxy? = nil

    // MARK: - Hilfsfunktionen

    private var fragen: [AufgabeModel] {
        vorhaben.viewAktuelleAufgaben
    }

    private var nächsteUnbeantwortetIndex: Int? {
        fragen.firstIndex { $0.antwort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private var alleBeantwortet: Bool {
        fragen.allSatisfy { !$0.antwort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    /// Abschlussfrage ist die letzte Frage der Phase (istAbschlussfrage == true)
    private var abschlussfrage: AufgabeModel? {
        fragen.last(where: { $0.istAbschlussfrage })
    }

    private var abschlussfrageBeantwortet: Bool {
        guard let a = abschlussfrage else { return false }
        return !a.antwort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.backgroundGradient(for: vorhaben.viewColor)
                    .ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.lg) {
                            headerSection

                            ForEach(Array(fragen.enumerated()), id: \.element) { index, frage in
                                FrageCard(
                                    frage: frage,
                                    index: index,
                                    istAktiv: aktiverIndex == index,
                                    phaseColor: vorhaben.viewColor,
                                    istAbschlussfrage: frage.istAbschlussfrage,
                                    onNext: { handleNext(currentIndex: index) },
                                    onNächstePhase: { handleNächstePhase() }
                                )
                                .id(index)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        aktiverIndex = index
                                    }
                                }
                            }

                            Spacer(minLength: 40)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        // Ersten unbeantworteten Index aktivieren
                        aktiverIndex = nächsteUnbeantwortetIndex ?? 0
                    }
                }
            }
            .navigationTitle(vorhaben.viewPhase)
            .modernNavigation()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(vorhaben.viewColor.opacity(0.2))
                        .frame(width: 56, height: 56)
                        .overlay { Circle().stroke(vorhaben.viewColor.opacity(0.4), lineWidth: 2) }
                    Image(systemName: vorhaben.viewPhaseIcon)
                        .font(.title2).fontWeight(.semibold)
                        .foregroundStyle(vorhaben.viewColor)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(vorhaben.bezeichnung)
                        .font(.title3).fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text(vorhaben.viewPhaseInfo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            // Fortschrittsbalken
            let beantwortet = fragen.filter {
                !$0.antwort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }.count
            let total = fragen.count

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack {
                    Text("Fortschritt")
                        .font(.caption).fontWeight(.semibold)
                    Spacer()
                    Text("\(beantwortet) / \(total)")
                        .font(.caption).fontWeight(.bold)
                        .foregroundStyle(vorhaben.viewColor)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5)).frame(height: 6)
                        if total > 0 {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(vorhaben.viewColor)
                                .frame(width: geo.size.width * (Double(beantwortet) / Double(total)), height: 6)
                                .animation(.easeInOut(duration: 0.4), value: beantwortet)
                        }
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .modernCard(color: vorhaben.viewColor, cornerRadius: DesignSystem.CornerRadius.xl)
    }

    // MARK: - Aktionen

    private func handleNext(currentIndex: Int) {
        let frage = fragen[currentIndex]
        // Antwort setzen → erledigt automatisch
        let antwort = frage.antwort.trimmingCharacters(in: .whitespacesAndNewlines)
        if !antwort.isEmpty {
            frage.erledigt = true
        }

        let nextIndex = currentIndex + 1
        if nextIndex < fragen.count {
            withAnimation(.spring(response: 0.35)) {
                aktiverIndex = nextIndex
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation { scrollProxy?.scrollTo(nextIndex, anchor: .top) }
            }
        }
    }

    private func handleNächstePhase() {
        // Abschlussfrage als erledigt markieren
        abschlussfrage?.erledigt = true

        // Reflexion speichern
        let frage = abschlussfrage
        let reflexion = PhaseReflexionModel(
            phase: vorhaben.phase,
            phaseName: vorhaben.viewPhase,
            phaseIcon: vorhaben.viewPhaseIcon,
            phaseFarbeID: {
                // FarbeID aus PhaseModel lesen
                let fetch = FetchDescriptor<PhaseModel>(
                    predicate: #Predicate { $0.sort == vorhaben.phase }
                )
                return (try? modelContext.fetch(fetch))?.first?.farbeID ?? "blue"
            }(),
            frage: frage?.aufgabe ?? "",
            antwort: frage?.antwort ?? "",
            datum: Date(),
            vorhaben: vorhaben
        )
        modelContext.insert(reflexion)

        // Phasenwechsel
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            vorhaben.phase += 1
        }
        dismiss()
    }
}

// MARK: - Frage-Karte

struct FrageCard: View {
    @Bindable var frage: AufgabeModel
    let index: Int
    let istAktiv: Bool
    let phaseColor: Color
    let istAbschlussfrage: Bool
    var onNext: () -> Void
    var onNächstePhase: () -> Void

    @FocusState private var textFeldFokussiert: Bool

    private var istBeantwortet: Bool {
        !frage.antwort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {

            // MARK: Frage-Header
            HStack(spacing: DesignSystem.Spacing.sm) {
                // Nummer-Badge oder Abschluss-Icon
                ZStack {
                    Circle()
                        .fill(istBeantwortet ? phaseColor : (istAbschlussfrage ? phaseColor.opacity(0.2) : Color(.systemGray5)))
                        .frame(width: 28, height: 28)
                    if istBeantwortet {
                        Image(systemName: "checkmark")
                            .font(.caption).fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else if istAbschlussfrage {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(phaseColor)
                    } else {
                        Text("\(index + 1)")
                            .font(.caption2).fontWeight(.bold)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(frage.aufgabe)
                    .font(istAbschlussfrage ? .subheadline.bold() : .subheadline)
                    .foregroundStyle(istAbschlussfrage ? phaseColor : .primary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }

            // MARK: Antwort-Textfeld (nur wenn aktiv oder bereits beantwortet)
            if istAktiv || istBeantwortet {
                TextField("Deine Antwort…", text: $frage.antwort, axis: .vertical)
                    .font(.subheadline)
                    .textFieldStyle(.plain)
                    .lineLimit(2...6)
                    .focused($textFeldFokussiert)
                    .padding(DesignSystem.Spacing.md)
                    .background {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                    .stroke(
                                        textFeldFokussiert ? phaseColor : phaseColor.opacity(0.25),
                                        lineWidth: textFeldFokussiert ? 2 : 1
                                    )
                            }
                    }
                    .onAppear {
                        if istAktiv && !istBeantwortet {
                            textFeldFokussiert = true
                        }
                    }
                    .onChange(of: frage.antwort) { _, neu in
                        // Erledigt automatisch setzen wenn Antwort vorhanden
                        frage.erledigt = !neu.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    }

                // MARK: Next / Nächste Phase Button
                if istAktiv && istBeantwortet {
                    HStack {
                        Spacer()
                        if istAbschlussfrage {
                            Button {
                                onNächstePhase()
                            } label: {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Text("Nächste Phase")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                                .padding(.vertical, DesignSystem.Spacing.sm)
                                .background {
                                    Capsule().fill(phaseColor)
                                }
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            Button {
                                onNext()
                            } label: {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Text("Weiter")
                                        .fontWeight(.medium)
                                    Image(systemName: "arrow.down.circle")
                                }
                                .font(.subheadline)
                                .foregroundStyle(phaseColor)
                            }
                            .buttonStyle(.plain)
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(response: 0.3), value: istBeantwortet)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(istAbschlussfrage ? phaseColor.opacity(0.08) : .ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(
                            istAbschlussfrage
                                ? phaseColor.opacity(istAktiv ? 0.6 : 0.3)
                                : phaseColor.opacity(istAktiv ? 0.4 : 0.1),
                            lineWidth: istAbschlussfrage ? 2 : 1
                        )
                }
        }
        .animation(.spring(response: 0.3), value: istAktiv)
        .animation(.spring(response: 0.3), value: istBeantwortet)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    do {
        let container = try ModelContainer(
            for: VorhabenModel.self, PhaseReflexionModel.self,
            configurations: config
        )
        let vorhaben = VorhabenModel.preview2
        addStandardAufgaben(vorhaben: vorhaben)
        container.mainContext.insert(vorhaben)
        return AufgabenListeView(vorhaben: vorhaben)
            .modelContainer(container)
    } catch {
        return Text("Preview nicht verfügbar")
    }
}
