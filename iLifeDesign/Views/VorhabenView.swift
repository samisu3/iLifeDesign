//
//  VorhabenView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.06.2024.
//

import SwiftUI
import SwiftData


struct VorhabenView: View {
    @Environment(\.horizontalSizeClass) var horSizeClass
    let vorhaben: VorhabenModel

    @State private var zeigeAufgaben = false

    /// Gesamtfortschritt: erledigte Aufgaben aller Phasen / alle Aufgaben
    private var gesamtFortschritt: Double {
        let alle = vorhaben.aufgaben?.count ?? 0
        guard alle > 0 else { return 0 }
        let erledigt = vorhaben.aufgaben?.filter { $0.erledigt }.count ?? 0
        return Double(erledigt) / Double(alle)
    }

    var body: some View {
        VStack(spacing: 12) {
            // Header mit Icon und Titel
            HStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(vorhaben.viewColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Circle()
                                .stroke(vorhaben.viewColor.opacity(0.3), lineWidth: 1.5)
                        }
                        .shadow(color: vorhaben.viewColor.opacity(0.2), radius: 6, x: 0, y: 3)

                    Image(systemName: vorhaben.viewIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(vorhaben.viewColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(vorhaben.bezeichnung)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .lineLimit(2)

                        Spacer(minLength: 0)

                        // Prioritäts-Indikator
                        if vorhaben.priority >= 0 {
                            HStack(spacing: 2) {
                                ForEach(0...4, id: \.self) { star in
                                    Image(systemName: star <= vorhaben.priority ? "star.fill" : "star")
                                        .font(.caption2)
                                        .foregroundStyle(star <= vorhaben.priority ? .orange : Color(.systemGray4))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background {
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay {
                                        Capsule()
                                            .stroke(.orange.opacity(0.3), lineWidth: 1)
                                    }
                            }
                        }
                    }

                    // Lebensbereich
                    HStack(spacing: 4) {
                        Image(systemName: vorhaben.viewLebensbereichIcon)
                            .font(.caption)
                            .foregroundStyle(LebensbereicheColor[vorhaben.lebensbereich] ?? .gray)
                        Text(vorhaben.viewLebensbereich)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Beschreibung
            if !vorhaben.beschreibung.isEmpty {
                Text(vorhaben.beschreibung)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }

            // ── Gesamtfortschritt: Phasen-Icons ────────────────────────
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Gesamtfortschritt")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Phase \(vorhaben.phase + 1) von 10 · \(Int(gesamtFortschritt * 100))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(vorhaben.viewColor)
                }

                HStack(spacing: 4) {
                    ForEach(0...9, id: \.self) { i in
                        let farbe = PhaseColor[i] ?? .gray
                        let icon  = VorhabenPhaseIcon[i] ?? "circle"
                        let fortschritt: Double = i < vorhaben.phase ? 1.0
                            : i == vorhaben.phase
                                ? (vorhaben.viewAktuelleAufgabenAnzahl > 0
                                    ? Double(vorhaben.viewAktuelleAufgabenAnzahlErledigt) / Double(vorhaben.viewAktuelleAufgabenAnzahl)
                                    : 0)
                            : 0

                        PhasenIconSegment(
                            icon: icon,
                            farbe: farbe,
                            istAktuell: i == vorhaben.phase,
                            fortschritt: fortschritt
                        )
                    }
                }
            }

            // Nächste Aktion Button
            if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                let fertig = vorhaben.viewAktuelleAufgabenErledigt
                let nächsteFrage = vorhaben.viewAktuellNächsteAufgabe

                Button {
                    zeigeAufgaben = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: fertig ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(fertig ? .green : .white)

                        if fertig {
                            Text("Phase abgeschlossen · Überarbeiten")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                        } else if let frage = nächsteFrage {
                            Text(frage.aufgabe)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        } else {
                            Text("Nächste Aktion")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }

                        Spacer(minLength: 0)

                        Image(systemName: "chevron.right")
                            .font(.caption2.bold())
                            .foregroundStyle(fertig ? .green.opacity(0.7) : .white.opacity(0.7))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(fertig ? .green.opacity(0.12) : vorhaben.viewColor)
                            .overlay {
                                if fertig {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(.green.opacity(0.4), lineWidth: 1)
                                }
                            }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(vorhaben.viewColor.opacity(0.3), lineWidth: 1)
                }
        }
        .shadow(color: vorhaben.viewColor.opacity(0.1), radius: 8, x: 0, y: 4)
        .fullScreenCover(isPresented: $zeigeAufgaben) {
            AufgabenListeView(vorhaben: vorhaben)
        }
    }
}

// MARK: - Phasen-Icon-Segment

private struct PhasenIconSegment: View {
    let icon: String
    let farbe: Color
    let istAktuell: Bool
    let fortschritt: Double // 0.0–1.0

    private let size: CGFloat = 28

    var body: some View {
        ZStack {
            // Hintergrundkreis
            Circle()
                .fill(fortschritt > 0
                      ? farbe.opacity(istAktuell ? 0.15 : 0.2)
                      : Color(.systemGray5).opacity(0.5))
                .frame(width: size, height: size)

            // Fortschritts-Bogen für aktuelle Phase
            if istAktuell && fortschritt > 0 {
                Circle()
                    .trim(from: 0, to: fortschritt)
                    .stroke(farbe, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: size - 1, height: size - 1)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.4), value: fortschritt)
            } else if fortschritt >= 1.0 {
                // Abgeschlossene Phase: vollständiger Ring
                Circle()
                    .stroke(farbe.opacity(0.5), lineWidth: 2)
                    .frame(width: size - 1, height: size - 1)
            }

            // Icon
            Image(systemName: icon)
                .font(.system(size: 11, weight: istAktuell ? .semibold : .regular))
                .foregroundStyle(
                    fortschritt > 0
                        ? (istAktuell ? farbe : farbe.opacity(0.8))
                        : Color(.systemGray3)
                )
        }
        .frame(maxWidth: .infinity)
        // Aktuelle Phase leicht nach oben heben
        .scaleEffect(istAktuell ? 1.15 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: istAktuell)
    }
}

#Preview {
    let container = VorhabenModel.preview
    let Vorhabens = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { vorhaben in
            vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    return NavigationStack {
        VorhabenView(vorhaben: Vorhabens[0])
    }
}

