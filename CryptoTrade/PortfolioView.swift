//
//  PortfolioView.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//

import SwiftUI
import Charts

struct PortfolioView: View {
    @Binding var portfolioEntries: [PortfolioEntry]
    let coinData: [String: CoinPriceData]
    let coins: [(String, String)]
    let isDarkMode: Bool
    @State private var showingAddSheet = false
    @State private var portfolioTimeframe: TimeFrame = .day
    
    var totalValue: Double {
        portfolioEntries.reduce(0) { sum, entry in
            sum + (entry.amount * (coinData[entry.coinId]?.price ?? 0))
        }
    }
    
    var totalProfit: Double {
        portfolioEntries.reduce(0) { sum, entry in
            let currentValue = entry.amount * (coinData[entry.coinId]?.price ?? 0)
            let purchaseValue = entry.amount * entry.purchasePrice
            return sum + (currentValue - purchaseValue)
        }
    }
    
    var profitPercentage: Double {
        let totalInvestment = portfolioEntries.reduce(0) { sum, entry in
            sum + (entry.amount * entry.purchasePrice)
        }
        
        if totalInvestment == 0 { return 0 }
        return (totalProfit / totalInvestment) * 100
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Portfolio Summary Card
                        VStack(spacing: 15) {
                            Text("Portfolio Value")
                                .font(.headline)
                                .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                            
                            Text("$\(totalValue, specifier: "%.2f")")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Profit/Loss")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                    Text("$\(totalProfit, specifier: "%.2f")")
                                        .font(.headline)
                                        .foregroundColor(totalProfit >= 0 ? AppColors.success : AppColors.alert)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text("Return")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                    Text("\(profitPercentage, specifier: "%.2f")%")
                                        .font(.headline)
                                        .foregroundColor(profitPercentage >= 0 ? AppColors.success : AppColors.alert)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
                        .cornerRadius(20)
                        .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 5)
                        
                        // Portfolio Chart (Sample data)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Performance")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                            
                            Picker("Timeframe", selection: $portfolioTimeframe) {
                                ForEach(TimeFrame.allCases) { timeframe in
                                    Text(timeframe.rawValue).tag(timeframe)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.bottom, 5)
                            
                            // Sample chart with simulated data - replace with real data in production
                            if !portfolioEntries.isEmpty {
                                Chart {
                                    ForEach(samplePerformanceData, id: \.date) { dataPoint in
                                        LineMark(
                                            x: .value("Date", dataPoint.date),
                                            y: .value("Value", dataPoint.value)
                                        )
                                        .foregroundStyle(AppColors.primary)
                                        
                                        AreaMark(
                                            x: .value("Date", dataPoint.date),
                                            y: .value("Value", dataPoint.value)
                                        )
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [AppColors.primary.opacity(0.5), AppColors.primary.opacity(0.0)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                    }
                                }
                                .frame(height: 150)
                            } else {
                                Text("Add holdings to see performance")
                                    .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                    .frame(height: 150)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
                        .cornerRadius(20)
                        .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 5)
                        
                        // Holdings List
                        VStack(alignment: .leading) {
                            Text("Your Holdings")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                .padding(.bottom, 5)
                            
                            if portfolioEntries.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "briefcase")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppColors.primary.opacity(0.5))
                                    Text("No holdings yet")
                                        .font(.headline)
                                    Text("Tap + to add crypto to your portfolio")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                }
                                .frame(maxWidth: .infinity, minHeight: 150)
                                .padding()
                            } else {
                                VStack(spacing: 15) {
                                    ForEach(portfolioEntries) { entry in
                                        let coinName = coins.first(where: { $0.1 == entry.coinId })?.0 ?? entry.coinId
                                        let currentPrice = coinData[entry.coinId]?.price ?? 0
                                        let value = entry.amount * currentPrice
                                        let profit = value - (entry.amount * entry.purchasePrice)
                                        let profitPercentage = ((currentPrice / entry.purchasePrice) - 1) * 100
                                        
                                        HStack {
                                            Image(coinIcon(for: entry.coinId))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 30, height: 30)
                                            
                                            VStack(alignment: .leading) {
                                                Text(coinName)
                                                    .font(.headline)
                                                Text("\(entry.amount, specifier: "%.4f") coins")
                                                    .font(.subheadline)
                                                    .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                            }
                                            
                                            Spacer()
                                            
                                            VStack(alignment: .trailing) {
                                                Text("$\(value, specifier: "%.2f")")
                                                    .font(.headline)
                                                Text("\(profitPercentage, specifier: "%.2f")%")
                                                    .font(.subheadline)
                                                    .foregroundColor(profit >= 0 ? AppColors.success : AppColors.alert)
                                            }
                                        }
                                        .padding()
                                        .background(isDarkMode ? Color.black.opacity(0.2) : Color.white.opacity(0.8))
                                        .cornerRadius(12)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
                        .cornerRadius(20)
                        .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 5)
                    }
                    .padding()
                }
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            // Using navigationBarItems instead of toolbar to fix ambiguity
            .navigationBarItems(trailing:
                Button(action: {
                    showingAddSheet = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.primary)
                }
            )
            .sheet(isPresented: $showingAddSheet) {
                AddPortfolioEntryView(
                    portfolioEntries: $portfolioEntries,
                    coins: coins,
                    coinData: coinData,
                    isDarkMode: isDarkMode
                )
            }
        }
    }
    
    // Sample data for chart - replace with actual historical portfolio data
    var samplePerformanceData: [PerformanceDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        
        var dataPoints: [PerformanceDataPoint] = []
        var currentValue = totalValue * 0.8  // Start at a lower value
        
        switch portfolioTimeframe {
        case .hour:
            // 12 5-minute points
            for minute in 0..<12 {
                guard let date = calendar.date(byAdding: .minute, value: -55 + (minute * 5), to: endDate) else { continue }
                
                // Add some random variation
                let randomChange = Double.random(in: -0.005...0.008)
                currentValue *= (1 + randomChange)
                
                dataPoints.append(PerformanceDataPoint(date: date, value: currentValue))
            }
        case .day:
            // 24 hourly points
            for hour in 0..<24 {
                guard let date = calendar.date(byAdding: .hour, value: -23 + hour, to: endDate) else { continue }
                
                // Add some random variation
                let randomChange = Double.random(in: -0.02...0.03)
                currentValue *= (1 + randomChange)
                
                dataPoints.append(PerformanceDataPoint(date: date, value: currentValue))
            }
        case .week:
            // 7 daily points
            for day in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: -6 + day, to: endDate) else { continue }
                
                let randomChange = Double.random(in: -0.05...0.07)
                currentValue *= (1 + randomChange)
                
                dataPoints.append(PerformanceDataPoint(date: date, value: currentValue))
            }
        case .month:
            // 30 daily points
            for day in 0..<30 {
                guard let date = calendar.date(byAdding: .day, value: -29 + day, to: endDate) else { continue }
                
                let randomChange = Double.random(in: -0.08...0.1)
                currentValue *= (1 + randomChange)
                
                dataPoints.append(PerformanceDataPoint(date: date, value: currentValue))
            }
        case .year, .all:
            // 12 monthly points
            for month in 0..<12 {
                guard let date = calendar.date(byAdding: .month, value: -11 + month, to: endDate) else { continue }
                
                let randomChange = Double.random(in: -0.12...0.15)
                currentValue *= (1 + randomChange)
                
                dataPoints.append(PerformanceDataPoint(date: date, value: currentValue))
            }
        }
        
        // Add current value as the last point
        dataPoints.append(PerformanceDataPoint(date: endDate, value: totalValue))
        
        return dataPoints
    }
}

struct AddPortfolioEntryView: View {
    @Binding var portfolioEntries: [PortfolioEntry]
    let coins: [(String, String)]
    let coinData: [String: CoinPriceData]
    let isDarkMode: Bool
    @State private var selectedCoinIndex = 0
    @State private var amount: String = ""
    @State private var purchasePrice: String = ""
    @State private var purchaseDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    var formattedCurrentPrice: String {
        let coinId = coins[selectedCoinIndex].1
        let price = coinData[coinId]?.price ?? 0
        return String(format: "%.6f", price)
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Coin selection
                        VStack(alignment: .leading) {
                            Text("Select Coin")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                            
                            Picker("Coin", selection: $selectedCoinIndex) {
                                ForEach(0..<coins.count, id: \.self) { index in
                                    HStack {
                                        Image(coinIcon(for: coins[index].1))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                        Text(coins[index].0)
                                    }
                                    .tag(index)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(height: 120)
                            
                            Text("Current price: $\(formattedCurrentPrice)")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                        }
                        .padding()
                        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
                        .cornerRadius(15)
                        
                        // Amount and purchase details
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading) {
                                Text("Amount")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                
                                HStack {
                                    TextField("0.0", text: $amount)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 20, weight: .medium))
                                        .padding()
                                        .background(Color(hex: isDarkMode ? "#1E293B" : "#F1F5F9"))
                                        .cornerRadius(10)
                                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                    
                                    Text(coins[selectedCoinIndex].0)
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Purchase Price (USD)")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                
                                HStack {
                                    TextField("0.0", text: $purchasePrice)
                                        .keyboardType(.decimalPad)
                                        .font(.system(size: 20, weight: .medium))
                                        .padding()
                                        .background(Color(hex: isDarkMode ? "#1E293B" : "#F1F5F9"))
                                        .cornerRadius(10)
                                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                    
                                    Button(action: {
                                        purchasePrice = formattedCurrentPrice
                                    }) {
                                        Text("Use Current")
                                            .font(.footnote)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(AppColors.primary)
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Purchase Date")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                
                                DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .labelsHidden()
                                    .frame(maxHeight: 120)
                            }
                        }
                        .padding()
                        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
                        .cornerRadius(15)
                        
                        // Add button
                        Button(action: {
                            addEntry()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Add to Portfolio")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.primary)
                                .cornerRadius(15)
                        }
                        .disabled(amount.isEmpty || purchasePrice.isEmpty)
                        .opacity(amount.isEmpty || purchasePrice.isEmpty ? 0.6 : 1)
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Holding")
            .navigationBarTitleDisplayMode(.inline)
            // Using navigationBarItems instead of toolbar to fix ambiguity
            .navigationBarItems(trailing:
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    func addEntry() {
        guard let amountValue = Double(amount),
              let priceValue = Double(purchasePrice),
              amountValue > 0, priceValue > 0 else {
            return
        }
        
        let newEntry = PortfolioEntry(
            coinId: coins[selectedCoinIndex].1,
            amount: amountValue,
            purchasePrice: priceValue,
            purchaseDate: purchaseDate
        )
        
        portfolioEntries.append(newEntry)
    }
}
