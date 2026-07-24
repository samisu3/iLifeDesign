//
//  LebensbereichEditor.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 12.07.2026.
//

import SwiftUI
import SwiftData

// MARK: - Editor

struct LebensbereichEditor: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var bereich: LebensbereichModel
    var isNew: Bool = false

    @State private var zeigeIconPicker = false
    @State private var zeigeFarbPicker = false

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Vorschau
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(bereich.viewFarbe.opacity(0.2))
                                .frame(width: 56, height: 56)
                            Image(systemName: bereich.icon)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(bereich.viewFarbe)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bereich.name.isEmpty ? "Name des Lebensbereichs" : bereich.name)
                                .font(.headline)
                                .foregroundStyle(bereich.name.isEmpty ? .secondary : .primary)
                            Text(bereich.beschreibung.isEmpty ? "Beschreibung" : bereich.beschreibung)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Einschätzung \(bereich.einschaetzung) / 10")
                                .font(.caption)
                                .foregroundStyle(bereich.viewFarbe)
                        }
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Vorschau")
                }

                // MARK: Name & Beschreibung
                Section("Name & Beschreibung") {
                    TextField("Name", text: $bereich.name)
                    TextField("Beschreibung", text: $bereich.beschreibung, axis: .vertical)
                        .lineLimit(2...4)
                }

                // MARK: Selbsteinschätzung
                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Aktueller Stand")
                            Spacer()
                            Text("\(bereich.einschaetzung) / 10")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(bereich.viewFarbe)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(bereich.einschaetzung) },
                                set: { bereich.einschaetzung = Int($0.rounded()) }
                            ),
                            in: 1...10,
                            step: 1
                        )
                        .tint(bereich.viewFarbe)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Selbsteinschätzung")
                } footer: {
                    Text("Wie zufrieden bist Du aktuell in dieser Dimension? Die Werte bilden das Netzdiagramm im Balance-Check der Statistik.")
                }

                // MARK: Icon
                Section {
                    Button {
                        zeigeIconPicker = true
                    } label: {
                        HStack {
                            Image(systemName: bereich.icon)
                                .font(.title3)
                                .foregroundStyle(bereich.viewFarbe)
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
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
                        ForEach(LebensbereichVerfügbareFarben) { farbe in
                            Button {
                                bereich.farbeID = farbe.id
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(farbe.color)
                                        .frame(width: 36, height: 36)
                                    if farbe.id == bereich.farbeID {
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

                // MARK: Sichtbarkeit
                Section {
                    Toggle("Lebensbereich aktiv", isOn: $bereich.istAktiv)
                } header: {
                    Text("Sichtbarkeit")
                } footer: {
                    Text("Inaktive Lebensbereiche werden in der Übersicht ausgeblendet.")
                }
            }
            .navigationTitle(isNew ? "Neuer Lebensbereich" : "Lebensbereich bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                    .disabled(bereich.name.isEmpty)
                }
                if isNew {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            modelContext.delete(bereich)
                            dismiss()
                        }
                    }
                }
            }
            .sheet(isPresented: $zeigeIconPicker) {
                LebensbereichIconPicker(gewähltesIcon: $bereich.icon, farbe: bereich.viewFarbe)
            }
        }
    }
}

// MARK: - Icon Picker

struct LebensbereichIconPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var gewähltesIcon: String
    let farbe: Color

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(LebensbereichVerfügbareIcons, id: \.self) { icon in
                        Button {
                            gewähltesIcon = icon
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(icon == gewähltesIcon ? farbe.opacity(0.2) : Color(.secondarySystemBackground))
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

// MARK: - Previews

#Preview("Editor") {
    let container = try! ModelContainer(
        for: LebensbereichModel.self, VorhabenModel.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let bereich = LebensbereichModel(
        name: "Vitalität",
        beschreibung: "Wie stark ist mein innerer Akku geladen?",
        icon: "bolt.heart.fill",
        farbeID: "green",
        einschaetzung: 7
    )
    container.mainContext.insert(bereich)
    return LebensbereichEditor(bereich: bereich)
        .modelContainer(container)
}
