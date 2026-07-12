//
//  PhaseEditor.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 12.07.2026.
//

import SwiftUI
import SwiftData

// MARK: - Editor

struct PhaseEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var phase: PhaseModel

    @State private var zeigeIconPicker = false

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Vorschau
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(phase.viewFarbe.opacity(0.2))
                                .frame(width: 56, height: 56)
                            Image(systemName: phase.icon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(phase.viewFarbe)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(phase.name.isEmpty ? "Name der Phase" : phase.name)
                                .font(.headline)
                                .foregroundStyle(phase.name.isEmpty ? .secondary : .primary)
                            Text(phase.info.isEmpty ? "Beschreibung" : phase.info)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Phase \(phase.sort + 1) von 10")
                                .font(.caption2)
                                .foregroundStyle(phase.viewFarbe.opacity(0.8))
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Vorschau")
                }

                // MARK: Name & Beschreibung
                Section("Name & Beschreibung") {
                    TextField("Name", text: $phase.name)
                    TextField("Beschreibung", text: $phase.info, axis: .vertical)
                        .lineLimit(2...4)
                }

                // MARK: Icon
                Section {
                    Button {
                        zeigeIconPicker = true
                    } label: {
                        HStack {
                            Image(systemName: phase.icon)
                                .font(.title3)
                                .foregroundStyle(phase.viewFarbe)
                                .frame(width: 32)
                            Text("Icon auswählen")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Icon")
                }

                // MARK: Farbe
                Section {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7),
                        spacing: 10
                    ) {
                        ForEach(PhaseVerfügbareFarben) { farbe in
                            Button {
                                phase.farbeID = farbe.id
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(farbe.color)
                                        .frame(width: 36, height: 36)
                                    if farbe.id == phase.farbeID {
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Farbe")
                }

                // MARK: Zurücksetzen
                Section {
                    Button(role: .destructive) {
                        resetPhase()
                    } label: {
                        Label("Standard wiederherstellen", systemImage: "arrow.counterclockwise")
                    }
                } footer: {
                    Text("Setzt Name, Beschreibung, Icon und Farbe dieser Phase auf die Originalwerte zurück.")
                }
            }
            .navigationTitle("Phase bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .disabled(phase.name.isEmpty)
                }
            }
            .sheet(isPresented: $zeigeIconPicker) {
                PhaseIconPicker(
                    gewähltesIcon: $phase.icon,
                    farbe: phase.viewFarbe
                )
            }
        }
    }

    private func resetPhase() {
        guard let default_ = PhaseDefaults.first(where: { $0.sort == phase.sort }) else { return }
        phase.name    = default_.name
        phase.info    = default_.info
        phase.icon    = default_.icon
        phase.farbeID = default_.farbeID
    }
}

// MARK: - Icon Picker

struct PhaseIconPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var gewähltesIcon: String
    let farbe: Color

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(PhaseVerfügbareIcons, id: \.self) { icon in
                        Button {
                            gewähltesIcon = icon
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(
                                        icon == gewähltesIcon
                                            ? farbe.opacity(0.2)
                                            : Color(.secondarySystemBackground)
                                    )
                                    .frame(width: 52, height: 52)
                                    .overlay {
                                        if icon == gewähltesIcon {
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(farbe, lineWidth: 2)
                                        }
                                    }
                                Image(systemName: icon)
                                    .font(.system(size: 22))
                                    .foregroundStyle(icon == gewähltesIcon ? farbe : .primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Icon wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: PhaseModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let phase = PhaseModel(sort: 0, name: "Idee", info: "Idee aufnehmen", icon: "pencil", farbeID: "blue")
    container.mainContext.insert(phase)
    return PhaseEditor(phase: phase)
        .modelContainer(container)
}
