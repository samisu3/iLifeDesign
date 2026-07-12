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
    @State private var zeigeAufgaben = false
    @FocusState private var titleFocused: Bool
    
    @Query(sort: \LebensbereichModel.sort) private var lebensbereiche: [LebensbereichModel]
    @Query(sort: \PhaseModel.sort) private var phasen: [PhaseModel]

    /// Benutzt die geladenen PhaseModel-Einträge, fällt auf PhaseDefaults zurück.
    private var verfügbarePhasen: [PhaseModel] {
        if !phasen.isEmpty { return phasen }
        // Fallback: temporäre Objekte aus den Defaults bauen (nicht persistiert)
        return PhaseDefaults.map {
            PhaseModel(sort: $0.sort, name: $0.name, info: $0.info, icon: $0.icon, farbeID: $0.farbeID)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // ── Titel ────────────────────────────────────────────────
                Section {
                    HStack(spacing: 12) {
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

                        TextField("Was möchten Sie erreichen?", text: $vorhaben.bezeichnung, axis: .vertical)
                            .font(.title3)
                            .fontWeight(.medium)
                            .focused($titleFocused)
                            .onAppear { if isNew { titleFocused = true } }
                    }

                    TextField("Beschreibung", text: $vorhaben.beschreibung, axis: .vertical)
                        .lineLimit(2...6)
                } header: {
                    Text("Titel")
                }

                // ── Priorität & Lebensbereich ────────────────────────────
                Section {
                    // Priorität
                    HStack {
                        Text("Priorität")
                        Spacer()
                        CompactStarPriorityView(priority: $vorhaben.priority)
                    }

                    // Lebensbereich
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
                        HStack {
                            Text("Lebensbereich")
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: vorhaben.viewLebensbereichIcon)
                                    .foregroundStyle(vorhaben.viewLebensbereichFarbe)
                                Text(vorhaben.viewLebensbereich.isEmpty ? "Wählen…" : vorhaben.viewLebensbereich)
                                    .foregroundStyle(vorhaben.viewLebensbereich.isEmpty ? .secondary : vorhaben.viewLebensbereichFarbe)
                            }
                        }
                    }
                    .tint(.primary)
                } header: {
                    Text("Priorität & Lebensbereich")
                }

                // ── Aktuelle Phase & Nächste Aktion ─────────────────────
                Section {
                    // Phasen-Picker
                    Menu {
                        ForEach(verfügbarePhasen) { phase in
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    vorhaben.phase = phase.sort
                                }
                            } label: {
                                HStack {
                                    Image(systemName: phase.icon)
                                        .foregroundStyle(phase.viewFarbe)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(phase.name)
                                            .fontWeight(.medium)
                                        Text(phase.info)
                                            .font(.caption)
                                            .foregroundStyle(phase.viewFarbe)
                                    }
                                    Spacer()
                                    if vorhaben.phase == phase.sort {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(phase.viewFarbe)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                    } label: {
                        let aktuellePhase = verfügbarePhasen.first { $0.sort == vorhaben.phase }
                        let farbe = aktuellePhase?.viewFarbe ?? vorhaben.viewColor
                        HStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(farbe.opacity(0.15))
                                    .frame(width: 28, height: 28)
                                Image(systemName: aktuellePhase?.icon ?? vorhaben.viewPhaseIcon)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(farbe)
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                Text(aktuellePhase?.name ?? vorhaben.viewPhase)
                                    .foregroundStyle(farbe)
                                Text(aktuellePhase?.info ?? vorhaben.viewPhaseInfo)
                                    .font(.caption)
                                    .foregroundStyle(farbe)
                            }
                            Spacer()
                        }
                    }
                    .tint(.primary)

                    // Nächste Aktion – Zwischenzeile
                    HStack {
                        Text("Nächste Aktion")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .textCase(nil)
                        Spacer()
                        if vorhaben.viewAktuelleAufgabenAnzahl > 0 {
                            Text("\(vorhaben.viewAktuelleAufgabenAnzahlErledigt)/\(vorhaben.viewAktuelleAufgabenAnzahl)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))

                    // Nächste Aktion – Button
                    let phaseFertig = vorhaben.viewAktuelleAufgabenErledigt
                    let nächsteFrage = vorhaben.viewAktuellNächsteAufgabe

                    Button {
                        zeigeAufgaben = true
                    } label: {
                        HStack(spacing: 10) {
                            if phaseFertig {
                                Text("Phase abgeschlossen · Überarbeiten")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.green)
                            } else if let frage = nächsteFrage {
                                Text(frage.aufgabe)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            } else {
                                Text("Nächste Aktion starten")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            }

                            Spacer(minLength: 0)

                            Image(systemName: phaseFertig ? "checkmark.circle.fill" : "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(phaseFertig ? .green.opacity(0.7) : .white.opacity(0.7))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(phaseFertig ? .green.opacity(0.12) : vorhaben.viewColor)
                                .overlay {
                                    if phaseFertig {
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(.green.opacity(0.4), lineWidth: 1)
                                    }
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                } header: {
                    Text("Aktuelle Phase")
                }

                // ── Verlauf ──────────────────────────────────────────────
                if !isNew {
                    Section {
                        let reflexionen = (vorhaben.reflexionen ?? []).sorted { $0.datum > $1.datum }
                        if reflexionen.isEmpty {
                            Text("Noch kein Verlauf — Fragen beantworten und zur nächsten Phase wechseln.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .italic()
                        } else {
                            ForEach(reflexionen) { reflexion in
                                VerlaufKarte(reflexion: reflexion)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                            }
                        }
                    } header: {
                        HStack {
                            Text("Verlauf")
                            Spacer()
                            let count = (vorhaben.reflexionen ?? []).count
                            if count > 0 { Text("\(count)") }
                        }
                    }
                }

                // ── Löschen ──────────────────────────────────────────────
                if !isNew {
                    Section {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("Vorhaben löschen", systemImage: "trash")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "Neues Vorhaben" : "Vorhaben bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $zeigeAufgaben) {
                AufgabenListeView(vorhaben: vorhaben)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        if isNew { modelContext.delete(vorhaben) }
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
    
    // MARK: - (verlaufSection entfernt — direkt in Form inline)
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
