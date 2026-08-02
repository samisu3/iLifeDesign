//
//  LebensbereicheView.swift
//  iLifeDesign
//
//  Puppenhaus-Ansicht: Die 7 Zimmer als gestapelte Etagen.
//  Der Dachboden hat ein farbiges Dreieck-Dach.
//  Jedes Vorhaben erscheint als Post-it in seinem Zimmer.
//

import SwiftUI
import SwiftData

// MARK: - Haupt-View

struct LebensbereicheView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query(sort: \LebensbereichModel.sort) private var zimmer: [LebensbereichModel]

    @State private var isNeuerBereich = false
    @State private var neuerBereich: LebensbereichModel?
    @State private var bearbeiteterBereich: LebensbereichModel?

    var body: some View {
        NavigationStack {
            Group {
                if zimmer.isEmpty {
                    ContentUnavailableView(
                        "Kein Haus",
                        systemImage: "house",
                        description: Text("Die Zimmer werden beim Start automatisch angelegt.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(zimmer) { z in
                                ZimmerView(
                                    zimmer: z,
                                    isDachboden: z.sort == 0
                                ) {
                                    let vorhaben = VorhabenModel()
                                    modelContext.insert(vorhaben)
                                    vorhaben.lebensbereichRef = z
                                    vorhaben.lebensbereich = z.sort
                                    addStandardAufgaben(vorhaben: vorhaben)
                                    appState.aktivesVorhaben = vorhaben
                                    appState.selectedTab = 1
                                } onBearbeiten: {
                                    bearbeiteterBereich = z
                                }
                            }

                            // Haus-Sockel
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 10)
                        }
                    }
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                }
            }
            .navigationTitle("Mein Leben")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            let vorhaben = VorhabenModel()
                            modelContext.insert(vorhaben)
                            addStandardAufgaben(vorhaben: vorhaben)
                            appState.aktivesVorhaben = vorhaben
                            appState.selectedTab = 1
                        } label: {
                            Label("Neues Experiment", systemImage: "note.text.badge.plus")
                        }
                        Divider()
                        Button {
                            let bereich = LebensbereichModel(sort: zimmer.count)
                            modelContext.insert(bereich)
                            neuerBereich = bereich
                            isNeuerBereich = true
                        } label: {
                            Label("Neues Zimmer", systemImage: "plus.square")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isNeuerBereich) {
            if let bereich = neuerBereich {
                LebensbereichEditor(bereich: bereich, isNew: true)
            }
        }
        .sheet(item: $bearbeiteterBereich) { bereich in
            LebensbereichEditor(bereich: bereich)
        }
        .onAppear {
            setupStandardLebensbereiche(context: modelContext)
        }
    }
}

// MARK: - Zimmer-Sektion

struct ZimmerView: View {
    let zimmer: LebensbereichModel
    let isDachboden: Bool
    var onNeuesVorhaben: () -> Void
    var onBearbeiten: () -> Void

    @Environment(AppState.self) private var appState

    private var vorhabens: [VorhabenModel] {
        (zimmer.vorhaben ?? []).sorted { $0.priority > $1.priority }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isDachboden {
                dachbodenHeader
            } else {
                normalHeader
            }
            postItBereich
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(zimmer.viewFarbe.opacity(0.5))
                .frame(width: 4)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 2)
        }
        .opacity(zimmer.istAktiv ? 1.0 : 0.55)
    }

    // MARK: Dachboden-Header: farbiges Dreieck mit Inhalt am unteren Rand

    private var dachbodenHeader: some View {
        ZStack(alignment: .bottom) {
            // Dreieck-Füllfläche in der Zimmer-Farbe
            GeometryReader { geo in
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    path.closeSubpath()
                }
                .fill(zimmer.viewFarbe.opacity(0.18))

                // Dreieck-Kanten
                Path { path in
                    path.move(to: CGPoint(x: geo.size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: geo.size.width - 2, y: geo.size.height))
                    path.move(to: CGPoint(x: geo.size.width / 2, y: 0))
                    path.addLine(to: CGPoint(x: 2, y: geo.size.height))
                }
                .stroke(zimmer.viewFarbe.opacity(0.4), lineWidth: 1.5)

                // Zimmer-Icon in der Dreieck-Spitze
                Image(systemName: zimmer.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(zimmer.viewFarbe.opacity(0.8))
                    .position(x: geo.size.width / 2, y: 22)
            }

            // Inhalt am unteren Rand des Dreiecks
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(zimmer.name)
                        .font(.subheadline.bold())
                        .foregroundStyle(zimmer.viewFarbe)
                    if !zimmer.beschreibung.isEmpty {
                        Text(zimmer.beschreibung)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    EinschaetzungsStreifen(wert: zimmer.einschaetzung, farbe: zimmer.viewFarbe)
                }

                Spacer()

                if !vorhabens.isEmpty {
                    Text("\(vorhabens.count)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(zimmer.viewFarbe.opacity(0.7))
                        .clipShape(Capsule())
                }

                Button { onBearbeiten() } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.subheadline)
                        .foregroundStyle(zimmer.viewFarbe.opacity(0.6))
                }
                .buttonStyle(.plain)

                Button { onNeuesVorhaben() } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(zimmer.viewFarbe)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .frame(height: 110)
    }

    // MARK: Normaler rechteckiger Header

    private var normalHeader: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(zimmer.viewFarbe.opacity(0.20))
                    .frame(width: 38, height: 38)
                Image(systemName: zimmer.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(zimmer.viewFarbe)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(zimmer.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(zimmer.viewFarbe)
                if !zimmer.beschreibung.isEmpty {
                    Text(zimmer.beschreibung)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                EinschaetzungsStreifen(wert: zimmer.einschaetzung, farbe: zimmer.viewFarbe)
            }

            Spacer()

            if !vorhabens.isEmpty {
                Text("\(vorhabens.count)")
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(zimmer.viewFarbe.opacity(0.7))
                    .clipShape(Capsule())
            }

            Button { onBearbeiten() } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.subheadline)
                    .foregroundStyle(zimmer.viewFarbe.opacity(0.6))
            }
            .buttonStyle(.plain)

            Button { onNeuesVorhaben() } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(zimmer.viewFarbe)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(zimmer.viewFarbe.opacity(0.10))
    }

    // MARK: Post-it-Bereich

    @ViewBuilder
    private var postItBereich: some View {
        if vorhabens.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(zimmer.viewFarbe.opacity(0.35))
                Text("Noch keine Experimente – tippe auf + um ein Post-it anzupinnen")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(zimmer.viewFarbe.opacity(0.04))
        } else {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 130), spacing: 10)],
                spacing: 10
            ) {
                ForEach(vorhabens) { vorhaben in
                    Button {
                        appState.aktivesVorhaben = vorhaben
                        appState.selectedTab = 1
                    } label: {
                        PostItView(vorhaben: vorhaben, zimmerFarbe: zimmer.viewFarbe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(zimmer.viewFarbe.opacity(0.04))
        }
    }
}

// MARK: - Selbsteinschätzungs-Streifen (1–10)

struct EinschaetzungsStreifen: View {
    let wert: Int   // 1–10
    let farbe: Color

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...10, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(i <= wert ? farbe : farbe.opacity(0.15))
                    .frame(width: 9, height: 4)
            }
            Text("\(wert)/10")
                .font(.system(size: 9, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .padding(.leading, 2)
        }
    }
}

// MARK: - Post-it Karte

struct PostItView: View {
    let vorhaben: VorhabenModel
    let zimmerFarbe: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top) {
                Image(systemName: vorhaben.viewIcon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(zimmerFarbe)
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<(vorhaben.priority + 1), id: \.self) { _ in
                        Circle()
                            .fill(zimmerFarbe.opacity(0.55))
                            .frame(width: 5, height: 5)
                    }
                }
            }

            Spacer(minLength: 4)

            Text(vorhaben.bezeichnung.isEmpty ? "Neues Experiment" : vorhaben.bezeichnung)
                .font(.caption.bold())
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 3) {
                Image(systemName: vorhaben.viewPhaseIcon)
                    .font(.system(size: 8))
                Text(vorhaben.viewPhase)
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 90, alignment: .topLeading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(zimmerFarbe.opacity(0.18))
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
        }
        .shadow(color: .black.opacity(0.12), radius: 3, x: 1, y: 2)
    }
}

// MARK: - Preview

#Preview {
    LebensbereicheView()
        .modelContainer(VorhabenModel.preview)
}
