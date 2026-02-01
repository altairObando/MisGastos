//
//  CustomProgressBar.swift
//  MisGastos
//
//  Created by Noel Obando Espinoza on 2/1/26.
//
import Foundation
import SwiftUI

struct CustomProgressBar: View {
    let progress: Double // 0.0 a 1.0
    let height: CGFloat
    let cornerRadius: CGFloat
    let showPercentage: Bool
    let showThresholds: Bool
    let thresholds: [(threshold: Double, color: Color, label: String)]
    
    init(
        progress: Double,
        height: CGFloat = 12,
        cornerRadius: CGFloat? = nil,
        showPercentage: Bool = true,
        showThresholds: Bool = false,
        thresholds: [(Double, Color, String)]? = nil
    ) {
        self.progress = max(0, min(1, progress)) // Asegurar entre 0 y 1
        self.height = height
        self.cornerRadius = cornerRadius ?? height / 2
        self.showPercentage = showPercentage
        self.showThresholds = showThresholds
        self.thresholds = thresholds ?? [
            (0.3, .green, "Bajo"),
            (0.6, .yellow, "Moderado"),
            (0.8, .red, "Alto"),
            (1.0, .purple, "Crítico")
        ]
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Barra de progreso
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: height)
                    
                    // Marcas de umbral
                    if showThresholds {
                        ForEach(thresholds, id: \.threshold) { threshold in
                            Rectangle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 2, height: height + 4)
                                .offset(x: geometry.size.width * threshold.threshold - 1)
                        }
                    }
                    
                    // Barra de progreso
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(currentColor)
                        .frame(width: geometry.size.width * progress, height: height)
                }
            }
            .frame(height: height)
            
            // Información
            HStack {
                if showPercentage {
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(currentLabel)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(currentColor)
            }
        }
    }
    
    private var currentColor: Color {
        for (threshold, color, _) in thresholds.sorted(by: { $0.threshold < $1.threshold }) {
            if progress <= threshold {
                return color
            }
        }
        return thresholds.last?.color ?? .blue
    }
    
    private var currentLabel: String {
        for (threshold, _, label) in thresholds.sorted(by: { $0.threshold < $1.threshold }) {
            if progress <= threshold {
                return label
            }
        }
        return thresholds.last?.label ?? ""
    }
}
