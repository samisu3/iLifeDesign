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
        VStack(spacing: 12) {
            // Header mit Icon und Titel
            HStack(spacing: 12) {
                // Animated Icon
                ZStack {
                    Circle()
                        .fill(vorhaben.viewColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                        .overlay {
                            Circle()
                                .stroke(vorhaben.viewColor.opacity(0.3), lineWidth: 2)
                        }
                        .shadow(color: vorhaben.viewColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: vorhaben.viewIcon)
                        .font(.title2)
                        .fontWeight(.semibold)
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
                            .shadow(color: .orange.opacity(0.2), radius: 4, x: 0, y: 2)
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
            
            // Phase und Progress
            HStack {
                // Phase Badge
                HStack(spacing: 4) {
                    Image(systemName: vorhaben.viewPhaseIcon)
                        .font(.caption)
                        .foregroundStyle(.white)
                    
                    Text(vorhaben.viewPhase)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    Capsule()
                        .fill(vorhaben.viewColor)
                        .shadow(color: vorhaben.viewColor.opacity(0.4), radius: 4, x: 0, y: 2)
                }
                
                Spacer()
                
                // Progress Badge
                Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(vorhaben.viewColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        Capsule()
                            .fill(vorhaben.viewColor.opacity(0.15))
                            .overlay {
                                Capsule()
                                    .stroke(vorhaben.viewColor.opacity(0.3), lineWidth: 1)
                            }
                    }
                    .shadow(color: vorhaben.viewColor.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            
            // Progress Bar
            if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                let progress = Double(vorhaben.viewAktuelleAufgabenAnzahlErledigt) / Double(vorhaben.viewAktuelleAufgabenAnzahl)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Fortschritt")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(progress * 100))%")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(vorhaben.viewColor)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [vorhaben.viewColor, vorhaben.viewColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: geometry.size.width * progress, height: 6)
                                .animation(.easeInOut(duration: 0.5), value: progress)
                        }
                    }
                    .frame(height: 6)
                }
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

