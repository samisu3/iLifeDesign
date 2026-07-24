//
//  QuickIdeaView.swift
//  iLifeDesign
//
//  Quick-Capture nach der 2-Minuten-Regel (Atomic Habits):
//  Eine Idee braucht nur 1 Satz und 1 Dimension — alles Weitere
//  kommt später im Kompass. Mit Inspirations-Pool für Mikro-Experimente.
//

import SwiftUI
import SwiftData

// MARK: - Inspirations-Pool: Mikro-Experimente

struct MikroIdee {
    let text: String
    /// sort-Wert der passenden Dimension (0–4)
    let dimension: Int
}

let MikroIdeen: [MikroIdee] = [
    MikroIdee(text: "Geh 10 Minuten ohne Ziel spazieren und beobachte, was Dir auffällt", dimension: 0),
    MikroIdee(text: "Schreibe drei Dinge auf, die Dir heute Energie gegeben haben", dimension: 0),
    MikroIdee(text: "Probiere eine Woche lang, 30 Minuten früher ins Bett zu gehen", dimension: 0),
    MikroIdee(text: "Frag jemanden nach seinem besten Trick für fokussiertes Arbeiten", dimension: 1),
    MikroIdee(text: "Blockiere 25 Minuten für Deine wichtigste Aufgabe — Handy im Flugmodus", dimension: 1),
    MikroIdee(text: "Erkläre jemandem in zwei Sätzen, woran Du gerade arbeitest", dimension: 1),
    MikroIdee(text: "Nimm heute einen neuen Weg nach Hause", dimension: 2),
    MikroIdee(text: "Koche ein Rezept aus einem Land, in dem Du noch nie warst", dimension: 2),
    MikroIdee(text: "Skizziere Deine nächste Idee, statt sie aufzuschreiben", dimension: 2),
    MikroIdee(text: "Melde Dich bei jemandem, mit dem Du lange nicht gesprochen hast", dimension: 3),
    MikroIdee(text: "Plane ein Treffen ganz ohne Handy — nur Gespräch", dimension: 3),
    MikroIdee(text: "Mach jemandem heute ein ehrliches, konkretes Kompliment", dimension: 3),
    MikroIdee(text: "Räume 10 Minuten die eine Schublade auf, die Dich nervt", dimension: 4),
    MikroIdee(text: "Notiere eine Woche lang jede Ausgabe — nur beobachten, nicht werten", dimension: 4),
    MikroIdee(text: "Richte Dir eine kleine Ecke ein, in der Du gerne arbeitest", dimension: 4),
]

// MARK: - Quick-Capture Sheet

struct QuickIdeaView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \LebensbereichModel.sort) private var lebensbereiche: [LebensbereichModel]

    @State private var ideeText = ""
    @State private var gewählteDimension: LebensbereichModel?
    @State private var inspiration: MikroIdee?
    @State private var gespeichert = false
    @State private var botschaft = ""
    @FocusState private var textFokus: Bool

    private var kannSpeichern: Bool {
        !ideeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && gewählteDimension != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if gespeichert {
                    erfolgsAnsicht
                } else {
                    eingabeAnsicht
                }
            }
            .navigationTitle("Neue Idee")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !gespeichert {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") { dismiss() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button("Festhalten") { speichern() }
                            .fontWeight(.semibold)
                            .disabled(!kannSpeichern)
                    }
                }
            }
        }
        .sensoryFeedback(.success, trigger: gespeichert)
    }

    // MARK: Eingabe

    private var eingabeAnsicht: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Ideen-Kärtchen
                VStack(alignment: .leading, spacing: 10) {
                    Text("EIN SATZ GENÜGT")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .kerning(0.5)

                    TextField(
                        "Was willst Du ausprobieren?",
                        text: $ideeText,
                        axis: .vertical
                    )
                    .font(.title3)
                    .lineLimit(2...5)
                    .focused($textFokus)
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(.systemBackground))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        (gewählteDimension?.viewFarbe ?? .blue).opacity(textFokus ? 0.5 : 0.15),
                                        lineWidth: 1.5
                                    )
                            }
                    }
                }

                // Dimension wählen
                VStack(alignment: .leading, spacing: 10) {
                    Text("DIMENSION")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .kerning(0.5)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(lebensbereiche.filter { $0.istAktiv }) { bereich in
                                DimensionChip(
                                    bereich: bereich,
                                    istGewählt: gewählteDimension?.id == bereich.id
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        gewählteDimension = bereich
                                    }
                                }
                            }
                        }
                    }
                }

                // Inspirations-Pool
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("KEINE IDEE?")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .kerning(0.5)
                        Spacer()
                        Button {
                            withAnimation(.spring(response: 0.35)) {
                                inspiration = MikroIdeen.filter { $0.text != inspiration?.text }.randomElement()
                            }
                        } label: {
                            Label(
                                inspiration == nil ? "Inspiration holen" : "Nächste",
                                systemImage: "sparkles"
                            )
                            .font(.caption.bold())
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                        .tint(.orange)
                    }

                    if let inspiration {
                        let dimension = lebensbereiche.first { $0.sort == inspiration.dimension }
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                ideeText = inspiration.text
                                gewählteDimension = dimension
                            }
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: dimension?.icon ?? "sparkles")
                                    .font(.subheadline)
                                    .foregroundStyle(dimension?.viewFarbe ?? .orange)
                                    .padding(.top, 2)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(inspiration.text)
                                        .font(.subheadline)
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.leading)
                                    Text("Tippen zum Übernehmen")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                            .padding(14)
                            .background {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill((dimension?.viewFarbe ?? .orange).opacity(0.08))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke((dimension?.viewFarbe ?? .orange).opacity(0.25), lineWidth: 1)
                                    }
                            }
                        }
                        .buttonStyle(.plain)
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                textFokus = true
            }
        }
    }

    // MARK: Erfolg

    private var erfolgsAnsicht: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.green)
                .transition(.scale.combined(with: .opacity))

            Text("Idee festgehalten!")
                .font(.title3.bold())

            Text(botschaft)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    // MARK: Aktionen

    private func speichern() {
        guard let dimension = gewählteDimension else { return }
        let vorhaben = VorhabenModel(
            bezeichnung: ideeText.trimmingCharacters(in: .whitespacesAndNewlines),
            phase: 0,
            priority: 2,
            lebensbereich: dimension.sort,
            lebensbereichRef: dimension
        )
        modelContext.insert(vorhaben)
        addStandardAufgaben(vorhaben: vorhaben)

        botschaft = EntdeckerBotschaften.randomElement() ?? ""
        withAnimation(.spring(response: 0.4)) { gespeichert = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            dismiss()
        }
    }
}

// MARK: - Dimension-Chip

private struct DimensionChip: View {
    let bereich: LebensbereichModel
    let istGewählt: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: bereich.icon)
                    .font(.caption)
                Text(bereich.name)
                    .font(.subheadline)
                    .fontWeight(istGewählt ? .semibold : .regular)
            }
            .foregroundStyle(istGewählt ? .white : bereich.viewFarbe)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background {
                Capsule()
                    .fill(istGewählt ? bereich.viewFarbe : bereich.viewFarbe.opacity(0.12))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: VorhabenModel.self, LebensbereichModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    setupStandardLebensbereiche(context: container.mainContext)
    return QuickIdeaView()
        .modelContainer(container)
}
