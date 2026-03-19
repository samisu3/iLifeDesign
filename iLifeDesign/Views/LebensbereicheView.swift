//
//  LebensbereicheView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 18.08.2024.
//

import SwiftUI
import SwiftData

struct LebensbereicheView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var refresh = false
    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(0..<9, id: \.self) { lebensbereich in
                        LebensbereichGruppeView(lebensbereich: lebensbereich)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .navigationTitle("Lebensbereiche")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("", systemImage: "arrow.clockwise") {
                        refresh.toggle()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("", systemImage: "plus") {
                        newVorhaben = VorhabenModel()
                        modelContext.insert(newVorhaben)
                        addStandardAufgaben(vorhaben: newVorhaben)
                        isNewVorhaben = true
                        refresh.toggle()
                    }
                }
            }
            .id(refresh)
        }
        .sheet(isPresented: $isNewVorhaben) {
            VorhabenEditor(vorhaben: newVorhaben, isNew: true)
        }
        .onAppear {
            refresh.toggle()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refresh.toggle()
            }
        }
    }
    }


struct LebensbereichGruppeView: View {
    @Environment(\.modelContext) private var modelContext
    let lebensbereich: Int
    
    private var sortDescriptors: [SortDescriptor<VorhabenModel>] {
        [SortDescriptor(\VorhabenModel.priority, order: .reverse)]
    }
    
    private var vorhabens: [VorhabenModel] {
        let predicate = #Predicate<VorhabenModel> { vorhaben in
            vorhaben.lebensbereich == lebensbereich
        }
        let fetch = FetchDescriptor(predicate: predicate, sortBy: sortDescriptors)
        return (try? modelContext.fetch(fetch)) ?? []
    }
    
    private var bereichColor: Color {
        LebensbereicheColor[lebensbereich] ?? .gray
    }
    
    private var bereichName: String {
        Lebensbereiche[lebensbereich] ?? "Lebensbereich \(lebensbereich + 1)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Lebensbereich Header (immer anzeigen)
            HStack(spacing: 12) {
                // Lebensbereich Icon
                ZStack {
                    Circle()
                        .fill(bereichColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: LebensbereicheIcon[lebensbereich] ?? "circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(bereichColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(bereichName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(bereichColor)
                        
                        Text("(\(vorhabens.count))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Lebensbereich")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Vorhaben Liste (nur wenn vorhanden)
            if !vorhabens.isEmpty {
                VStack(spacing: 6) {
                    ForEach(vorhabens) { vorhaben in
                        NavigationLink {
                            VorhabenEditor(vorhaben: vorhaben)
                        } label: {
                            CompactVorhabenCard(vorhaben: vorhaben, showPhase: true)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("Keine Vorhaben")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .italic()
                    .padding(.leading, 44)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(bereichColor.opacity(vorhabens.isEmpty ? 0.1 : 0.2), lineWidth: 1)
                }
        }
    }
}

#Preview {
    LebensbereicheView()
        .modelContainer(VorhabenModel.preview)
}
