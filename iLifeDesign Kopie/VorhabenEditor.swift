//
//  VorhabenEditor.swift  
//  iLifeDesign
//
//  Created by Assistant on 19.03.2026.
//

import SwiftUI
import SwiftData

struct VorhabenEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var vorhaben: VorhabenModel
    var isNew = false
    
    @State private var isPickingSymbol = false
    @State private var showDeleteAlert = false
    @FocusState private var titleFocused: Bool
    @State private var animateGradient = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    headerSection
                    iconAndTitleSection
                    phaseSelectionSection
                    detailsSection
                    nextStepsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle(isNew ? "Neues Ziel" : "Ziel bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        if isNew {
                            modelContext.delete(Vorhaben)
                        }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Speichern") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(Vorhaben.bezeichnung.isEmpty)
                }
            }
            .background {
                LinearGradient(
                    colors: [
                        Vorhaben.viewColor.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .animation(.easeInOut(duration: 0.6), value: Vorhaben.phase)
            }
        }
        .sheet(isPresented: $isPickingSymbol) {
            ModernSymbolPickerView(Vorhaben: Vorhaben)
        }
        .alert("Vorhaben löschen", isPresented: $showDeleteAlert) {
            Button("Löschen", role: .destructive) {
                modelContext.delete(Vorhaben)
                dismiss()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Dieses Vorhaben wird unwiderruflich gelöscht.")
        }
    }
    
    // MARK: - Header Section with Compact Phase Progress
    private var headerSection: some View {
        VStack(spacing: 12) {
            // Compact Phase Display (similar to VorhabenView)
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
                
                // Compact Progress Badge
                Text("\(Vorhaben.phase + 1)/10")
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
            
            // Phase Info Text (smaller and more compact)
            Text(Vorhaben.viewPhaseInfo)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
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
    
    // MARK: - Icon and Title Section
    private var iconAndTitleSection: some View {
        VStack(spacing: 16) {
            // Icon Selector
            Button {
                isPickingSymbol = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Vorhaben.viewColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: Vorhaben.viewIcon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(Vorhaben.viewColor)
                }
            }
            .buttonStyle(.plain)
            .scaleEffect(isPickingSymbol ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPickingSymbol)
            
            // Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Titel")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                TextField("Was möchten Sie erreichen?", text: $Vorhaben.bezeichnung, axis: .vertical)
                    .font(.title3)
                    .fontWeight(.medium)
                    .textFieldStyle(.plain)
                    .focused($titleFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(titleFocused ? Vorhaben.viewColor : .clear, lineWidth: 2)
                            }
                    }
                    .onAppear {
                        if isNew {
                            titleFocused = true
                        }
                    }
            }
        }
    }
    
    // MARK: - Compact Phase Selection with Dropdown
    private var phaseSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aktuelle Phase")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Menu {
                ForEach(0...9, id: \.self) { phase in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            Vorhaben.phase = phase
                        }
                    } label: {
                        HStack {
                            Image(systemName: VorhabenPhaseIcon[phase] ?? "circle")
                                .foregroundStyle(PhaseColor[phase] ?? .gray)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(VorhabenPhase[phase] ?? "Phase \(phase + 1)")
                                    .fontWeight(.medium)
                                
                                Text("Phase \(phase + 1) von 10")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if Vorhaben.phase == phase {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Vorhaben.viewColor)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    // Phase Icon with colored background
                    ZStack {
                        Circle()
                            .fill(Vorhaben.viewColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: Vorhaben.viewPhaseIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Vorhaben.viewColor)
                    }
                    
                    // Phase Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Vorhaben.viewPhase)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        Text("Phase \(Vorhaben.phase + 1) von 10")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    // Dropdown indicator
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                        }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Priority
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Priorität")
                        .font(.headline)
                    Spacer()
                    Text("\(Vorhaben.priority + 1)/7")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                PrioritySlider(priority: $Vorhaben.priority)
            }
            
            Divider()
            
            // Lebensbereich
            VStack(alignment: .leading, spacing: 12) {
                Text("Lebensbereich")
                    .font(.headline)
                
                Menu {
                    ForEach(0...8, id: \.self) { bereich in
                        Button {
                            Vorhaben.lebensbereich = bereich
                        } label: {
                            HStack {
                                Text(Lebensbereiche[bereich] ?? "")
                                if Vorhaben.lebensbereich == bereich {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(LebensbereicheColor[Vorhaben.lebensbereich] ?? .gray)
                            .frame(width: 12, height: 12)
                        
                        Text(Vorhaben.viewLebensbereich)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    }
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Beschreibung")
                    .font(.headline)
                
                TextField("Beschreiben Sie Ihr Ziel genauer...", text: $Vorhaben.beschreibung, axis: .vertical)
                    .font(.body)
                    .textFieldStyle(.plain)
                    .lineLimit(3...8)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(.systemGray6))
                    }
            }
        }
    }
    
    // MARK: - Next Steps Section
    private var nextStepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nächste Schritte")
                .font(.headline)
            
            NavigationLink {
                AufgabenListeView(Vorhaben: Vorhaben)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Aufgaben für \(Vorhaben.viewPhase)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        HStack {
                            Text("\(Vorhaben.viewAktuelleAufgabenAnzahlErledigt) von \(Vorhaben.viewAktuelleAufgabenAnzahl) erledigt")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            if Vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                                ProgressView(value: Double(Vorhaben.viewAktuelleAufgabenAnzahlErledigt), total: Double(Vorhaben.viewAktuelleAufgabenAnzahl))
                                    .frame(width: 60)
                                    .tint(Vorhaben.viewColor)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
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
            .buttonStyle(.plain)
            
            // Delete Button (nur wenn nicht neu)
            if !isNew {
                Button {
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Vorhaben löschen")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.red.opacity(0.1))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 40) // Extra spacing at bottom
    }
}

// MARK: - Supporting Views



struct PrioritySlider: View {
    @Binding var priority: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(0...6, id: \.self) { level in
                    Circle()
                        .fill(level <= priority ? .orange : Color(.systemGray5))
                        .frame(width: 8, height: 8)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                priority = level
                            }
                        }
                    
                    if level < 6 {
                        Rectangle()
                            .fill(level < priority ? .orange : Color(.systemGray5))
                            .frame(height: 2)
                    }
                }
            }
            
            HStack {
                Text("Niedrig")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Hoch")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}



#Preview("Neu") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)
    let newVorhaben = VorhabenModel()
    container.mainContext.insert(newVorhaben)
    
    return ModernVorhabenEditor(Vorhaben: newVorhaben, isNew: true)
        .modelContainer(container)
}

#Preview("Bearbeiten") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: VorhabenModel.self, configurations: config)
    let Vorhaben = VorhabenModel.preview2
    container.mainContext.insert(Vorhaben)
    
    return ModernVorhabenEditor(Vorhaben: Vorhaben)
        .modelContainer(container)
}