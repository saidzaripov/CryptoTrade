//
//  UtilityViews.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//

import SwiftUI

// MARK: - Common UI Components

struct BackgroundView: View {
    let isDarkMode: Bool
    
    var body: some View {
        if isDarkMode {
            AppColors.darkBackground
                .ignoresSafeArea()
        } else {
            AppColors.lightBackground
                .ignoresSafeArea()
        }
    }
}

struct StatusToast: View {
    let message: String
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .padding()
                .background(AppColors.primary.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .transition(.scale.combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: isVisible)
        }
    }
}

struct ConfettiView: View {
    let isDarkMode: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50, id: \.self) { index in
                Circle()
                    .foregroundColor([AppColors.primary, AppColors.success, AppColors.highlight, AppColors.alert].randomElement()!)
                    .frame(width: CGFloat.random(in: 5...15), height: CGFloat.random(in: 5...15))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
                    .animation(.easeOut(duration: 1).delay(Double.random(in: 0...0.5)), value: UUID())
            }
        }
    }
}

struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}
