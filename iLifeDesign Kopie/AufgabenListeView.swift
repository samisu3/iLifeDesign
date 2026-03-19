//
//  AufgabenListeView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//

import SwiftUI
import SwiftData

struct AufgabenListeView: View {
    @Bindable var Vorhaben: VorhabenModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    headerSection
                    
                    if Vorhaben.viewAktuelleAufgaben.isEmpty {
                        emptyStateView
                    } else {
                        aufgabenSection
                    }
                    
                    progressSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .navigationTitle(Vorhaben.viewPhase)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .background {
                LinearGradient(
                    colors: [
                        Vorhaben.viewColor.opacity(0.03),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: Vorhaben.viewPhaseIcon)
                    .font(.title2)
                    .foregroundStyle(Vorhaben.viewColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(Vorhaben.bezeichnung)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(Vorhaben.viewPhaseInfo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Fortschritt")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(Vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(Vorhaben.viewAktuelleAufgabenAnzahl)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Vorhaben.viewColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        if Vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                            Rectangle()
                                .fill(Vorhaben.viewColor)
                                .frame(
                                    width: geometry.size.width * (Double(Vorhaben.viewAktuelleAufgabenAnzahlErledigt) / Double(Vorhaben.viewAktuelleAufgabenAnzahl)),
                                    height: 6
                                )
                                .cornerRadius(3)
                                .animation(.easeInOut(duration: 0.5), value: Vorhaben.viewAktuelleAufgabenAnzahlErledigt)
                        }
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                }
        }
    }
    
    // MARK: - Aufgaben Section
    private var aufgabenSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(Vorhaben.viewAktuelleAufgaben, id: \.self) { aufgabe in
                AufgabenCard(aufgabe: aufgabe, phaseColor: Vorhaben.viewColor)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Vorhaben.viewColor)
            
            Text("Alle Aufgaben erledigt!")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Text("Sie haben alle Aufgaben für diese Phase abgeschlossen. Zeit für den nächsten Schritt!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nächste Schritte")
                .font(.headline)
                .fontWeight(.semibold)
            
            if Vorhaben.viewAktuelleAufgabenErledigt && Vorhaben.phase < 9 {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        Vorhaben.phase += 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Zur nächsten Phase")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Phase \(Vorhaben.phase + 2): \(VorhabenPhase[Vorhaben.phase + 1] ?? "")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Vorhaben.viewColor)
                    }
                }
                .buttonStyle(.plain)
            } else if Vorhaben.viewAktuelleAufgabenErledigt {
                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.title2)
                        .foregroundStyle(Vorhaben.viewColor)
                    
                    Text("Vorhaben abgeschlossen!")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("Herzlichen Glückwunsch! Sie haben Ihr Vorhaben erfolgreich durchgeführt.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Vorhaben.viewColor.opacity(0.1))
                }
            }
        }
        .padding(.bottom, 40)
    }
}

// MARK: - Aufgaben Card
struct AufgabenCard: View {
    @Bindable var aufgabe: AufgabeModel
    let phaseColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        aufgabe.erledigt.toggle()
                    }
                } label: {
                    Image(systemName: aufgabe.erledigt ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(aufgabe.erledigt ? phaseColor : Color(.systemGray3))
                }
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(aufgabe.aufgabe)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(aufgabe.erledigt ? .secondary : .primary)
                        .strikethrough(aufgabe.erledigt)
                    
                    if !aufgabe.antwort.isEmpty {
                        Text(aufgabe.antwort)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(.systemGray6))
                            }
                    }
                }
                
                Spacer()
            }
            
            // Antwort-Textfeld
            if !aufgabe.erledigt {
                TextField("Ihre Antwort oder Notizen...", text: $aufgabe.antwort, axis: .vertical)
                    .font(.caption)
                    .textFieldStyle(.plain)
                    .lineLimit(1...3)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(.systemGray6))
                    }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(aufgabe.erledigt ? Color(.systemGray6).opacity(0.5) : Color(.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(aufgabe.erledigt ? phaseColor.opacity(0.3) : Color(.systemGray4), lineWidth: 1)
                }
        }
        .animation(.easeInOut(duration: 0.3), value: aufgabe.erledigt)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)
    
    let Vorhaben = VorhabenModel.preview2
    addStandardAufgaben(Vorhaben: Vorhaben)
    container.mainContext.insert(Vorhaben)
    
    return AufgabenListeView(Vorhaben: Vorhaben)
        .modelContainer(container)
}
