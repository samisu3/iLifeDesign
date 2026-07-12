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
            ZStack {
                // Dynamic Background
                DesignSystem.Colors.backgroundGradient(for: vorhaben.viewColor)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.lg) {
                        headerSection
                        
                        if vorhaben.viewAktuelleAufgaben.isEmpty {
                            emptyStateView
                        } else {
                            aufgabenSection
                        }
                        
                        progressSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.sm)
                }
            }
            .navigationTitle(vorhaben.viewPhase)
            .modernNavigation()
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .buttonStyle(ModernButtonStyle(color: vorhaben.viewColor, isProminent: true))
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Titel und Icon
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(vorhaben.viewColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Circle()
                                .stroke(vorhaben.viewColor.opacity(0.4), lineWidth: 2)
                        }
                        .shadow(color: vorhaben.viewColor.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: vorhaben.viewPhaseIcon)
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(vorhaben.viewColor)
                }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(vorhaben.bezeichnung)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(vorhaben.viewPhaseInfo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Enhanced Progress Bar
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text("Fortschritt")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(vorhaben.viewColor)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background {
                            Capsule()
                                .fill(vorhaben.viewColor.opacity(0.15))
                                .overlay {
                                    Capsule()
                                        .stroke(vorhaben.viewColor.opacity(0.3), lineWidth: 1)
                                }
                        }
                        .shadow(color: vorhaben.viewColor.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(LinearGradient(
                                    colors: [vorhaben.viewColor, vorhaben.viewColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(
                                    width: geometry.size.width * (Double(vorhaben.viewAktuelleAufgabenAnzahlErledigt) / Double(vorhaben.viewAktuelleAufgabenAnzahl)),
                                    height: 8
                                )
                                .animation(.easeInOut(duration: 0.5), value: vorhaben.viewAktuelleAufgabenAnzahlErledigt)
                        }
                    }
                    .shadow(color: vorhaben.viewColor.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .frame(height: 8)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .modernCard(color: vorhaben.viewColor, cornerRadius: DesignSystem.CornerRadius.xl)
        .shadow(color: vorhaben.viewColor.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Aufgaben Section
    private var aufgabenSection: some View {
        LazyVStack(spacing: DesignSystem.Spacing.md) {
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
    @State private var isHovered = false
    
    // Funktion um zur nächsten Aufgabe zu springen
    private func moveToNextTask() {
        // Kurze Verzögerung um Focus-Konflikte zu vermeiden
        Task { @MainActor in
            try await Task.sleep(nanoseconds: 50_000_000) // 50ms
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                aufgabe.erledigt = true
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Header mit Checkbox und Titel
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                // Animated Checkbox
                Button {
                    // Defensive Implementierung gegen Focus-Probleme
                    guard !aufgabe.erledigt else { return }
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        aufgabe.erledigt.toggle()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(aufgabe.erledigt ? phaseColor : Color(.systemGray5))
                            .frame(width: 28, height: 28)
                            .overlay {
                                Circle()
                                    .stroke(phaseColor.opacity(0.3), lineWidth: 2)
                            }
                            .shadow(color: phaseColor.opacity(aufgabe.erledigt ? 0.3 : 0.1), radius: 4, x: 0, y: 2)
                        
                        if aufgabe.erledigt {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(false) // Explizit aktiviert lassen
                
                // Task Content
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(aufgabe.aufgabe.isEmpty ? "Aufgabe ohne Titel" : aufgabe.aufgabe)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(aufgabe.erledigt ? .secondary : .primary)
                        .strikethrough(aufgabe.erledigt)
                        .multilineTextAlignment(.leading)
                        .animation(.easeInOut(duration: 0.3), value: aufgabe.erledigt)
                }
                
                Spacer()
                
                // Quick Action Button
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
                    .shadow(color: phaseColor.opacity(0.2), radius: 2, x: 0, y: 1)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: aufgabe.antwort.isEmpty)
                }
            }
            
            // Answer Field
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text("Ihre Antwort:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                TextField("Notizen und Gedanken...", text: $aufgabe.antwort, axis: .vertical)
                    .font(.subheadline)
                    .textFieldStyle(.plain)
                    .lineLimit(2...4)
                    .padding(DesignSystem.Spacing.md)
                    .background {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm, style: .continuous)
                                    .stroke(phaseColor.opacity(aufgabe.antwort.isEmpty ? 0.2 : 0.4), lineWidth: 1)
                            }
                            .shadow(color: phaseColor.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(aufgabe.erledigt ? 0.5 : 1.0)
                .overlay {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                        .stroke(
                            aufgabe.erledigt ? phaseColor.opacity(0.3) : phaseColor.opacity(0.2), 
                            lineWidth: aufgabe.erledigt ? 2 : 1
                        )
                }
        }
        .shadow(color: phaseColor.opacity(aufgabe.erledigt ? 0.2 : 0.1), radius: 6, x: 0, y: 3)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: aufgabe.erledigt)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
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
