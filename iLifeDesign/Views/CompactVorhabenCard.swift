//
//  CompactVorhabenCard.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//

import SwiftUI
import SwiftData

// MARK: - Nächste Aktion Button
// Gemeinsamer Button: zeigt die nächste offene Frage der aktuellen Phase
// oder den Abgeschlossen-Zustand. Wird in Karten und im Editor verwendet.

struct NächsteAktionButton: View {
    let vorhaben: VorhabenModel
    var farbe: Color? = nil
    var action: () -> Void

    private var displayColor: Color { farbe ?? vorhaben.viewColor }
    private var fertig: Bool { vorhaben.viewAktuelleAufgabenErledigt }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if fertig {
                    Text("Phase abgeschlossen · Überarbeiten")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                } else if let frage = vorhaben.viewAktuellNächsteAufgabe {
                    Text(frage.aufgabe)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(displayColor)
                        .lineLimit(1)
                } else {
                    Text("Nächste Aktion")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(displayColor)
                }

                Spacer(minLength: 0)

                Image(systemName: fertig ? "checkmark.circle.fill" : "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(fertig ? .green.opacity(0.7) : displayColor.opacity(0.7))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(fertig ? .green.opacity(0.12) : displayColor.opacity(0.12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(
                                fertig ? .green.opacity(0.3) : displayColor.opacity(0.25),
                                lineWidth: 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

struct CompactVorhabenCard: View {
    let vorhaben: VorhabenModel
    let showPhase: Bool
    var phaseColor: Color? = nil
    /// Callback wenn der Aktions-Button gedrückt wird
    var onAktion: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // ── Obere Zeile: Icon + Titel + Sterne ──────────────────────
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 40)
                    Image(systemName: vorhaben.viewIcon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color(.systemGray))
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(vorhaben.bezeichnung)
                            .font(.title3)
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
                                    .foregroundStyle(.secondary)
                                Text(vorhaben.viewPhase)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: vorhaben.viewLebensbereichIcon)
                                    .foregroundStyle(vorhaben.viewLebensbereichFarbe)
                                Text(vorhaben.viewLebensbereich)
                                    .fontWeight(.medium)
                                    .foregroundStyle(vorhaben.viewLebensbereichFarbe)
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
                NächsteAktionButton(vorhaben: vorhaben, farbe: phaseColor) {
                    onAktion?()
                }
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
    
    let vorhaben = VorhabenModel(bezeichnung: "Test Vorhaben", icon: "iphone", phase: 2, priority: 3, beschreibung: "Test", lebensbereich: 1)
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
