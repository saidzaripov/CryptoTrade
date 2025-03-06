//
//  ContentView.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-05.
//

import SwiftUI
import Charts
import AVFoundation
import UserNotifications

struct ContentView: View {
    // State variables
    @State private var selectedTab = 0
    @State private var coinData: [String: CoinPriceData] = [:]
    @State private var statusMessage: String = "Welcome to CryptoTrade!"
    @State private var showAlertFlash: Bool = false
    @State private var isChecking: Bool = false
    @State private var alertThreshold: Double = 5.0
    @State private var selectedChartCoin: String = "bitcoin"
    @State private var chartData: [ChartDataPoint] = []
    @State private var portfolioEntries: [PortfolioEntry] = []
    @State private var lastChartFetch: Date? = nil
    @State private var showConfetti: Bool = false
    @State private var timer: Timer? = nil
    @State private var checkStreak: Int = 0
    @State private var lastCheckDate: Date? = nil
    @State private var isDarkMode: Bool = true
    @State private var audioPlayer: AVAudioPlayer?
    
    // Data constants
    let coins = [
        ("Bitcoin", "bitcoin"),
        ("Ethereum", "ethereum"),
        ("Dogecoin", "dogecoin"),
        ("Shiba Inu", "shiba-inu"),
        ("Pepe", "pepe"),
        ("BONK", "bonk"),
        ("FLOKI", "floki-inu"),
        ("WIF", "dogwifhat"),
        ("Solana", "solana"),
        ("XRP", "xrp"),
        ("Cardano", "cardano"),
        ("Tether", "tether")
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MarketView(
                coins: coins,
                coinData: coinData,
                alertThreshold: alertThreshold,
                selectedChartCoin: $selectedChartCoin,
                selectedTab: $selectedTab,
                isDarkMode: isDarkMode,
                refreshAction: checkPrices
            )
            .tabItem {
                Label("Market", systemImage: "chart.bar.fill")
            }
            .tag(0)
            
            ChartTabView(
                selectedChartCoin: $selectedChartCoin,
                chartData: $chartData,
                coins: coins,
                isDarkMode: isDarkMode
            )
            .tabItem {
                Label("Chart", systemImage: "chart.xyaxis.line")
            }
            .tag(1)
            
            PortfolioView(
                portfolioEntries: $portfolioEntries,
                coinData: coinData,
                coins: coins,
                isDarkMode: isDarkMode
            )
            .tabItem {
                Label("Portfolio", systemImage: "briefcase.fill")
            }
            .tag(2)
            
            NewsView(isDarkMode: isDarkMode)
            .tabItem {
                Label("News", systemImage: "newspaper.fill")
            }
            .tag(3)
            
            SettingsView(
                isDarkMode: $isDarkMode,
                alertThreshold: $alertThreshold,
                isChecking: $isChecking,
                checkStreak: checkStreak
            )
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(4)
        }
        .accentColor(AppColors.primary)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .overlay(
            StatusToast(message: statusMessage, isVisible: showAlertFlash)
                .padding(.top, 10),
            alignment: .top
        )
        .overlay(
            ZStack {
                if showConfetti {
                    ConfettiView(isDarkMode: isDarkMode)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showConfetti = false
                            }
                        }
                }
            }
        )
        .onChange(of: isChecking) { newValue in
            if newValue {
                startChecking()
            } else {
                stopChecking()
            }
        }
        .onAppear {
            setupApp()
        }
    }
    
    func setupApp() {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
        
        // Setup audio
        setupAudio()
        
        // Initialize all the data
        checkPrices()
        fetchChartData()
        updateStreak()
    }
    
    func setupAudio() {
        guard let url = Bundle.main.url(forResource: "alert", withExtension: "mp3") else {
            print("Alert sound file not found!")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio: \(error.localizedDescription)")
        }
    }
    
    func playAlertSound() {
        audioPlayer?.currentTime = 0
        audioPlayer?.play()
    }
    
    func triggerVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func updateStreak() {
        guard let lastCheck = lastCheckDate else {
            checkStreak = 1
            lastCheckDate = Date()
            return
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(lastCheck) {
            // Already checked today, no change
        } else if calendar.isDateInYesterday(lastCheck) {
            checkStreak += 1
        } else {
            checkStreak = 1
        }
        lastCheckDate = Date()
    }
    
    func startChecking() {
        isChecking = true
        statusMessage = "Starting price checks every 120 seconds..."
        timer = Timer.scheduledTimer(withTimeInterval: 120.0, repeats: true) { _ in
            checkPrices()
            fetchChartData()
            updateStreak()
        }
        checkPrices()
        fetchChartData()
        updateStreak()
        
        // Show toast message
        showAlertFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showAlertFlash = false
        }
    }
    
    func stopChecking() {
        isChecking = false
        timer?.invalidate()
        timer = nil
        statusMessage = "Price checks stopped."
        
        // Show toast message
        showAlertFlash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showAlertFlash = false
        }
    }
    
    // This is the function that will be passed to MarketView
    func checkPrices() {
        // Call the function with retry logic
        checkPricesWithRetry(retryCount: 3)
    }
    
    func checkPricesWithRetry(retryCount: Int = 3) {
        statusMessage = "Fetching prices for all coins..."
        let coinIds = coins.map { $1 }.joined(separator: ",")
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=\(coinIds)") else {
            statusMessage = "Invalid URL!"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.statusMessage = "No data received!"
                }
                return
            }
            
            if httpResponse.statusCode == 429, retryCount > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) { // Wait 60s before retry
                    self.checkPricesWithRetry(retryCount: retryCount - 1)
                }
                return
            }
            
            do {
                let json = try JSONDecoder().decode([CoinData].self, from: data)
                DispatchQueue.main.async {
                    var newCoinData: [String: CoinPriceData] = [:]
                    var triggeredAlerts: [String] = []
                    for coin in json {
                        let change = coin.priceChangePercentage24h ?? 0.0
                        let price = coin.currentPrice ?? 0.0
                        newCoinData[coin.id] = CoinPriceData(price: price, change: change)
                        if abs(change) >= self.alertThreshold {
                            triggeredAlerts.append(coin.name ?? coin.id)
                        }
                    }
                    self.coinData = newCoinData
                    self.statusMessage = "Prices updated!"
                    
                    // Update portfolio entries with current prices
                    for i in 0..<self.portfolioEntries.count {
                        if let price = newCoinData[self.portfolioEntries[i].coinId]?.price {
                            var entry = self.portfolioEntries[i]
                            entry.updateValues(with: price)
                            self.portfolioEntries[i] = entry
                        }
                    }
                    
                    if !triggeredAlerts.isEmpty {
                        self.statusMessage += " Alerts: \(triggeredAlerts.joined(separator: ", "))"
                        self.showAlertFlash = true
                        self.showConfetti = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.showAlertFlash = false
                        }
                        self.playAlertSound()
                        self.triggerVibration()
                        self.scheduleNotification(for: triggeredAlerts)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusMessage = "JSON error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchChartData(force: Bool = false) {
        let now = Date()
        if !force, let lastFetch = lastChartFetch, now.timeIntervalSince(lastFetch) < 300 {
            statusMessage = "Using cached chart for \(coins.first { $1 == selectedChartCoin }?.0 ?? "coin")"
            return
        }
        
        statusMessage = "Fetching chart data for \(coins.first { $1 == selectedChartCoin }?.0 ?? "coin")..."
        guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(selectedChartCoin)/market_chart?vs_currency=usd&days=1") else {
            statusMessage = "Invalid chart URL!"
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.statusMessage = "Chart network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.statusMessage = "No chart data received!"
                }
                return
            }
            
            do {
                let json = try JSONDecoder().decode(ChartResponse.self, from: data)
                DispatchQueue.main.async {
                    self.chartData = json.prices.map { ChartDataPoint(time: $0[0] / 1000, price: $0[1]) }
                    self.lastChartFetch = Date()
                    self.statusMessage = "Chart updated for \(self.coins.first { $1 == self.selectedChartCoin }?.0 ?? "coin")!"
                }
            } catch {
                DispatchQueue.main.async {
                    do {
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        self.statusMessage = "Chart error: \(errorResponse.status.errorMessage). Wait a minute and try again."
                    } catch {
                        self.statusMessage = "Chart JSON error: \(error.localizedDescription)"
                    }
                }
            }
        }.resume()
    }
    
    func scheduleNotification(for coins: [String]) {
        let content = UNMutableNotificationContent()
        content.title = "Crypto Alert!"
        content.body = "Price change exceeded \(alertThreshold)% for: \(coins.joined(separator: ", "))"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}
