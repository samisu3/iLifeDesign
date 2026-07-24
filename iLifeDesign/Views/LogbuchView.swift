//
//  LogbuchView.swift
//  iLifeDesign
//
//  Das Expeditions-Logbuch: Alle abgeschlossenen Phasen als Sammelkarten
//  und eine sanfte Wochen-Serie (ein verpasster Tag zerstört nichts —
//  gezählt wird pro Woche).
//

import SwiftUI
import SwiftData

struct LogbuchView: View {
    @Query(sort: \PhaseReflexionModel.datum, order: .reverse)
    private var reflexionen: [PhaseReflexionModel]

    @Query(sort: \ErkenntnisModel.datum, order: .reverse)
    private var erkenntnisse: [ErkenntnisModel]

    /// Anzahl aufeinanderfolgender Kalenderwochen mit mindestens einem
    /// Phasenabschluss. Die laufende Woche ohne Aktivität unterbricht
    /// die Serie noch nicht (Verzeihen eingebaut).
    private var wochenSerie: Int {
        let kalender = Calendar.current
        let wochen = Set(reflexionen.compactMap {
            kalender.dateInterval(of: .weekOfYear, for: $0.datum)?.start
        })
        guard !wochen.isEmpty,
              var woche = kalender.dateInterval(of: .weekOfYear, for: .now)?.start
        else { return 0 }

        if !wochen.contains(woche) {
            guard let vorwoche = kalender.date(byAdding: .weekOfYear, value: -1, to: woche)
            else { return 0 }
            woche = vorwoche
        }

        var serie = 0
        while wochen.contains(woche) {
            serie += 1
            guard let vorherige = kalender.date(byAdding: .weekOfYear, value: -1, to: woche)
            else { break }
            woche = vorherige
        }
        return serie
    }

    private let spalten = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        NavigationStack {
            Group {
                if reflexionen.isEmpty && erkenntnisse.isEmpty {
                    ContentUnavailableView(
                        "Noch keine Trophäen",
                        systemImage: "trophy",
                        description: Text("Schliesse Deine erste Phase ab — jeder Abschluss landet hier als Sammelkarte.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            serienKarte

                            if !erkenntnisse.isEmpty {
                                erkenntnisseKarte
                            }

                            LazyVGrid(columns: spalten, spacing: 12) {
                                ForEach(reflexionen) { reflexion in
                                    TrophäenKarte(reflexion: reflexion)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Logbuch")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: Wochen-Serie

    private var serienKarte: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "flame.fill")
                    .font(.title3)
                    .foregroundStyle(wochenSerie > 0 ? .orange : .secondary)
            }

            VStack(alignment: .leading, spacing: 3) {
                if wochenSerie > 0 {
                    Text(wochenSerie == 1
                         ? "1 Woche auf Expedition"
                         : "\(wochenSerie) Wochen in Folge auf Expedition")
                        .font(.headline)
                } else {
                    Text("Bereit für eine neue Serie?")
                        .font(.headline)
                }
                Text("Gezählt wird pro Woche — ein Ruhetag zerstört nichts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Text("\(reflexionen.count)")
                .font(.title2.bold())
                .foregroundStyle(.orange)
                .monospacedDigit()
                + Text(" ✓")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        }
    }

    // MARK: Erkenntnisse

    private var erkenntnisseKarte: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.max.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.yellow)
                Text("DEINE ERKENNTNISSE")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .kerning(0.5)
                Spacer()
                Text("\(erkenntnisse.count)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }

            ForEach(erkenntnisse) { erkenntnis in
                ErkenntnisKarte(erkenntnis: erkenntnis)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        }
    }
}

// MARK: - Erkenntnis-Karte (auch im Quick-Capture verwendet)

struct ErkenntnisKarte: View {
    let erkenntnis: ErkenntnisModel

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(erkenntnis.viewFarbe.opacity(0.15))
                    .frame(width: 30, height: 30)
                Image(systemName: erkenntnis.icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(erkenntnis.viewFarbe)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(erkenntnis.text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text("\(erkenntnis.quelle) · \(erkenntnis.viewDatum)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(erkenntnis.viewFarbe.opacity(0.06))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(erkenntnis.viewFarbe.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

// MARK: - Trophäen-Karte (Sammelkarten-Optik)

private struct TrophäenKarte: View {
    let reflexion: PhaseReflexionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(reflexion.viewFarbe.opacity(0.18))
                        .frame(width: 34, height: 34)
                    Image(systemName: reflexion.phaseIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(reflexion.viewFarbe)
                }
                Spacer()
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundStyle(reflexion.viewFarbe.opacity(0.6))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(reflexion.vorhaben?.bezeichnung ?? "Vorhaben")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(reflexion.phaseName)
                    .font(.caption)
                    .foregroundStyle(reflexion.viewFarbe)
            }

            if !reflexion.antwort.isEmpty {
                Text(reflexion.antwort)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            Spacer(minLength: 0)

            Text(reflexion.viewDatum)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            reflexion.viewFarbe.opacity(0.10),
                            Color(.systemBackground)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(reflexion.viewFarbe.opacity(0.25), lineWidth: 1)
                }
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: VorhabenModel.self, PhaseReflexionModel.self, LebensbereichModel.self, PhaseModel.self, ErkenntnisModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let vorhaben = VorhabenModel(bezeichnung: "Neuer Heimweg", icon: "map", phase: 1)
    container.mainContext.insert(vorhaben)

    let erkenntnis = ErkenntnisModel(
        text: "Abends bin ich zu müde für Neues — morgens klappt es viel besser.",
        quelle: "Neuer Heimweg",
        icon: "sparkles",
        farbeID: "orange"
    )
    container.mainContext.insert(erkenntnis)

    let kalender = Calendar.current
    let r1 = PhaseReflexionModel(
        phase: 0, phaseName: "Der Kompass", phaseIcon: "safari", phaseFarbeID: "blue",
        frage: "Fokus-Satz", antwort: "Ich teste 2 Wochen lang neue Wege nach Hause.",
        datum: .now, vorhaben: vorhaben
    )
    let r2 = PhaseReflexionModel(
        phase: 1, phaseName: "Der Entwurf", phaseIcon: "lightbulb.max", phaseFarbeID: "yellow",
        frage: "Start-Termin", antwort: "Montag nach der Arbeit gehts los.",
        datum: kalender.date(byAdding: .weekOfYear, value: -1, to: .now)!, vorhaben: vorhaben
    )
    container.mainContext.insert(r1)
    container.mainContext.insert(r2)

    return LogbuchView()
        .modelContainer(container)
}
