//
//  VorhabenView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//

import SwiftUI
import SwiftData

struct VorhabenView2: View {
    let Vorhaben: VorhabenModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon mit farbigem Hintergrund
            ZStack {
                Circle()
                    .fill(Vorhaben.viewColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: Vorhaben.viewIcon)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Vorhaben.viewColor)
            }
            
            // Hauptinhalt
            VStack(alignment: .leading, spacing: 6) {
                // Titel mit Priorität
                HStack {
                    Text(Vorhaben.bezeichnung)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    // Prioritäts-Indikator
                    if Vorhaben.priority > 2 {
                        HStack(spacing: 2) {
                            ForEach(0..<min(Vorhaben.priority + 1, 3), id: \.self) { _ in
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 4, height: 4)
                            }
                        }
                    }
                }
                
                // Phase mit Progress
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: Vorhaben.viewPhaseIcon)
                            .font(.caption)
                            .foregroundStyle(Vorhaben.viewColor)
                        
                        Text(Vorhaben.viewPhase)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Vorhaben.viewColor)
                    }
                    
                    Spacer()
                    
                    // Progress Badge
                    Text("\(Vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(Vorhaben.viewAktuelleAufgabenAnzahl)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background {
                            Capsule()
                                .fill(Vorhaben.viewColor)
                        }
                }
                
                // Lebensbereich
                HStack {
                    Circle()
                        .fill(LebensbereicheColor[Vorhaben.lebensbereich] ?? .gray)
                        .frame(width: 8, height: 8)
                    
                    Text(Vorhaben.viewLebensbereich)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Vervollständigung
                    if Vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                        let progress = Double(Vorhaben.viewAktuelleAufgabenAnzahlErledigt) / Double(Vorhaben.viewAktuelleAufgabenAnzahl)
                        
                        HStack(spacing: 4) {
                            ProgressView(value: progress)
                                .frame(width: 40)
                                .tint(Vorhaben.viewColor)
                            
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
                        .stroke(Vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

#Preview {
    let container = VorhabenModel.preview
    let Vorhabens = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { Vorhaben in
            Vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    return VStack(spacing: 12) {
        VorhabenView(Vorhaben: Vorhabens[0])
        VorhabenView(Vorhaben: VorhabenModel.preview2)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
