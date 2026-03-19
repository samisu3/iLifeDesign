//
//  AufgabenListeView.swift
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//

import SwiftUI
import SwiftData

struct AufgabenListeView: View {
    @Bindable var vorhaben: VorhabenModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    headerSection
                    
                    if vorhaben.viewAktuelleAufgaben.isEmpty {
                        emptyStateView
                    } else {
                        aufgabenSection
                    }
                    
                    progressSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
            .navigationTitle(vorhaben.viewPhase)
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
                        vorhaben.viewColor.opacity(0.03),
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
                Image(systemName: vorhaben.viewPhaseIcon)
                    .font(.title2)
                    .foregroundStyle(vorhaben.viewColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vorhaben.bezeichnung)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(vorhaben.viewPhaseInfo)
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
                    
                    Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(vorhaben.viewColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                            Rectangle()
                                .fill(vorhaben.viewColor)
                                .frame(
                                    width: geometry.size.width * (Double(vorhaben.viewAktuelleAufgabenAnzahlErledigt) / Double(vorhaben.viewAktuelleAufgabenAnzahl)),
                                    height: 6
                                )
                                .cornerRadius(3)
                                .animation(.easeInOut(duration: 0.5), value: vorhaben.viewAktuelleAufgabenAnzahlErledigt)
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
                        .stroke(vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                }
        }
    }
    
    // MARK: - Aufgaben Section
    private var aufgabenSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(vorhaben.viewAktuelleAufgaben, id: \.self) { aufgabe in
                AufgabenCard(aufgabe: aufgabe, phaseColor: vorhaben.viewColor)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(vorhaben.viewColor)
            
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
            
            if vorhaben.viewAktuelleAufgabenErledigt && vorhaben.phase < 9 {
                Button {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        vorhaben.phase += 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Zur nächsten Phase")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("Phase \(vorhaben.phase + 2): \(VorhabenPhase[vorhaben.phase + 1] ?? "")")
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
                            .fill(vorhaben.viewColor)
                    }
                }
                .buttonStyle(.plain)
            } else if vorhaben.viewAktuelleAufgabenErledigt {
                VStack(spacing: 12) {
                    Image(systemName: "party.popper.fill")
                        .font(.title2)
                        .foregroundStyle(vorhaben.viewColor)
                    
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
                        .fill(vorhaben.viewColor.opacity(0.1))
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
    
    // Funktion um zur nächsten Aufgabe zu springen
    private func moveToNextTask() {
        // Aktuelle Aufgabe als erledigt markieren
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            aufgabe.erledigt = true
        }
        
        // Hier könnte zusätzliche Logik für das Springen zur nächsten Aufgabe hinzugefügt werden
        // z.B. ScrollView zur nächsten Aufgabe, Focus Management, etc.
    }
    
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
                    // Aufgaben-Titel (nur anzeigen, nicht änderbar)
                    Text(aufgabe.aufgabe.isEmpty ? "Aufgabe ohne Titel" : aufgabe.aufgabe)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(aufgabe.erledigt ? .secondary : .primary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            // Antwort-Textfeld (immer editierbar)
            HStack(spacing: 8) {
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
                
                // Button für "Zur nächsten Aufgabe" (nur wenn nicht erledigt)
                if !aufgabe.erledigt {
                    Button {
                        moveToNextTask()
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                            .foregroundStyle(phaseColor)
                    }
                    .buttonStyle(.plain)
                    .opacity(!aufgabe.antwort.isEmpty ? 1.0 : 0.3)
                    .disabled(aufgabe.antwort.isEmpty)
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
    
    do {
        let container = try ModelContainer(for: VorhabenModel.self, configurations: config)
        let vorhaben = VorhabenModel.preview2
        addStandardAufgaben(vorhaben: vorhaben)
        container.mainContext.insert(vorhaben)
        
        return AufgabenListeView(vorhaben: vorhaben)
            .modelContainer(container)
    } catch {
        return Text("Preview nicht verfügbar: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}
