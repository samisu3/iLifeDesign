//
//  StatistikView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 12.07.2026.
//

import SwiftUI
import SwiftData

// MARK: - StatistikView

struct StatistikView: View {
    @Query private var alleVorhaben: [VorhabenModel]
    @Query(sort: \PhaseModel.sort) private var phasen: [PhaseModel]
    @Query(sort: \LebensbereichModel.sort) private var lebensbereiche: [LebensbereichModel]

    private var total: Int { alleVorhaben.count }

    /// Daten für das Netzdiagramm: pro aktiver Dimension die Selbsteinschätzung (1–10)
    /// und die Aktivität (Anzahl Vorhaben relativ zur aktivsten Dimension).
    private var radarAchsen: [RadarAchse] {
        let aktive = lebensbereiche.filter { $0.istAktiv }
        let anzahlen = aktive.map { bereich in
            alleVorhaben.filter { $0.lebensbereichRef?.id == bereich.id }.count
        }
        let maxAnzahl = max(anzahlen.max() ?? 0, 1)
        return zip(aktive, anzahlen).map { bereich, anzahl in
            RadarAchse(
                name: bereich.name,
                icon: bereich.icon,
                farbe: bereich.viewFarbe,
                einschaetzung: Double(bereich.einschaetzung) / 10.0,
                einschaetzungWert: bereich.einschaetzung,
                aktivitaet: Double(anzahl) / Double(maxAnzahl),
                anzahlVorhaben: anzahl
            )
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: 0. Balance-Check (Netzdiagramm)
                    if radarAchsen.count >= 3 {
                        StatistikKarte(titel: "Balance-Check", systemImage: "circle.hexagonpath") {
                            VStack(spacing: 14) {
                                RadarChartView(achsen: radarAchsen)
                                    .frame(height: 240)

                                // Legende
                                HStack(spacing: 16) {
                                    HStack(spacing: 5) {
                                        Circle()
                                            .fill(.blue.opacity(0.5))
                                            .frame(width: 8, height: 8)
                                        Text("Selbsteinschätzung")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    HStack(spacing: 5) {
                                        RoundedRectangle(cornerRadius: 1)
                                            .fill(.orange)
                                            .frame(width: 14, height: 2)
                                        Text("Aktive Vorhaben")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                // Werte pro Dimension
                                LazyVGrid(
                                    columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2),
                                    spacing: 8
                                ) {
                                    ForEach(radarAchsen) { achse in
                                        HStack(spacing: 5) {
                                            Image(systemName: achse.icon)
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundStyle(achse.farbe)
                                                .frame(width: 14)
                                            Text(achse.name)
                                                .font(.caption2)
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            Spacer(minLength: 2)
                                            Text("\(achse.einschaetzungWert)/10")
                                                .font(.caption2.bold())
                                                .foregroundStyle(achse.farbe)
                                                .monospacedDigit()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // MARK: 1. Prioritäten
                    StatistikKarte(titel: "Nach Priorität", systemImage: "star.fill") {
                        VStack(spacing: 10) {
                            ForEach((0...4).reversed(), id: \.self) { p in
                                let anzahl = alleVorhaben.filter { $0.priority == p }.count
                                PrioritätZeile(priorität: p, anzahl: anzahl, total: total)
                            }
                        }
                    }

                    // MARK: 2. Phasen
                    StatistikKarte(titel: "Nach Phase", systemImage: "infinity") {
                        VStack(spacing: 10) {
                            ForEach(phasen) { phase in
                                let anzahl = alleVorhaben.filter { $0.phase == phase.sort }.count
                                BalkenZeile(
                                    label: phase.name,
                                    icon: phase.icon,
                                    anzahl: anzahl,
                                    total: total,
                                    farbe: phase.viewFarbe
                                )
                            }
                        }
                    }

                    // MARK: 3. Lebensbereiche
                    StatistikKarte(titel: "Nach Lebensbereich", systemImage: "circle.hexagonpath") {
                        VStack(spacing: 10) {
                            ForEach(lebensbereiche) { bereich in
                                let anzahl = alleVorhaben.filter { $0.lebensbereichRef?.id == bereich.id }.count
                                BalkenZeile(
                                    label: bereich.name,
                                    icon: bereich.icon,
                                    anzahl: anzahl,
                                    total: total,
                                    farbe: bereich.viewFarbe
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Statistik")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Karten-Container

private struct StatistikKarte<Content: View>: View {
    let titel: String
    let systemImage: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(titel.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .kerning(0.5)
            }

            content()
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemBackground))
        }
    }
}

// MARK: - Prioritäts-Zeile (Sterne)

private struct PrioritätZeile: View {
    let priorität: Int
    let anzahl: Int
    let total: Int

    private var anteil: Double {
        guard total > 0 else { return 0 }
        return Double(anzahl) / Double(total)
    }

    var body: some View {
        HStack(spacing: 10) {
            // Sterne (priority 0–4, angezeigt als 1–5 Sterne)
            HStack(spacing: 2) {
                ForEach(0...4, id: \.self) { s in
                    Image(systemName: s <= priorität ? "star.fill" : "star")
                        .font(.system(size: 9))
                        .foregroundStyle(s <= priorität ? .orange : Color(.systemGray4))
                }
            }
            .frame(width: 68, alignment: .leading)

            // Balken
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(.orange.opacity(0.3 + 0.14 * Double(priorität + 1)))
                        .frame(width: geo.size.width * anteil, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: anteil)
                }
            }
            .frame(height: 8)

            // Zahl
            Text("\(anzahl)")
                .font(.caption.bold())
                .foregroundStyle(anzahl > 0 ? .primary : .secondary)
                .frame(width: 24, alignment: .trailing)
                .monospacedDigit()
        }
    }
}

// MARK: - Allgemeine Balken-Zeile (Phase / Lebensbereich)

private struct BalkenZeile: View {
    let label: String
    let icon: String
    let anzahl: Int
    let total: Int
    let farbe: Color

    private var anteil: Double {
        guard total > 0 else { return 0 }
        return Double(anzahl) / Double(total)
    }

    var body: some View {
        HStack(spacing: 10) {
            // Icon + Label
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(farbe)
                    .frame(width: 14)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .frame(width: 100, alignment: .leading)

            // Balken
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(farbe.opacity(0.75))
                        .frame(width: geo.size.width * anteil, height: 8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: anteil)
                }
            }
            .frame(height: 8)

            // Zahl
            Text("\(anzahl)")
                .font(.caption.bold())
                .foregroundStyle(anzahl > 0 ? farbe : .secondary)
                .frame(width: 24, alignment: .trailing)
                .monospacedDigit()
        }
    }
}

// MARK: - Balance-Check: Radar-Chart (Netzdiagramm)

private struct RadarAchse: Identifiable {
    var id: String { name }
    let name: String
    let icon: String
    let farbe: Color
    /// Selbsteinschätzung normiert auf 0…1
    let einschaetzung: Double
    /// Selbsteinschätzung als Originalwert 1–10
    let einschaetzungWert: Int
    /// Anzahl Vorhaben relativ zur aktivsten Dimension, 0…1
    let aktivitaet: Double
    let anzahlVorhaben: Int
}

private struct RadarChartView: View {
    let achsen: [RadarAchse]

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 - 26

            ZStack {
                // Gitter: Ringe bei 25 / 50 / 75 / 100 %
                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { stufe in
                    polygon(center: center, radius: radius) { _ in stufe }
                        .stroke(Color(.systemGray5), lineWidth: 1)
                }

                // Achsen-Linien vom Zentrum nach aussen
                ForEach(achsen.indices, id: \.self) { i in
                    Path { path in
                        path.move(to: center)
                        path.addLine(to: punkt(center: center, radius: radius, index: i, wert: 1.0))
                    }
                    .stroke(Color(.systemGray5), lineWidth: 1)
                }

                // Fläche: Selbsteinschätzung
                polygon(center: center, radius: radius) { achsen[$0].einschaetzung }
                    .fill(.blue.opacity(0.15))
                polygon(center: center, radius: radius) { achsen[$0].einschaetzung }
                    .stroke(.blue.opacity(0.7), lineWidth: 2)

                // Linie: wo aktuell am meisten experimentiert wird
                polygon(center: center, radius: radius) { achsen[$0].aktivitaet }
                    .stroke(.orange, style: StrokeStyle(lineWidth: 2, dash: [5, 4]))

                // Punkte auf der Selbsteinschätzung
                ForEach(achsen.indices, id: \.self) { i in
                    Circle()
                        .fill(.blue)
                        .frame(width: 6, height: 6)
                        .position(punkt(center: center, radius: radius, index: i, wert: achsen[i].einschaetzung))
                }

                // Icons der Dimensionen an den Achsen-Enden
                ForEach(achsen.indices, id: \.self) { i in
                    Image(systemName: achsen[i].icon)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(achsen[i].farbe)
                        .position(punkt(center: center, radius: radius + 17, index: i, wert: 1.0))
                }
            }
        }
    }

    /// Punkt auf der Achse `index` bei `wert` (0…1). Erste Achse zeigt nach oben.
    private func punkt(center: CGPoint, radius: CGFloat, index: Int, wert: Double) -> CGPoint {
        let winkel = -Double.pi / 2 + 2 * .pi * Double(index) / Double(achsen.count)
        return CGPoint(
            x: center.x + cos(winkel) * radius * wert,
            y: center.y + sin(winkel) * radius * wert
        )
    }

    private func polygon(center: CGPoint, radius: CGFloat, wert: (Int) -> Double) -> Path {
        Path { path in
            for i in achsen.indices {
                let p = punkt(center: center, radius: radius, index: i, wert: wert(i))
                if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
            }
            path.closeSubpath()
        }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: VorhabenModel.self, PhaseModel.self, LebensbereichModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    setupStandardPhasen(context: container.mainContext)
    setupStandardLebensbereiche(context: container.mainContext)

    let fetch = FetchDescriptor<LebensbereichModel>(sortBy: [SortDescriptor(\.sort)])
    let bereiche = (try? container.mainContext.fetch(fetch)) ?? []
    for (i, wert) in [7, 5, 8, 4, 6].enumerated() where i < bereiche.count {
        bereiche[i].einschaetzung = wert
    }

    let v1 = VorhabenModel(bezeichnung: "App bauen", icon: "iphone", phase: 2, priority: 4, lebensbereichRef: bereiche.count > 1 ? bereiche[1] : nil)
    let v2 = VorhabenModel(bezeichnung: "Sport", icon: "bicycle", phase: 0, priority: 3, lebensbereichRef: bereiche.first)
    let v3 = VorhabenModel(bezeichnung: "Lesen", icon: "book", phase: 4, priority: 4, lebensbereichRef: bereiche.count > 2 ? bereiche[2] : nil)
    let v4 = VorhabenModel(bezeichnung: "Kochen", icon: "birthday.cake", phase: 1, priority: 2, lebensbereichRef: bereiche.count > 2 ? bereiche[2] : nil)
    [v1, v2, v3, v4].forEach { container.mainContext.insert($0) }

    return StatistikView()
        .modelContainer(container)
}
