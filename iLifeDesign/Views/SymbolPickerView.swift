//
//  SymbolPickerView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 06.10.2024.
//

import SwiftUI
import SwiftData

struct SymbolPickerView: View {
    @Bindable var vorhaben: VorhabenModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)
    
    private var filteredIcons: [Int] {
        if searchText.isEmpty {
            return Array(0...79)
        } else {
            return Array(0...79).filter { iconIndex in
                guard let iconName = VorhabenIcons[iconIndex] else { return false }
                return iconName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredIcons, id: \.self) { iconIndex in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                vorhaben.icon = iconIndex
                            }
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(vorhaben.icon == iconIndex ? vorhaben.viewColor.opacity(0.2) : Color(.systemGray6))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(vorhaben.icon == iconIndex ? vorhaben.viewColor : .clear, lineWidth: 2)
                                    }
                                
                                Image(systemName: VorhabenIcons[iconIndex] ?? "circle")
                                    .font(.title2)
                                    .foregroundStyle(vorhaben.icon == iconIndex ? vorhaben.viewColor : .primary)
                            }
                            .frame(height: 60)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Icon wählen")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Icons durchsuchen")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    let container = VorhabenModel.preview
    let Vorhabens = try! container.mainContext.fetch(
        FetchDescriptor<VorhabenModel>(predicate: #Predicate { vorhaben in
            vorhaben.bezeichnung == "iLifeDesign"
        }))
    SymbolPickerView(vorhaben: Vorhabens[0] )
}
