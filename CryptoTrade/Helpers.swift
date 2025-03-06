//
//  Helpers.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//

import SwiftUI

// MARK: - Colors and Styling

// Centralized color palette for the app
struct AppColors {
    // Background colors
    static let darkBackground = Color(hex: "#121726")
    static let lightBackground = Color(hex: "#F8F9FD")
    
    // Accent colors
    static let primary = Color(hex: "#7B61FF")
    static let success = Color(hex: "#00D7B1")
    static let alert = Color(hex: "#FF4A6E")
    static let highlight = Color(hex: "#FFB22E")
    
    // Neutral colors
    static let darkSurface = Color.black.opacity(0.3)
    static let lightSurface = Color.white
    
    // Text colors
    static func textPrimary(isDark: Bool) -> Color {
        isDark ? .white : .black
    }
    
    static func textSecondary(isDark: Bool) -> Color {
        isDark ? .gray : .gray
    }
}

// MARK: - Extensions

// Color Extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// Date extension for formatting
extension Date {
    func formattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
    
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) hour\(hour == 1 ? "" : "s") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) minute\(minute == 1 ? "" : "s") ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Utility Functions

// Helper functions for formatting
func formatPrice(_ price: Double) -> String {
    if price < 0.01 {
        return String(format: "%.6f", price)
    } else if price < 1 {
        return String(format: "%.4f", price)
    } else if price < 1000 {
        return String(format: "%.2f", price)
    } else {
        return String(format: "%.2f", price)
    }
}

func formatLargeNumber(_ number: Double) -> String {
    let billion = 1_000_000_000.0
    let million = 1_000_000.0
    let thousand = 1_000.0
    
    if number >= billion {
        return String(format: "$%.2fB", number / billion)
    } else if number >= million {
        return String(format: "$%.2fM", number / million)
    } else if number >= thousand {
        return String(format: "$%.2fK", number / thousand)
    } else {
        return String(format: "$%.2f", number)
    }
}

// Function to get coin icon based on ID
func coinIcon(for id: String) -> String {
    switch id {
    case "bitcoin": return "btc"
    case "ethereum": return "eth"
    case "dogecoin": return "doge"
    case "shiba-inu": return "shib"
    case "pepe": return "pepe"
    case "bonk": return "bonk"
    case "floki-inu": return "floki"
    case "dogwifhat": return "wif"
    case "solana": return "sol"
    case "xrp": return "xrp"
    case "cardano": return "ada"
    case "tether": return "tether-usdt-icon"
    default: return "default_coin_icon"
    }
}
