//
//  AufgabenListeView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//  Überarbeitet: Sandra Sulzberger, 12.07.2026

import SwiftUI
import SwiftData

struct AufgabenListeView: View {
    @Bindable var vorhaben: VorhabenModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var aktiverIndex: Int? = nil
    @State private var scrollProxy: ScrollViewProxy? = nil
    /// Neuer Date-Stempel = Fokus jetzt setzen. nil = kein Fokus.
    @State private var fokusZeitpunkt: Date? = nil

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

                            ForEach(Array(fragen.enumerated()), id: \.element.persistentModelID) { index, frage in
                                FrageCard(
                                    frage: frage,
                                    index: index,
                                    istAktiv: aktiverIndex == index,
                                    fokusZeitpunkt: aktiverIndex == index ? fokusZeitpunkt : nil,
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
                    .id("phase-\(vorhaben.phase)")
                    .onAppear {
                        scrollProxy = proxy
                        let zielIndex = nächsteUnbeantwortetIndex ?? 0
                        aktiverIndex = zielIndex
                        // 1. Warten bis fullScreenCover vollständig eingeblendet ist
                        // 2. Scrollen
                        // 3. Warten bis Scroll fertig
                        // 4. Fokus setzen → Tastatur öffnet sich
                        Task {
                            try? await Task.sleep(for: .milliseconds(450))
                            withAnimation(.easeInOut(duration: 0.35)) {
                                proxy.scrollTo(zielIndex, anchor: .top)
                            }
                            try? await Task.sleep(for: .milliseconds(450))
                            fokusZeitpunkt = Date()
                        }
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
            .onChange(of: vorhaben.phase) { _, _ in
                fokusZeitpunkt = nil
                withAnimation(.spring(response: 0.4)) {
                    aktiverIndex = nächsteUnbeantwortetIndex ?? 0
                }
                Task {
                    try? await Task.sleep(for: .milliseconds(200))
                    withAnimation { scrollProxy?.scrollTo(0, anchor: .top) }
                    try? await Task.sleep(for: .milliseconds(450))
                    fokusZeitpunkt = Date()
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
        let antwort = frage.antwort.trimmingCharacters(in: .whitespacesAndNewlines)
        if !antwort.isEmpty { frage.erledigt = true }

        let nextIndex = currentIndex + 1
        guard nextIndex < fragen.count else { return }

        fokusZeitpunkt = nil
        withAnimation(.spring(response: 0.35)) {
            aktiverIndex = nextIndex
        }
        Task {
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation { scrollProxy?.scrollTo(nextIndex, anchor: .top) }
            try? await Task.sleep(for: .milliseconds(350))
            fokusZeitpunkt = Date()
        }
    }

    private func handleNächstePhase() {
        abschlussfrage?.erledigt = true

        let frage = abschlussfrage
        let reflexion = PhaseReflexionModel(
            phase: vorhaben.phase,
            phaseName: vorhaben.viewPhase,
            phaseIcon: vorhaben.viewPhaseIcon,
            phaseFarbeID: {
                let aktuellePhase: Int = vorhaben.phase
                let fetch = FetchDescriptor<PhaseModel>(
                    predicate: #Predicate<PhaseModel> { phaseModel in
                        phaseModel.sort == aktuellePhase
                    }
                )
                return (try? modelContext.fetch(fetch))?.first?.farbeID ?? "blue"
            }(),
            frage: frage?.aufgabe ?? "",
            antwort: frage?.antwort ?? "",
            datum: Date(),
            vorhaben: vorhaben
        )
        modelContext.insert(reflexion)

        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            vorhaben.phase += 1
        }
    }
}

// MARK: - Frage-Karte

struct FrageCard: View {
    @Bindable var frage: AufgabeModel
    let index: Int
    let istAktiv: Bool
    /// Neuer Date-Stempel von außen → Fokus jetzt setzen
    let fokusZeitpunkt: Date?
    let phaseColor: Color
    let istAbschlussfrage: Bool
    var onNext: () -> Void
    var onNächstePhase: () -> Void

    @FocusState private var textFeldFokussiert: Bool

    private var istBeantwortet: Bool {
        !frage.antwort.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Badge

    @ViewBuilder
    private var badgeView: some View {
        let badgeFill: Color = istBeantwortet
            ? phaseColor
            : (istAbschlussfrage ? phaseColor.opacity(0.2) : Color(.systemGray5))
        ZStack {
            Circle()
                .fill(badgeFill)
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
    }

    // MARK: - Action-Button-Zeile

    @ViewBuilder
    private var actionButtonRow: some View {
        HStack {
            Spacer()
            if istAbschlussfrage {
                Button { onNächstePhase() } label: {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text("Nächste Phase").fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                    .background { Capsule().fill(phaseColor) }
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button { onNext() } label: {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text("Weiter").fontWeight(.medium)
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

    // MARK: - Textfeld

    @ViewBuilder
    private var antwortTextField: some View {
        let borderColor: Color = textFeldFokussiert ? phaseColor : phaseColor.opacity(0.25)
        let borderWidth: CGFloat = textFeldFokussiert ? 2 : 1
        let placeholder = istAbschlussfrage
            ? "Deine Kernaussage für diese Phase…"
            : "Was hast Du getan / erkannt…"

        TextField(placeholder, text: $frage.antwort, axis: .vertical)
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
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
            }
            // Fokus setzen sobald AufgabenListeView den Stempel setzt
            .onChange(of: fokusZeitpunkt) { _, zeitpunkt in
                guard zeitpunkt != nil, !istBeantwortet else { return }
                textFeldFokussiert = true
            }
            .onChange(of: frage.antwort) { _, neu in
                frage.erledigt = !neu.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
    }

    // MARK: - Hintergrund

    @ViewBuilder
    private var cardBackground: some View {
        let fillStyle: AnyShapeStyle = istAbschlussfrage
            ? AnyShapeStyle(phaseColor.opacity(0.08))
            : AnyShapeStyle(.ultraThinMaterial)
        let strokeColor: Color = istAbschlussfrage
            ? phaseColor.opacity(istAktiv ? 0.6 : 0.3)
            : phaseColor.opacity(istAktiv ? 0.4 : 0.1)
        let strokeWidth: CGFloat = istAbschlussfrage ? 2 : 1
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
            .fill(fillStyle)
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {

            HStack(spacing: DesignSystem.Spacing.sm) {
                badgeView
                Text(frage.aufgabe)
                    .font(istAbschlussfrage ? .subheadline.bold() : .subheadline)
                    .foregroundStyle(istAbschlussfrage ? phaseColor : .primary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }

            if istAktiv || istBeantwortet {
                antwortTextField

                if istAktiv && istBeantwortet {
                    actionButtonRow
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background { cardBackground }
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
