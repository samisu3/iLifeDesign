//
//  VorhabenDetailView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.08.2024.
//

import SwiftUI
import SwiftData

struct VorhabenDetailView: View {
    @Bindable var vorhaben: VorhabenModel
    let editVorhaben: Bool
    
    @State private var isPickingSymbol = false
    @FocusState private var titleFocused: Bool
    @FocusState private var descriptionFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if editVorhaben {
                    editingView
                } else {
                    displayView
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
        .sheet(isPresented: $isPickingSymbol){
            SymbolPickerView(vorhaben: vorhaben)
        }
    }
    
    // MARK: - Editing View
    private var editingView: some View {
        VStack(spacing: 24) {
            // Header with Icon and Phase Progress
            headerSection
            
            // Title Input
            titleInputSection
            
            // Phase Selection
            phaseSelectionSection
            
            // Details Section
            detailsInputSection
        }
    }
    
    // MARK: - Display View  
    private var displayView: some View {
        VStack(spacing: 20) {
            // Display Header
            displayHeaderSection
            
            // Phase Info
            phaseDisplaySection
            
            // Details Display
            detailsDisplaySection
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Phase Progress Ring
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 4)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: CGFloat(vorhaben.phase) / 9.0)
                    .stroke(vorhaben.viewColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: vorhaben.phase)
                
                VStack(spacing: 2) {
                    Image(systemName: vorhaben.viewPhaseIcon)
                        .font(.title3)
                        .foregroundStyle(vorhaben.viewColor)
                    
                    Text("\(vorhaben.phase + 1)/10")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(vorhaben.viewPhase)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(vorhaben.viewColor)
        }
    }
    
    // MARK: - Title Input Section
    private var titleInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon Picker
            Button {
                isPickingSymbol = true
            } label: {
                ZStack {
                    Circle()
                        .fill(vorhaben.viewColor.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: vorhaben.viewIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(vorhaben.viewColor)
                }
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            
            // Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Titel")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                TextField("Was möchten Sie erreichen?", text: $vorhaben.bezeichnung, axis: .vertical)
                    .font(.title3)
                    .fontWeight(.medium)
                    .textFieldStyle(.plain)
                    .focused($titleFocused)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(titleFocused ? vorhaben.viewColor : .clear, lineWidth: 2)
                            }
                    }
            }
        }
    }
    
    // MARK: - Phase Selection Section
    private var phaseSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Phase auswählen")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
                ForEach(0...9, id: \.self) { phase in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vorhaben.phase = phase
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: VorhabenPhaseIcon[phase] ?? "circle")
                                .font(.subheadline)
                                .foregroundStyle(vorhaben.phase == phase ? .white : (PhaseColor[phase] ?? .gray))
                            
                            Text("\(phase + 1)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(vorhaben.phase == phase ? .white : .secondary)
                        }
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(vorhaben.phase == phase ? (PhaseColor[phase] ?? .gray) : Color(.systemGray6))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // MARK: - Details Input Section
    private var detailsInputSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Priority
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Priorität")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(vorhaben.priority + 1)/7")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Custom Priority Slider
                HStack {
                    ForEach(0...6, id: \.self) { level in
                        Circle()
                            .fill(level <= vorhaben.priority ? .orange : Color(.systemGray5))
                            .frame(width: 8, height: 8)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    vorhaben.priority = level
                                }
                            }
                        
                        if level < 6 {
                            Rectangle()
                                .fill(level < vorhaben.priority ? .orange : Color(.systemGray5))
                                .frame(height: 2)
                        }
                    }
                }
            }
            
            // Lebensbereich
            VStack(alignment: .leading, spacing: 12) {
                Text("Lebensbereich")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                Menu {
                    ForEach(0...8, id: \.self) { bereich in
                        Button {
                            vorhaben.lebensbereich = bereich
                        } label: {
                            HStack {
                                Text(Lebensbereiche[bereich] ?? "")
                                if vorhaben.lebensbereich == bereich {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(LebensbereicheColor[vorhaben.lebensbereich] ?? .gray)
                            .frame(width: 12, height: 12)
                        
                        Text(vorhaben.viewLebensbereich)
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
                            .fill(.ultraThinMaterial)
                    }
                }
                .buttonStyle(.plain)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Beschreibung")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                TextField("Beschreiben Sie Ihr Vorhaben genauer...", text: $vorhaben.beschreibung, axis: .vertical)
                    .font(.body)
                    .textFieldStyle(.plain)
                    .focused($descriptionFocused)
                    .lineLimit(3...8)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(descriptionFocused ? vorhaben.viewColor : .clear, lineWidth: 2)
                            }
                    }
            }
        }
    }
    
    // MARK: - Display Header Section
    private var displayHeaderSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(vorhaben.viewColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: vorhaben.viewIcon)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(vorhaben.viewColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vorhaben.bezeichnung)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(vorhaben.viewColor)
                
                // Priority Stars
                if vorhaben.priority > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<min(vorhaben.priority + 1, 5), id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
    
    // MARK: - Phase Display Section  
    private var phaseDisplaySection: some View {
        VStack(spacing: 12) {
            PhaseView(phase: vorhaben.phase)
            
            Text(vorhaben.viewPhaseInfo)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(vorhaben.viewColor.opacity(0.1))
        }
    }
    
    // MARK: - Details Display Section
    private var detailsDisplaySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !vorhaben.beschreibung.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Beschreibung")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(vorhaben.beschreibung)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lebensbereich")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Circle()
                            .fill(LebensbereicheColor[vorhaben.lebensbereich] ?? .gray)
                            .frame(width: 12, height: 12)
                        
                        Text(vorhaben.viewLebensbereich)
                            .font(.subheadline)
                            .foregroundStyle(LebensbereicheColor[vorhaben.lebensbereich] ?? .gray)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Priorität")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 2) {
                        ForEach(0...6, id: \.self) { level in
                            Circle()
                                .fill(level <= vorhaben.priority ? .orange : Color(.systemGray5))
                                .frame(width: 6, height: 6)
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
        }
    }
}


#Preview ("Edit"){
    let container = VorhabenModel.preview
    let vorhaben = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { vorhaben in
            vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    
    NavigationStack {
        VorhabenDetailView(vorhaben: vorhaben[0], editVorhaben: true)
    }
}


#Preview ("Show"){
    let container = VorhabenModel.preview
    let vorhaben = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { vorhaben in
            vorhaben.bezeichnung == "iLifeDesign"
        }))
    
    
    NavigationStack {
        VorhabenDetailView(vorhaben: vorhaben[0], editVorhaben: false)
    }
}