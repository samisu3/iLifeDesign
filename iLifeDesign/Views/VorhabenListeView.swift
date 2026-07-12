//
//  VorhabenListeView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 16.06.2024.
// Inspred by Xopyright © 2023 Big Mountain Studio.
// All rights reserved. Twitter: @BigMtnStudio
//

import SwiftUI
import SwiftData


struct VorhabenListeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var refresh = true
    @State private var sortOrder = SortOrder.forward
    @State private var searchText = ""
    @State private var sortBy = [
        SortDescriptor(\VorhabenModel.priority, order: .reverse),
        SortDescriptor(\VorhabenModel.phase)
    ]
    @State private var showingStatsSheet = false
    
    // Neue Preiew Variable, die nil sein kann
    var previewVorhabens: [VorhabenModel]? = nil
    
    private var Vorhabens: [VorhabenModel] {
        if let previewVorhabens = previewVorhabens {
            return previewVorhabens
        }

        let predicate = #Predicate<VorhabenModel> { vorhaben in
            vorhaben.bezeichnung.contains(searchText)
        }
        let fetch = FetchDescriptor(
            predicate: searchText.isEmpty ? nil : predicate,
            sortBy: sortBy
        )
        return (try? modelContext.fetch(fetch)) ?? []
    }
    
    
    @State private var VorhabenToDelete: VorhabenModel?
    @State private var newVorhaben = VorhabenModel()
    @State private var showDeleteAlert = false
    @State private var isNewVorhaben = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Group {
                    if Vorhabens.isEmpty {
                        emptyStateView
                    } else {
                        ScrollView {
                            LazyVStack(spacing: DesignSystem.Spacing.md) {
                                // Vorhaben List
                                ForEach(Vorhabens) { vorhaben in
                                    NavigationLink {
                                        VorhabenEditor(vorhaben: vorhaben)
                                    } label: {
                                        VorhabenView(vorhaben: vorhaben)
                                    }
                                    .buttonStyle(.plain)
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button("Löschen", role: .destructive) {
                                            VorhabenToDelete = vorhaben
                                            showDeleteAlert = true
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.vertical, DesignSystem.Spacing.sm)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Vorhaben suchen...")
            .navigationTitle("Meine Vorhaben")
            .modernNavigation()
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showingStatsSheet = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }

                    Button {
                        newVorhaben = VorhabenModel()
                        modelContext.insert(newVorhaben)
                        addStandardAufgaben(vorhaben: newVorhaben)
                        isNewVorhaben = true
                        refresh.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onChange(of: searchText) {
                //  refresh.toggle()
            }
            .id(refresh)
        }
        .alert("Vorhaben löschen", isPresented: $showDeleteAlert) {
            Button("Löschen", role: .destructive) {
                deleteItems(vorhaben: VorhabenToDelete!)
                showDeleteAlert = false
            }
            Button("Abbrechen", role: .cancel) {
                showDeleteAlert = false
            }
        } message: {
            Text("Soll das Vorhaben wirklich gelöscht werden")
        }
        .sheet(isPresented: $isNewVorhaben) {
            VorhabenEditor(vorhaben: newVorhaben, isNew: true)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showingStatsSheet) {
            statsSheetView
        }
        .onAppear() {
            refresh.toggle()
        }
    }
    
    func deleteItems(vorhaben: VorhabenModel) {
        modelContext.delete(vorhaben)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        let iconView = ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 120, height: 120)
            
            Image(systemName: "sparkles")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(.blue)
        }
        .shadow(color: .blue.opacity(0.2), radius: 20, x: 0, y: 10)
        
        let textContent = VStack(spacing: DesignSystem.Spacing.md) {
            Text("Starten Sie Ihre Reise")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("Erstellen Sie Ihr erstes Vorhaben und verwandeln Sie Ihre Träume in erreichbare Ziele")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        
        let actionButton = Button {
            newVorhaben = VorhabenModel()
            modelContext.insert(newVorhaben)
            addStandardAufgaben(vorhaben: newVorhaben)
            isNewVorhaben = true
            refresh.toggle()
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "plus.circle.fill")
                Text("Erstes Vorhaben erstellen")
            }
            .fontWeight(.semibold)
            .foregroundStyle(.white)
        }
        .buttonStyle(ModernButtonStyle(color: .blue, isProminent: true))
        
        return VStack(spacing: DesignSystem.Spacing.xxl) {
            iconView
            textContent
            actionButton
        }
        .padding(DesignSystem.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .modernCard(color: .blue, cornerRadius: DesignSystem.CornerRadius.xxl)
        .padding(DesignSystem.Spacing.lg)
    }
    
    // MARK: - Stats Sheet View
    private var statsSheetView: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Iterate through Int keys instead of String keys
                        ForEach(Array(Lebensbereiche.keys.sorted()), id: \.self) { bereichKey in
                            let count = Vorhabens.filter { $0.lebensbereich == bereichKey }.count
                            if count > 0, let bereichName = Lebensbereiche[bereichKey] {
                                statsRowView(bereichKey: bereichKey, bereichName: bereichName, count: count)
                            }
                        }
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .navigationTitle("Statistiken")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        showingStatsSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // Helper view for stats rows
    private func statsRowView(bereichKey: Int, bereichName: String, count: Int) -> some View {
        let bereichColor = LebensbereicheColor[bereichKey] ?? .gray
        let bereichIconString = LebensbereicheIcon[bereichKey] ?? "circle"
        
        let contentRow = HStack {
            Image(systemName: bereichIconString)
                .foregroundStyle(bereichColor)
            
            Text(bereichName)
                .fontWeight(.medium)
            
            Spacer()
            
            Text("\(count)")
                .fontWeight(.bold)
                .foregroundStyle(bereichColor)
        }
        
        return contentRow
            .padding(DesignSystem.Spacing.md)
            .modernCard(color: bereichColor)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        let iconRow = HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Spacer()
        }
        
        let valueText = Text(value)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(.primary)
        
        let titleText = Text(title)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
        
        return VStack(spacing: DesignSystem.Spacing.sm) {
            iconRow
            valueText
            titleText
        }
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity)
        .modernCard(color: color, cornerRadius: DesignSystem.CornerRadius.md)
    }
}


#Preview ("Container"){
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: VorhabenModel.self, configurations: config)

        return VorhabenListeView()
            .modelContainer(container)
    } catch {
        return Text("Preview nicht verfügbar: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}

#Preview ("Preview 2"){
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: VorhabenModel.self, configurations: config)

        let example = VorhabenModel.preview2
        container.mainContext.insert(example)

        return VorhabenListeView()
            .modelContainer(container)
    } catch {
        return Text("Preview nicht verfügbar: \(error.localizedDescription)")
            .foregroundColor(.red)
    }
}

