//
//  LebensbereicheView.swift
//  iLifeDesign
//
//  Created by Sandra Sulzberger on 18.08.2024.
//  Überarbeitet: 12.07.2026
//

import SwiftUI
import SwiftData

// MARK: - Haupt-View

struct LebensbereicheView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LebensbereichModel.sort) private var lebensbereiche: [LebensbereichModel]
    @Query private var alleVorhaben: [VorhabenModel]

    @State private var newVorhaben = VorhabenModel()
    @State private var isNewVorhaben = false
    @State private var isNeuerBereich = false
    @State private var neuerBereich: LebensbereichModel?
    @State private var bearbeiteterBereich: LebensbereichModel?
    @State private var zeigeLeere = true

    private var sichtbareLebensbereiche: [LebensbereichModel] {
        let liste: [LebensbereichModel]
        if zeigeLeere {
            liste = lebensbereiche
        } else {
            liste = lebensbereiche.filter { bereich in
                alleVorhaben.contains { $0.lebensbereichRef?.id == bereich.id }
            }
        }
        return liste.sorted { $0.sort < $1.sort }
    }

    var body: some View {
        NavigationStack {
            Group {
                if lebensbereiche.isEmpty {
                    ContentUnavailableView(
                        "Keine Lebensbereiche",
                        systemImage: "circle.hexagonpath",
                        description: Text("Tippe auf + um einen Lebensbereich anzulegen.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(sichtbareLebensbereiche) { bereich in
                                LebensbereichGruppeView(bereich: bereich) {
                                    bearbeiteterBereich = bereich
                                } onNeuesVorhaben: {
                                    let vorhaben = VorhabenModel(lebensbereichRef: bereich)
                                    modelContext.insert(vorhaben)
                                    addStandardAufgaben(vorhaben: vorhaben)
                                    newVorhaben = vorhaben
                                    isNewVorhaben = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemGroupedBackground).ignoresSafeArea())
                }
            }
            .navigationTitle("Lebensbereiche")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation { zeigeLeere.toggle() }
                    } label: {
                        Image(systemName: zeigeLeere ? "eye.fill" : "eye.slash")
                            .foregroundStyle(zeigeLeere ? .primary : .secondary)
                    }
                    .help(zeigeLeere ? "Leere Lebensbereiche ausblenden" : "Leere Lebensbereiche einblenden")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            let bereich = LebensbereichModel(sort: lebensbereiche.count)
                            modelContext.insert(bereich)
                            neuerBereich = bereich
                            isNeuerBereich = true
                        } label: {
                            Label("Neuer Lebensbereich", systemImage: "plus.circle")
                        }
                        Button {
                            let vorhaben = VorhabenModel()
                            modelContext.insert(vorhaben)
                            addStandardAufgaben(vorhaben: vorhaben)
                            newVorhaben = vorhaben
                            isNewVorhaben = true
                        } label: {
                            Label("Neues Vorhaben", systemImage: "plus.square")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isNewVorhaben) {
            VorhabenEditor(vorhaben: newVorhaben, isNew: true)
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $isNeuerBereich) {
            if let bereich = neuerBereich {
                LebensbereichEditor(bereich: bereich, isNew: true)
            }
        }
        .sheet(item: $bearbeiteterBereich) { bereich in
            LebensbereichEditor(bereich: bereich)
        }
        .onAppear {
            setupStandardLebensbereiche(context: modelContext)
        }
    }
}

// MARK: - Lebensbereich Gruppen-Karte

struct LebensbereichGruppeView: View {
    @Environment(\.modelContext) private var modelContext

    let bereich: LebensbereichModel
    var onBearbeiten: () -> Void
    var onNeuesVorhaben: () -> Void

    @State private var istAusgeklappt = true

    private var vorhabens: [VorhabenModel] {
        (bereich.vorhaben ?? []).sorted { $0.priority > $1.priority }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Header
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    istAusgeklappt.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(bereich.viewFarbe.opacity(0.18))
                            .frame(width: 40, height: 40)
                        Image(systemName: bereich.icon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(bereich.viewFarbe)
                    }

                    // Texte
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(bereich.name)
                                .fontWeight(.regular)
                                .foregroundStyle(bereich.istAktiv ? bereich.viewFarbe : .secondary)

                            Text("(\(vorhabens.count))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if !bereich.beschreibung.isEmpty {
                            Text(bereich.beschreibung)
                                .font(.caption)
                                .foregroundStyle(bereich.viewFarbe)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    // Aktionen
                    HStack(spacing: 8) {
                        // Bearbeiten-Button
                        Button {
                            onBearbeiten()
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.title3)
                                .foregroundStyle(bereich.viewFarbe.opacity(0.7))
                        }
                        .buttonStyle(.plain)

                        // Vorhaben hinzufügen
                        Button {
                            onNeuesVorhaben()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(bereich.viewFarbe)
                        }
                        .buttonStyle(.plain)

                        // Aufklapp-Pfeil
                        Image(systemName: "chevron.down")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(istAusgeklappt ? 0 : -90))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            // MARK: Vorhaben-Liste
            if istAusgeklappt {
                Divider()
                    .padding(.horizontal, 14)

                if vorhabens.isEmpty {
                    HStack {
                        Image(systemName: "tray")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Noch keine Vorhaben")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                } else {
                    VStack(spacing: 6) {
                        ForEach(vorhabens) { vorhaben in
                            VorhabenZeile(vorhaben: vorhaben, showPhase: true)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
        }
        .opacity(bereich.istAktiv ? 1.0 : 0.5)
    }
}

// MARK: - Previews

#Preview {
    LebensbereicheView()
        .modelContainer(VorhabenModel.preview)
}
