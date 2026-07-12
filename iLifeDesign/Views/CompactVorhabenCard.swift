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
                    
                    // Kompakter Progress
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
    
    return VStack(spacing: 10) {
        CompactVorhabenCard(vorhaben: vorhaben, showPhase: true)
        CompactVorhabenCard(vorhaben: vorhaben, showPhase: false)
    }
    .padding()
    .modelContainer(container)
}
