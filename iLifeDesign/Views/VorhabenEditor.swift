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
    @State private var zeigeVerlauf = false
    
    @Query(sort: \LebensbereichModel.sort) private var lebensbereiche: [LebensbereichModel]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // headerSection
                    iconAndTitleSection
                    phaseSelectionSection
                    detailsSection
                    nextStepsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .navigationTitle(isNew ? "Neues Vorhaben" : "Vorhaben bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        if isNew {
                            modelContext.delete(vorhaben)
                        }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Speichern") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(vorhaben.bezeichnung.isEmpty)
                }
            }
            .background {
                LinearGradient(
                    colors: [
                        vorhaben.viewColor.opacity(0.05),
                        Color(.systemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .animation(.easeInOut(duration: 0.6), value: vorhaben.phase)
            }
        }
        .sheet(isPresented: $isPickingSymbol) {
            SymbolPickerView(vorhaben: vorhaben)
        }
        .alert("Vorhaben löschen", isPresented: $showDeleteAlert) {
            Button("Löschen", role: .destructive) {
                modelContext.delete(vorhaben)
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
                    Image(systemName: vorhaben.viewPhaseIcon)
                        .font(.caption)
                        .foregroundStyle(vorhaben.viewColor)
                    
                    Text(vorhaben.viewPhase)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(vorhaben.viewColor)
                }
                
                Spacer()
                
                // Compact Progress Badge
                Text("\(vorhaben.phase + 1)/10")
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
            
            // Phase Info Text (smaller and more compact)
            Text(vorhaben.viewPhaseInfo)
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
                        .stroke(vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                }
        }
    }
    
    // MARK: - Icon and Title Section
    private var iconAndTitleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Titel")
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 12) {
                // Kleineres Icon links
                Button {
                    isPickingSymbol = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(vorhaben.viewColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: vorhaben.viewIcon.isEmpty ? "target" : vorhaben.viewIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(vorhaben.viewColor)
                    }
                }
                .buttonStyle(.plain)
                .scaleEffect(isPickingSymbol ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPickingSymbol)
                
                // Title Input rechts daneben
                TextField("Was möchten Sie erreichen?", text: $vorhaben.bezeichnung, axis: .vertical)
                    .font(.title3)
                    .fontWeight(.medium)
                    .textFieldStyle(.plain)
                    .focused($titleFocused)
                    .onAppear {
                        if isNew {
                            titleFocused = true
                        }
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(titleFocused ? vorhaben.viewColor : .clear, lineWidth: 2)
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
                            vorhaben.phase = phase
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
                            
                            if vorhaben.phase == phase {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(vorhaben.viewColor)
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
                            .fill(vorhaben.viewColor.opacity(0.15))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: vorhaben.viewPhaseIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(vorhaben.viewColor)
                    }
                    
                    // Phase Info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(vorhaben.viewPhase)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        Text("Phase \(vorhaben.phase + 1) von 10")
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
                                .stroke(vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                        }
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Priority und Lebensbereich nebeneinander
            HStack(spacing: 16) {
                // Priority (links)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Priorität")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Text("\(vorhaben.priority + 1)/5")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    CompactStarPriorityView(priority: $vorhaben.priority)
                }
                .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(height: 50)
                
                // Lebensbereich (rechts)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lebensbereich")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Menu {
                        ForEach(lebensbereiche.filter { $0.istAktiv }) { bereich in
                            Button {
                                vorhaben.lebensbereichRef = bereich
                                vorhaben.lebensbereich = bereich.sort
                            } label: {
                                HStack {
                                    Image(systemName: bereich.icon)
                                        .foregroundStyle(bereich.viewFarbe)
                                    Text(bereich.name)
                                    if vorhaben.lebensbereichRef?.id == bereich.id {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(bereich.viewFarbe)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: vorhaben.viewLebensbereichIcon)
                                .font(.caption)
                                .foregroundStyle(vorhaben.viewLebensbereichFarbe)
                                .frame(width: 12)
                            
                            Text(vorhaben.viewLebensbereich.isEmpty ? "Wählen…" : vorhaben.viewLebensbereich)
                                .font(.caption)
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .foregroundStyle(vorhaben.viewLebensbereich.isEmpty ? .secondary : .primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(.systemGray6))
                        }
                    }
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            
            // Description (kompakter)
            VStack(alignment: .leading, spacing: 8) {
                Text("Beschreibung")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("Beschreiben Sie Ihr Ziel genauer...", text: $vorhaben.beschreibung, axis: .vertical)
                    .font(.caption)
                    .textFieldStyle(.plain)
                    .lineLimit(2...4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(.systemGray6))
                    }
            }
        }
    }
    
    // MARK: - Next Steps Section
    private var nextStepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nächste Aktion")
                .font(.headline)

            // Aktuelle Frage direkt anzeigen und anspringen
            let nächsteFrage = vorhaben.viewAktuellNächsteAufgabe

            NavigationLink {
                AufgabenListeView(vorhaben: vorhaben)
            } label: {
                VStack(alignment: .leading, spacing: 10) {
                    // Kopfzeile mit Phase und Fortschritt
                    HStack {
                        HStack(spacing: 5) {
                            Image(systemName: vorhaben.viewPhaseIcon)
                                .font(.caption2)
                            Text(vorhaben.viewPhase)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(vorhaben.viewColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background { Capsule().fill(vorhaben.viewColor.opacity(0.12)) }

                        Spacer()

                        Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(vorhaben.viewColor)
                    }

                    if let frage = nächsteFrage {
                        // Aktuelle Frage hervorheben
                        HStack(spacing: 10) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(vorhaben.viewColor)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(frage.aufgabe)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundStyle(vorhaben.viewColor)
                        }
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(vorhaben.viewColor.opacity(0.07))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(vorhaben.viewColor.opacity(0.2), lineWidth: 1)
                                }
                        }
                    } else {
                        // Alle Fragen beantwortet
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Phase abgeschlossen")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text("Alle Fragen beantwortet · Antworten überarbeiten")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(vorhaben.viewColor.opacity(0.25), lineWidth: 1)
                        }
                }
            }
            .buttonStyle(.plain)

            // MARK: Verlauf (ausklappbar)
            if !isNew {
                verlaufSection
            }

            // MARK: Löschen
            if !isNew {
                Button {
                    showDeleteAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Vorhaben löschen")
                    }
                    .font(.subheadline).foregroundStyle(.red)
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.red.opacity(0.1))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 40)
    }

    // MARK: - Verlauf Section

    private var verlaufSection: some View {
        let reflexionen = (vorhaben.reflexionen ?? [])
            .sorted { $0.datum > $1.datum } // neueste zuerst

        return VStack(alignment: .leading, spacing: 0) {
            // Header-Button zum Aufklappen
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    zeigeVerlauf.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        .font(.subheadline)
                        .foregroundStyle(vorhaben.viewColor)

                    Text("Verlauf")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("(\(reflexionen.count))")
                        .font(.caption).foregroundStyle(.secondary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.bold()).foregroundStyle(.secondary)
                        .rotationEffect(.degrees(zeigeVerlauf ? 0 : -90))
                }
                .padding(.horizontal, 16).padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            if zeigeVerlauf {
                Divider().padding(.horizontal, 12)

                if reflexionen.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("Noch kein Verlauf — Fragen beantworten und zur nächsten Phase wechseln.")
                            .font(.caption).foregroundStyle(.secondary).italic()
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                } else {
                    VStack(spacing: 10) {
                        ForEach(reflexionen) { reflexion in
                            VerlaufKarte(reflexion: reflexion)
                        }
                    }
                    .padding(.horizontal, 12).padding(.vertical, 10)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(vorhaben.viewColor.opacity(0.15), lineWidth: 1)
                }
        }
    }
}

// MARK: - Verlauf Karte

struct VerlaufKarte: View {
    let reflexion: PhaseReflexionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(reflexion.viewFarbe.opacity(0.15))
                        .frame(width: 28, height: 28)
                    Image(systemName: reflexion.phaseIcon)
                        .font(.caption2)
                        .foregroundStyle(reflexion.viewFarbe)
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(reflexion.phaseName)
                        .font(.caption).fontWeight(.semibold)
                        .foregroundStyle(reflexion.viewFarbe)
                    Text(reflexion.viewDatum)
                        .font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
            }

            Text(reflexion.frage)
                .font(.caption2).foregroundStyle(.secondary)
                .italic()

            if !reflexion.antwort.isEmpty {
                Text(reflexion.antwort)
                    .font(.caption).foregroundStyle(.primary)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(reflexion.viewFarbe.opacity(0.08))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(reflexion.viewFarbe.opacity(0.2), lineWidth: 1)
                            }
                    }
            } else {
                Text("(keine Antwort)")
                    .font(.caption2).foregroundStyle(.tertiary).italic()
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6).opacity(0.5))
        }
    }
}

// MARK: - Supporting Views



struct StarPriorityView: View {
    @Binding var priority: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0...4, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            priority = star
                        }
                    } label: {
                        Image(systemName: star <= priority ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(star <= priority ? .orange : Color(.systemGray4))
                    }
                    .buttonStyle(.plain)
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

struct CompactStarPriorityView: View {
    @Binding var priority: Int
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                ForEach(0...4, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            priority = star
                        }
                    } label: {
                        Image(systemName: star <= priority ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundStyle(star <= priority ? .orange : Color(.systemGray4))
                    }
                    .buttonStyle(.plain)
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
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container: ModelContainer = try ModelContainer(for: VorhabenModel.self, configurations: config)
        let newVorhaben = VorhabenModel()
        container.mainContext.insert(newVorhaben)
        
        return VorhabenEditor(vorhaben: newVorhaben, isNew: true)
            .modelContainer(container)
    } catch {
        return VorhabenEditor(vorhaben: VorhabenModel(), isNew: true)
    }
}

#Preview("Bearbeiten") {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container: ModelContainer = try ModelContainer(for: VorhabenModel.self, configurations: config)
    let vorhaben = VorhabenModel.preview2
    container.mainContext.insert(vorhaben)
    
    return VorhabenEditor(vorhaben: vorhaben)
        .modelContainer(container)
    } catch {
        return VorhabenEditor(vorhaben: VorhabenModel.preview2)
    }
}
