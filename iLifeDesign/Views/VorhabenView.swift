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
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon mit farbigem Hintergrund
            ZStack {
                Circle()
                    .fill(vorhaben.viewColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: vorhaben.viewIcon)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(vorhaben.viewColor)
            }
            
            // Hauptinhalt
            VStack(alignment: .leading, spacing: 6) {
                // Titel mit Priorität
                HStack {
                    Text(vorhaben.bezeichnung)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Prioritäts-Indikator (5-Sterne-System)
                    if vorhaben.priority >= 0 {
                        HStack(spacing: 1) {
                            ForEach(0...4, id: \.self) { star in
                                Image(systemName: star <= vorhaben.priority ? "star.fill" : "star")
                                    .font(.caption2)
                                    .foregroundStyle(star <= vorhaben.priority ? .orange : Color(.systemGray4))
                            }
                        }
                    }
                }
                
                // Phase mit Progress
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: vorhaben.viewPhaseIcon)
                            .font(.caption)
                            .foregroundStyle(vorhaben.viewColor)
                        
                        Text(vorhaben.viewPhase)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(vorhaben.viewColor)
                    }
                    
                    Spacer()
                    
                    // Progress Badge
                    Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background {
                            Capsule()
                                .fill(vorhaben.viewColor)
                        }
                }
                
                // Lebensbereich
                HStack {
                    Image(systemName: vorhaben.viewLebensbereichIcon)
                        .font(.caption2)
                        .foregroundStyle(LebensbereicheColor[vorhaben.lebensbereich] ?? .gray)
                    
                    Text(vorhaben.viewLebensbereich)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Vervollständigung
                    if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                        let progress = Double(vorhaben.viewAktuelleAufgabenAnzahlErledigt) / Double(vorhaben.viewAktuelleAufgabenAnzahl)
                        
                        HStack(spacing: 4) {
                            ProgressView(value: progress)
                                .frame(width: 40)
                                .tint(vorhaben.viewColor)
                            
                            Text("\(Int(progress * 100))%")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 28, alignment: .trailing)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                }
        }
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

