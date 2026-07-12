//
//  DesignSystem.swift
//  iLifeDesign
//
//  Created by Assistant on 15.05.2026.
//

import SwiftUI

// MARK: - Design System
struct DesignSystem {
    
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
    
    // MARK: - Shadows
    struct Shadows {
        static let subtle = Shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        static let soft = Shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        static let medium = Shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Custom View Modifiers
extension View {
    // Liquid Glass Card Style
    func glassCard(color: Color = .clear, cornerRadius: CGFloat = DesignSystem.CornerRadius.lg) -> some View {
        self
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.regularMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    }
                    .glassEffect(.regular.tint(color.opacity(0.1)), in: .rect(cornerRadius: cornerRadius))
            }
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
                    // Background gradient
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(DesignSystem.Colors.cardGradient(for: color))
                    
                    // Glass effect
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        }
                }
            }
    }
    
    // Animated Button Style
    func animatedButton(color: Color) -> some View {
        self
            .scaleEffect(1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: color)
    }
    
    // Navigation Style
    func modernNavigation() -> some View {
        self
            .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Custom Button Styles
struct GlassButtonStyle: ButtonStyle {
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
                        .glassEffect(.regular.tint(color.opacity(0.2)).interactive(), in: .rect(cornerRadius: DesignSystem.CornerRadius.md))
                } else {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                        .fill(.regularMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                                .stroke(color.opacity(0.5), lineWidth: 1)
                        }
                        .glassEffect(.regular.tint(color.opacity(0.1)).interactive(), in: .rect(cornerRadius: DesignSystem.CornerRadius.md))
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}