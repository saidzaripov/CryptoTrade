//
//  MarketView.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//

import SwiftUI

struct MarketView: View {
    let coins: [(String, String)]
    let coinData: [String: CoinPriceData]
    let alertThreshold: Double
    @Binding var selectedChartCoin: String
    @Binding var selectedTab: Int
    let isDarkMode: Bool
    let refreshAction: () -> Void
    
    @State private var searchText = ""
    @State private var showingFilterOptions = false
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Meme", "DeFi", "Layer 1", "Stablecoin"]
    
    var filteredCoins: [(String, String)] {
        let filtered = coins.filter { coin in
            if searchText.isEmpty {
                return true
            } else {
                return coin.0.lowercased().contains(searchText.lowercased())
            }
        }
        
        if selectedCategory == "All" {
            return filtered
        } else {
            // This is simplistic - in a real app, you'd have proper category data
            switch selectedCategory {
            case "Meme":
                return filtered.filter { ["dogecoin", "shiba-inu", "pepe", "bonk", "floki-inu", "dogwifhat"].contains($0.1) }
            case "DeFi":
                return filtered.filter { ["ethereum"].contains($0.1) }
            case "Layer 1":
                return filtered.filter { ["bitcoin", "ethereum", "solana", "cardano"].contains($0.1) }
            case "Stablecoin":
                return filtered.filter { ["tether"].contains($0.1) }
            default:
                return filtered
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Direct background definition
                if isDarkMode {
                    AppColors.darkBackground.ignoresSafeArea()
                } else {
                    AppColors.lightBackground.ignoresSafeArea()
                }
                
                VStack {
                    // Market overview card
                    MarketOverviewCard(isDarkMode: isDarkMode)
                    
                    // Search and filter bar
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                            TextField("Search coins", text: $searchText)
                                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                        }
                        .padding(10)
                        .background(isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        Button(action: { showingFilterOptions.toggle() }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.system(size: 22))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Category filter
                    if showingFilterOptions {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button(action: {
                                        selectedCategory = category
                                    }) {
                                        Text(category)
                                            .font(.system(size: 14, weight: .medium))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedCategory == category ? AppColors.primary : (isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)))
                                            .foregroundColor(selectedCategory == category ? .white : AppColors.textPrimary(isDark: isDarkMode))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 5)
                    }
                    
                    // Coin grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(filteredCoins, id: \.1) { name, id in
                                CoinCard(
                                    name: name,
                                    id: id,
                                    coinData: coinData,
                                    alertThreshold: alertThreshold,
                                    isDarkMode: isDarkMode
                                )
                                .onTapGesture {
                                    selectedChartCoin = id
                                    selectedTab = 1 // Switch to chart tab
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Crypto Market")
            .navigationBarTitleDisplayMode(.inline)
            // Using navigationBarItems instead of toolbar to fix ambiguity
            .navigationBarItems(trailing:
                Button(action: refreshAction) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(AppColors.primary)
                }
            )
        }
    }
}

struct MarketOverviewCard: View {
    let isDarkMode: Bool
    
    // Sample data - in a real app, this would come from your API
    let marketCap = 2_430_000_000_000.0
    let marketCapChange = 2.1
    let btcDom = 51.2
    let ethDom = 18.4
    let fearGreedIndex = 65
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Market Overview")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Global Market Cap")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                    Text(formatLargeNumber(marketCap))
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("24h Change")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                    // Using String(format:) instead of specifier in interpolation
                    Text(String(format: "%+.1f%%", marketCapChange))
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(marketCapChange >= 0 ? AppColors.success : AppColors.alert)
                }
            }
            
            HStack(spacing: 8) {
                // Using String(format:) instead of specifier in interpolation
                TagView(text: "BTC Dom: " + String(format: "%.1f%%", btcDom), color: AppColors.highlight)
                TagView(text: "ETH Dom: " + String(format: "%.1f%%", ethDom), color: AppColors.primary)
                TagView(text: "Fear & Greed: \(fearGreedIndex)", color: fearGreedColor(fearGreedIndex))
            }
        }
        .padding()
        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
        .cornerRadius(15)
        .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 5)
        .padding(.horizontal)
        .padding(.top, 5)
    }
    
    func fearGreedColor(_ index: Int) -> Color {
        if index <= 25 {
            return AppColors.alert
        } else if index <= 45 {
            return Color.orange
        } else if index <= 55 {
            return AppColors.highlight
        } else if index <= 75 {
            return AppColors.success
        } else {
            return Color.green
        }
    }
}

struct CoinCard: View {
    let name: String
    let id: String
    let coinData: [String: CoinPriceData]
    let alertThreshold: Double
    let isDarkMode: Bool
    
    var body: some View {
        let price = coinData[id]?.price ?? 0.0
        let change = coinData[id]?.change ?? 0.0
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(coinIcon(for: id))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(name)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                Spacer()
            }
            
            Text("$" + formatPrice(price))
                .font(.subheadline)
                .bold()
                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
            
            HStack {
                // Using String(format:) instead of specifier in interpolation
                Text(String(format: "%+.2f%%", change))
                    .font(.caption)
                    .foregroundColor(change >= 0 ? AppColors.success : AppColors.alert)
                
                Spacer()
                
                // Mini spark line chart (placeholder)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: change >= 0 ? 10 : 5))
                    path.addLine(to: CGPoint(x: 10, y: change >= 0 ? 8 : 7))
                    path.addLine(to: CGPoint(x: 20, y: change >= 0 ? 6 : 9))
                    path.addLine(to: CGPoint(x: 30, y: change >= 0 ? 4 : 6))
                    path.addLine(to: CGPoint(x: 40, y: change >= 0 ? 3 : 8))
                }
                .stroke(change >= 0 ? AppColors.success : AppColors.alert, lineWidth: 1.5)
                .frame(width: 40, height: 10)
            }
        }
        .padding()
        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
        .cornerRadius(15)
        .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(abs(change) >= alertThreshold ? (change >= 0 ? AppColors.success : AppColors.alert) : Color.clear, lineWidth: 2)
        )
    }
}
