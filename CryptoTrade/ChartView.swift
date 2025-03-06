//
//  ChartView.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//


import SwiftUI
import Charts

struct ChartTabView: View {
    @Binding var selectedChartCoin: String
    @Binding var chartData: [ChartDataPoint]
    let coins: [(String, String)]
    let isDarkMode: Bool
    @State private var selectedTimeframe: TimeFrame = .day
    
    var body: some View {
        NavigationView {
            ZStack {
                // Use the standard background view pattern
                if isDarkMode {
                    AppColors.darkBackground.ignoresSafeArea()
                } else {
                    AppColors.lightBackground.ignoresSafeArea()
                }
                
                VStack(spacing: 20) {
                    // Coin selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(coins, id: \.1) { name, id in
                                Button(action: {
                                    selectedChartCoin = id
                                }) {
                                    HStack {
                                        Image(coinIcon(for: id))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                        Text(name)
                                            .font(.system(size: 16, weight: .medium))
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedChartCoin == id ? AppColors.primary : (isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)))
                                    .foregroundColor(selectedChartCoin == id ? .white : AppColors.textPrimary(isDark: isDarkMode))
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Timeframe selector
                    HStack {
                        ForEach(TimeFrame.allCases) { timeframe in
                            Button(action: {
                                selectedTimeframe = timeframe
                            }) {
                                Text(timeframe.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedTimeframe == timeframe ? AppColors.primary : (isDarkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1)))
                                    .foregroundColor(selectedTimeframe == timeframe ? .white : AppColors.textPrimary(isDark: isDarkMode))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Price info
                    if let coinName = coins.first(where: { $0.1 == selectedChartCoin })?.0,
                       let lastPrice = chartData.last?.price {
                        
                        VStack(spacing: 8) {
                            Text(coinName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                            
                            Text("$\(formatPrice(lastPrice))")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                            
                            // In a real app, calculate the actual change based on timeframe
                            // This is just a placeholder
                            let change = calculateChange(for: selectedTimeframe)
                            Text("\(change >= 0 ? "+" : "")\(String(format: "%.2f", change))% (\(selectedTimeframe.rawValue))")
                                .font(.headline)
                                .foregroundColor(change >= 0 ? AppColors.success : AppColors.alert)
                        }
                        .padding()
                    }
                    
                    // Chart
                    if chartData.isEmpty {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Text("Loading chart data...")
                                .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Price Chart
                        Chart {
                            ForEach(chartData, id: \.time) { dataPoint in
                                LineMark(
                                    x: .value("Time", Date(timeIntervalSince1970: dataPoint.time)),
                                    y: .value("Price", dataPoint.price)
                                )
                                .foregroundStyle(AppColors.primary.gradient)
                                .interpolationMethod(.catmullRom)
                                
                                AreaMark(
                                    x: .value("Time", Date(timeIntervalSince1970: dataPoint.time)),
                                    y: .value("Price", dataPoint.price)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [AppColors.primary.opacity(0.3), AppColors.primary.opacity(0.0)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom)
                            }
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .frame(height: 300)
                        .padding()
                        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
                        .cornerRadius(15)
                    }

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Price Chart")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Helper function to calculate price change
    // In a real app, this would use actual data for the selected timeframe
    func calculateChange(for timeframe: TimeFrame) -> Double {
        // This is just a placeholder - in a real app, you'd calculate
        // the actual change based on the selected timeframe
        switch timeframe {
        case .hour:
            return Double.random(in: -1.0...1.0)
        case .day:
            return Double.random(in: -3.0...3.0)
        case .week:
            return Double.random(in: -10.0...10.0)
        case .month:
            return Double.random(in: -20.0...20.0)
        case .year, .all:
            return Double.random(in: -50.0...50.0)
        }
    }
}
