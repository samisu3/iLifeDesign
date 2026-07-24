//
//  DesignSystem.swift
//  iLifeDesign
//
//  Created by Assistant on 15.05.2026.
//

import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }
    
    // MARK: - Colors
    struct Colors {
        static let primaryBackground = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        // Gradient Backgrounds
        static func backgroundGradient(for color: Color) -> LinearGradient {
            LinearGradient(
                colors: [
                    color.opacity(0.08),
                    color.opacity(0.03),
                    Color(.systemBackground)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func cardGradient(for color: Color) -> LinearGradient {
            LinearGradient(
                colors: [
                    color.opacity(0.15),
                    color.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Custom View Extensions
extension View {
    // Modern Card Style
    func modernCard(color: Color = .clear, cornerRadius: CGFloat = DesignSystem.CornerRadius.lg) -> some View {
        self.background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                }
        }
        .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // Navigation Style
    func modernNavigation() -> some View {
        self.navigationBarTitleDisplayMode(.large)
    }
    
    // Enhanced Card Style
    func enhancedCard(
        color: Color,
        cornerRadius: CGFloat = DesignSystem.CornerRadius.lg,
        padding: CGFloat = DesignSystem.Spacing.lg
    ) -> some View {
        self
            .padding(padding)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(DesignSystem.Colors.cardGradient(for: color))
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        }
                }
            }
            .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Entdecker-Botschaften (Identity Shift)
// Kurze identitätsstiftende Botschaften nach kleinen Erfolgen —
// die App bestätigt nicht die Aufgabe, sondern die Rolle als Entdecker:in.

let EntdeckerBotschaften: [String] = [
    "Du bist heute 1 % mehr Entdecker:in als gestern.",
    "Expeditions-Level gestiegen! 🧭",
    "Kleine Experimente, grosse Wirkung.",
    "Wieder einen Schritt mutiger als gestern.",
    "Deine Neugier zahlt sich aus.",
    "So sehen Menschen aus, die Dinge ausprobieren.",
]

// MARK: - Konfetti (Belohnungs-Effekt)
// Leichter Partikel-Effekt für Phasenabschlüsse — ohne externe Abhängigkeiten.

struct KonfettiView: View {
    private let farben: [Color] = [.blue, .green, .orange, .pink, .purple, .yellow, .teal]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<36, id: \.self) { i in
                    KonfettiTeilchen(
                        farbe: farben[i % farben.count],
                        feldBreite: geo.size.width,
                        feldHöhe: geo.size.height,
                        verzögerung: Double(i % 12) * 0.04
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct KonfettiTeilchen: View {
    let farbe: Color
    let feldBreite: CGFloat
    let feldHöhe: CGFloat
    let verzögerung: Double

    @State private var fällt = false

    private let x = CGFloat.random(in: 0.02...0.98)
    private let drehung = Double.random(in: 0...360)
    private let grösse = CGFloat.random(in: 7...12)
    private let dauer = Double.random(in: 1.6...2.6)

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(farbe)
            .frame(width: grösse, height: grösse * 0.6)
            .rotationEffect(.degrees(fällt ? drehung + 540 : drehung))
            .position(x: x * feldBreite, y: fällt ? feldHöhe + 30 : -30)
            .opacity(fällt ? 0.85 : 1)
            .onAppear {
                withAnimation(.easeIn(duration: dauer).delay(verzögerung)) {
                    fällt = true
                }
            }
    }
}

// MARK: - Custom Button Styles
struct ModernButtonStyle: ButtonStyle {
    let color: Color
    let isProminent: Bool
    
    init(color: Color, isProminent: Bool = false) {
        self.color = color
        self.isProminent = isProminent
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background {
                if isProminent {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                        .fill(color)
                        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                                .stroke(color.opacity(0.5), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}