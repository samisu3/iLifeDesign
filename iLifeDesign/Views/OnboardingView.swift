//
//  OnboardingView.swift
//  iLifeDesign
//
//  Intro beim App-Start: erklärt das Konzept — Ideen sammeln und
//  als kleine Experimente (Prototyping) umsetzen. Wird bei jedem Start
//  gezeigt, bis „Überspringen“ gewählt wird; in den Einstellungen
//  jederzeit wieder aktivierbar.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("introBeimStart") private var introBeimStart = true

    @State private var seite = 0
    private let letzteSeite = 3

    var body: some View {
        ZStack {
            DesignSystem.Colors.backgroundGradient(for: .blue)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // Überspringen: blendet das Intro dauerhaft aus
                HStack {
                    Spacer()
                    Button("Überspringen") {
                        introBeimStart = false
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }

                // Seiten
                TabView(selection: $seite) {
                    ideenSeite.tag(0)
                    dimensionenSeite.tag(1)
                    prototypingSeite.tag(2)
                    dranbleibenSeite.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Weiter / Los geht's
                Button {
                    if seite < letzteSeite {
                        withAnimation(.spring(response: 0.35)) { seite += 1 }
                    } else {
                        dismiss()
                    }
                } label: {
                    Text(seite < letzteSeite ? "Weiter" : "Los geht's!")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.blue)
                        }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)

                Text("„Überspringen“ blendet das Intro dauerhaft aus — Du findest es jederzeit in den Einstellungen wieder.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 10)
                    .padding(.bottom, 16)
            }
        }
    }

    // MARK: Seite 1 — Ideen sammeln

    private var ideenSeite: some View {
        OnboardingSeite(
            icon: "lightbulb.max.fill",
            farbe: .orange,
            titel: "Sammle Deine Ideen",
            text: "Jede Veränderung beginnt mit einer Idee. Halte sie fest, sobald sie auftaucht — ein Satz genügt. Alles Weitere kommt später."
        ) {
            // Mini-Vorschau des Ideen-Kärtchens
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)
                Text("Nimm heute einen neuen Weg nach Hause")
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .orange.opacity(0.15), radius: 8, y: 4)
            }
            .padding(.horizontal, 12)
        }
    }

    // MARK: Seite 2 — Die 5 Dimensionen

    private var dimensionenSeite: some View {
        OnboardingSeite(
            icon: "circle.hexagonpath.fill",
            farbe: .teal,
            titel: "Behalte Deine Balance",
            text: "Fünf Dimensionen zeigen Dir auf einen Blick, wo Du gerade experimentierst — und wo noch Platz für Neues ist."
        ) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    OnboardingChip(name: "Vitalität", icon: "bolt.heart.fill", farbe: .green)
                    OnboardingChip(name: "Wirkung", icon: "briefcase.fill", farbe: .blue)
                    OnboardingChip(name: "Experimente", icon: "sparkles", farbe: .orange)
                }
                HStack(spacing: 8) {
                    OnboardingChip(name: "Verbindung", icon: "person.2.fill", farbe: .pink)
                    OnboardingChip(name: "Umfeld", icon: "house.fill", farbe: .teal)
                }
            }
        }
    }

    // MARK: Seite 3 — Der Prototyping-Loop

    private var prototypingSeite: some View {
        OnboardingSeite(
            icon: "arrow.triangle.2.circlepath",
            farbe: .purple,
            titel: "Teste klein statt gross zu planen",
            text: "Deine Idee wird zum kleinen Experiment: Fokus schärfen, Prototyp planen, im Alltag ausprobieren, Bilanz ziehen — und mit Schwung in die nächste Runde."
        ) {
            HStack(spacing: 10) {
                OnboardingPhasenIcon(icon: "safari", farbe: .blue)
                pfeil
                OnboardingPhasenIcon(icon: "lightbulb.max", farbe: .yellow)
                pfeil
                OnboardingPhasenIcon(icon: "figure.run", farbe: .green)
                pfeil
                OnboardingPhasenIcon(icon: "book", farbe: .indigo)
                pfeil
                OnboardingPhasenIcon(icon: "arrow.triangle.2.circlepath", farbe: .purple)
            }
        }
    }

    private var pfeil: some View {
        Image(systemName: "chevron.right")
            .font(.caption2.bold())
            .foregroundStyle(.tertiary)
    }

    // MARK: Seite 4 — Dranbleiben

    private var dranbleibenSeite: some View {
        OnboardingSeite(
            icon: "trophy.fill",
            farbe: .yellow,
            titel: "Bleib auf Expedition",
            text: "Jede abgeschlossene Phase wird zur Trophäe in Deinem Logbuch. Kleine Schritte, Woche für Woche — das ist die 1-%-Methode."
        ) {
            HStack(spacing: 12) {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("3 Wochen in Folge auf Expedition")
                    .font(.subheadline.bold())
                Spacer(minLength: 0)
            }
            .padding(14)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .orange.opacity(0.15), radius: 8, y: 4)
            }
            .padding(.horizontal, 12)
        }
    }
}

// MARK: - Bausteine

private struct OnboardingSeite<Visual: View>: View {
    let icon: String
    let farbe: Color
    let titel: String
    let text: String
    @ViewBuilder let visual: () -> Visual

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(farbe.opacity(0.15))
                    .frame(width: 110, height: 110)
                Circle()
                    .stroke(farbe.opacity(0.3), lineWidth: 2)
                    .frame(width: 110, height: 110)
                Image(systemName: icon)
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(farbe)
            }

            VStack(spacing: 12) {
                Text(titel)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }

            visual()

            Spacer()
            // Platz für die Punkte-Anzeige des TabView
            Spacer().frame(height: 24)
        }
        .padding(.horizontal, 28)
    }
}

private struct OnboardingChip: View {
    let name: String
    let icon: String
    let farbe: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption)
            Text(name)
                .font(.caption.bold())
        }
        .foregroundStyle(farbe)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background { Capsule().fill(farbe.opacity(0.12)) }
    }
}

private struct OnboardingPhasenIcon: View {
    let icon: String
    let farbe: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(farbe.opacity(0.15))
                .frame(width: 40, height: 40)
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(farbe)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView()
}
