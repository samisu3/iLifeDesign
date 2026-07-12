//
//  CompactVorhabenCard.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//

import SwiftUI
import SwiftData

struct CompactVorhabenCard: View {
    let vorhaben: VorhabenModel
    let showPhase: Bool // true für LebensbereicheView, false für PhasenListeView
    /// Optionale Phasenfarbe – direkt aus PhaseModel übergeben, damit sie mit dem PhaseEditor übereinstimmt.
    /// Wird nicht übergeben, fällt der View auf vorhaben.viewColor (hardcodiertes Dictionary) zurück.
    var phaseColor: Color? = nil

    private var displayColor: Color { phaseColor ?? vorhaben.viewColor }

    var body: some View {
        HStack(spacing: 8) {
            // Kleines Vorhaben Icon
            Image(systemName: vorhaben.viewIcon.isEmpty ? "target" : vorhaben.viewIcon)
                .font(.caption)
                .foregroundStyle(displayColor)
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(vorhaben.bezeichnung)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer()

                    // Kompakte Prioritäts-Sterne
                    HStack(spacing: 0) {
                        ForEach(0...4, id: \.self) { star in
                            Image(systemName: star <= vorhaben.priority ? "star.fill" : "star")
                                .font(.system(size: 8))
                                .foregroundStyle(star <= vorhaben.priority ? .orange : Color(.systemGray5))
                        }
                    }
                }

                HStack {
                    // Phase oder Lebensbereich je nach View
                    if showPhase {
                        HStack(spacing: 2) {
                            Image(systemName: vorhaben.viewPhaseIcon)
                                .font(.system(size: 8))
                                .foregroundStyle(displayColor)
                            Text(vorhaben.viewPhase)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    } else {
                        HStack(spacing: 2) {
                            Image(systemName: vorhaben.viewLebensbereichIcon)
                                .font(.system(size: 8))
                                .foregroundStyle(vorhaben.viewLebensbereichFarbe)
                            Text(vorhaben.viewLebensbereich)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Fortschritt-Zähler
                    if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                        Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(.systemGray6).opacity(0.3))
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)
    
    let vorhaben = VorhabenModel(bezeichnung: "Test Vorhaben", icon: 23, phase: 2, priority: 3, beschreibung: "Test", lebensbereich: 1)
    container.mainContext.insert(vorhaben)
    
    return NavigationStack {
        VStack(spacing: 10) {
            VorhabenZeile(vorhaben: vorhaben, showPhase: true)
            VorhabenZeile(vorhaben: vorhaben, showPhase: false)
        }
        .padding()
    }
    .modelContainer(container)
}

// MARK: - VorhabenZeile
// Zeile mit zwei Tap-Bereichen: links → VorhabenEditor, rechts → AufgabenListeView

struct VorhabenZeile: View {
    @Bindable var vorhaben: VorhabenModel
    let showPhase: Bool
    var phaseColor: Color? = nil

    @State private var zeigeAufgaben = false

    private var displayColor: Color { phaseColor ?? vorhaben.viewColor }
    private var phaseFertig: Bool { vorhaben.viewAktuelleAufgabenErledigt }

    var body: some View {
        HStack(spacing: 0) {

            // ── Linke Seite: Navigation zum Editor ──────────────────────
            NavigationLink {
                VorhabenEditor(vorhaben: vorhaben)
            } label: {
                CompactVorhabenCard(vorhaben: vorhaben, showPhase: showPhase, phaseColor: phaseColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            // ── Rechte Seite: Direkt zur nächsten Aktion ─────────────────
            if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                Button {
                    zeigeAufgaben = true
                } label: {
                    Image(systemName: phaseFertig ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(phaseFertig ? .green : displayColor)
                        .padding(.leading, 8)
                        .padding(.trailing, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .fullScreenCover(isPresented: $zeigeAufgaben) {
            AufgabenListeView(vorhaben: vorhaben)
        }
    }
}