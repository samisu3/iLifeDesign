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
    let showPhase: Bool
    var phaseColor: Color? = nil
    /// Callback wenn der Aktions-Button gedrückt wird
    var onAktion: (() -> Void)? = nil

    private var displayColor: Color { phaseColor ?? vorhaben.viewColor }
    private var phaseFertig: Bool { vorhaben.viewAktuelleAufgabenErledigt }
    private var nächsteAufgabe: AufgabeModel? { vorhaben.viewAktuellNächsteAufgabe }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // ── Obere Zeile: Icon + Titel + Sterne ──────────────────────
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(displayColor.opacity(0.15))
                        .frame(width: 30, height: 30)
                    Image(systemName: vorhaben.viewIcon.isEmpty ? "target" : vorhaben.viewIcon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(displayColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(vorhaben.bezeichnung)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Spacer()

                        HStack(spacing: 1) {
                            ForEach(0...4, id: \.self) { star in
                                Image(systemName: star <= vorhaben.priority ? "star.fill" : "star")
                                    .font(.system(size: 9))
                                    .foregroundStyle(star <= vorhaben.priority ? .orange : Color(.systemGray5))
                            }
                        }
                    }

                    HStack {
                        if showPhase {
                            HStack(spacing: 3) {
                                Image(systemName: vorhaben.viewPhaseIcon)
                                    .font(.system(size: 9))
                                    .foregroundStyle(displayColor)
                                Text(vorhaben.viewPhase)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        } else {
                            HStack(spacing: 3) {
                                Image(systemName: vorhaben.viewLebensbereichIcon)
                                    .font(.system(size: 9))
                                    .foregroundStyle(vorhaben.viewLebensbereichFarbe)
                                Text(vorhaben.viewLebensbereich)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                            Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // ── Aktions-Button ───────────────────────────────────────────
            if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                Button {
                    onAktion?()
                } label: {
                    HStack(spacing: 8) {
                        if phaseFertig {
                            Text("Phase abgeschlossen · Überarbeiten")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                        } else if let aufgabe = nächsteAufgabe {
                            Text(aufgabe.aufgabe)
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

                        Image(systemName: phaseFertig ? "checkmark.circle.fill" : "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(phaseFertig ? .green.opacity(0.7) : .white.opacity(0.7))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(phaseFertig ? .green.opacity(0.12) : displayColor)
                            .overlay {
                                if phaseFertig {
                                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                                        .stroke(.green.opacity(0.4), lineWidth: 1)
                                }
                            }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(.systemGray6).opacity(0.5))
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
// Zeile mit zwei Tap-Bereichen: links → VorhabenEditor, Aktions-Button → AufgabenListeView

struct VorhabenZeile: View {
    @Bindable var vorhaben: VorhabenModel
    let showPhase: Bool
    var phaseColor: Color? = nil

    @State private var zeigeAufgaben = false

    var body: some View {
        NavigationLink {
            VorhabenEditor(vorhaben: vorhaben)
        } label: {
            CompactVorhabenCard(
                vorhaben: vorhaben,
                showPhase: showPhase,
                phaseColor: phaseColor,
                onAktion: { zeigeAufgaben = true }
            )
        }
        .buttonStyle(.plain)
        // fullScreenCover ausserhalb des NavigationLink-Kontexts —
        // sonst ist der onAppear-Timing in AufgabenListeView gestört
        .background {
            Color.clear
                .fullScreenCover(isPresented: $zeigeAufgaben) {
                    AufgabenListeView(vorhaben: vorhaben)
                }
        }
    }
}
