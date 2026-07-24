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

    private var filteredIcons: [String] {
        if searchText.isEmpty {
            return VorhabenVerfügbareIcons
        }
        return VorhabenVerfügbareIcons.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredIcons, id: \.self) { icon in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                vorhaben.icon = icon
                            }
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(vorhaben.icon == icon ? vorhaben.viewColor.opacity(0.2) : Color(.systemGray6))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(vorhaben.icon == icon ? vorhaben.viewColor : .clear, lineWidth: 2)
                                    }

                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundStyle(vorhaben.icon == icon ? vorhaben.viewColor : .primary)
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
    SymbolPickerView(vorhaben: Vorhabens[0])
        .modelContainer(container)
}
