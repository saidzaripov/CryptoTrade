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
    @State private var coinData: [String: CoinPriceData] = [:]
    @State private var statusMessage: String = "Welcome to your Crypto Bot!"
    @State private var showAlertFlash: Bool = false
    @State private var timer: Timer? = nil
    @State private var isChecking: Bool = false
    @State private var alertThreshold: Double = 5.0
    @State private var selectedChartCoin: String = "dogecoin"
    @State private var chartData: [ChartDataPoint] = []
    @State private var lastChartFetch: Date? = nil
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showConfetti: Bool = false
    @State private var showChartFullscreen: Bool = false
    @State private var isDarkMode: Bool = true
    @State private var checkStreak: Int = 0
    @State private var lastCheckDate: Date? = nil
    
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
        ZStack {
            BackgroundView(isDarkMode: isDarkMode)
            
            ScrollView {
                VStack(spacing: 20) {
                    StatusMessageView(statusMessage: $statusMessage, showAlertFlash: $showAlertFlash, isDarkMode: isDarkMode)
                    
                    CoinListView(
                        coins: coins,
                        coinData: coinData,
                        alertThreshold: alertThreshold,
                        selectedChartCoin: $selectedChartCoin,
                        showChartFullscreen: $showChartFullscreen,
                        isDarkMode: isDarkMode
                    )
                    
                    ChartView(
                        selectedChartCoin: $selectedChartCoin,
                        chartData: $chartData,
                        coins: coins,
                        fetchChartData: fetchChartDataIfNeeded,
                        isDarkMode: isDarkMode
                    )
                    
                    SettingsAndExtrasView(
                        isDarkMode: $isDarkMode,
                        checkStreak: checkStreak,
                        tipAction: {
                            let walletAddress = "bc1qx75gmtrrzscahrgl9rcvllpke5fallsaxvskmc" // Replace with your wallet
                            statusMessage = "Support the Dev! Send crypto to $BTC address: \(walletAddress)"
                        }
                    )
                    
                    ControlButtons(
                        isChecking: $isChecking,
                        checkAction: {
                            checkPrices()
                            fetchChartDataIfNeeded(force: true)
                            updateStreak()
                        },
                        toggleChecking: { isChecking in
                            if isChecking { stopChecking() } else { startChecking() }
                        }
                    )
                }
                .padding()
            }
            
            if showConfetti {
                ConfettiView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            showConfetti = false
                        }
                    }
            }
        }
        .onAppear {
            setupAudio()
            requestNotificationPermission()
            fetchChartDataIfNeeded()
            updateStreak()
        }
        .sheet(isPresented: $showChartFullscreen) {
            FullscreenChartView(
                chartData: chartData,
                coinName: coins.first { $1 == selectedChartCoin }?.0 ?? "Coin",
                isDarkMode: isDarkMode
            )
        }
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
            fetchChartDataIfNeeded()
            updateStreak()
        }
        checkPrices()
        fetchChartDataIfNeeded()
        updateStreak()
    }
    
    func stopChecking() {
        isChecking = false
        timer?.invalidate()
        timer = nil
        statusMessage = "Price checks stopped."
    }
    
    func checkPrices(retryCount: Int = 3) {
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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON (prices): \(jsonString)")
            }
            
            if httpResponse.statusCode == 429, retryCount > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) { // Wait 60s before retry
                    self.checkPrices(retryCount: retryCount - 1)
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
                    if !triggeredAlerts.isEmpty {
                        self.statusMessage += " Alerts: \(triggeredAlerts.joined(separator: ", "))"
                        self.showAlertFlash = true
                        self.showConfetti = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
    
    func fetchChartDataIfNeeded(force: Bool = false) {
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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON (chart): \(jsonString)")
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
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
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

// Sub-Views
struct BackgroundView: View {
    let isDarkMode: Bool
    
    var body: some View {
        if isDarkMode {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0D1B2A"), Color(hex: "#1E3050")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        } else {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#F8F1E9"), Color(hex: "#EADBC8")]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
}

struct StatusMessageView: View {
    @Binding var statusMessage: String
    @Binding var showAlertFlash: Bool
    let isDarkMode: Bool
    
    var body: some View {
        Text(statusMessage)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundColor(isDarkMode ? .white : .black)
            .padding()
            .background(showAlertFlash ? Color(hex: "#FF6B6B").opacity(0.7) : (isDarkMode ? Color(hex: "#D9E6F2").opacity(0.9) : Color(hex: "#F5F5F5").opacity(0.9)))
            .cornerRadius(12)
            .shadow(radius: 5)
            .animation(.easeInOut(duration: 0.5), value: showAlertFlash)
    }
}

struct CoinListView: View {
    let coins: [(String, String)]
    let coinData: [String: CoinPriceData]
    let alertThreshold: Double
    @Binding var selectedChartCoin: String
    @Binding var showChartFullscreen: Bool
    let isDarkMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(coins, id: \.1) { (name, id) in
                let price = coinData[id]?.price ?? 0.0
                let change = coinData[id]?.change ?? 0.0
                HStack {
                    Image(coinIcon(for: id))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    VStack(alignment: .leading) {
                        Text("\(name) Price: $\(price, specifier: "%.6f")")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        HStack {
                            Text("24h: \(change, specifier: "%.2f")%")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(change >= 0 ? Color(hex: "#FFEE58") : Color(hex: "#FF6B6B"))
                                .bold(abs(change) >= alertThreshold)
                            Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                .foregroundColor(change >= 0 ? Color(hex: "#FFEE58") : Color(hex: "#FF6B6B"))
                                .animation(.spring(), value: change)
                        }
                    }
                    Spacer()
                }
                .padding()
                .background(abs(change) >= alertThreshold ? Color(hex: "#FFEE58").opacity(0.3) : (isDarkMode ? Color(hex: "#D9E6F2").opacity(0.8) : Color(hex: "#F5F5F5").opacity(0.8)))
                .cornerRadius(12)
                .shadow(radius: 3)
                .transition(.scale)
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedChartCoin = id
                    }
                }
                .onLongPressGesture(minimumDuration: 0.5) {
                    withAnimation {
                        showChartFullscreen = true
                    }
                }
            }
        }
        .padding(.vertical)
        .animation(.spring(), value: coinData)
    }
    
    func coinIcon(for id: String) -> String {
        switch id {
        case "bitcoin": return "btc"
        case "ethereum": return "eth"
        case "dogecoin": return "doge"
        case "shiba-inu": return "shib"       // Fixed icon name
        case "pepe": return "pepe"             // Fixed icon name
        case "bonk": return "bonk"             // Fixed icon name
        case "floki-inu": return "floki"       // Fixed icon name
        case "dogwifhat": return "wif"         // Fixed icon name
        case "solana": return "sol"         // Fixed icon name (removed "solana-sol-icon")
        case "xrp": return "xrp"               // Fixed icon name (removed "xrp-coin-icon")
        case "cardano": return "ada"       // Fixed icon name (removed "cardano-ada-icon")
        case "tether": return "tether-usdt-icon"         // Fixed icon name (removed "tether-usdt-icon")
        default: return "default_coin_icon"
        }
    }
}

struct ChartView: View {
    @Binding var selectedChartCoin: String
    @Binding var chartData: [ChartDataPoint]
    let coins: [(String, String)]
    let fetchChartData: (Bool) -> Void
    let isDarkMode: Bool
    
    var body: some View {
        VStack {
            Picker("Chart Coin", selection: $selectedChartCoin) {
                ForEach(coins, id: \.1) { (name, id) in
                    Text(name)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .tag(id)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(isDarkMode ? Color(hex: "#D9E6F2").opacity(0.9) : Color(hex: "#F5F5F5").opacity(0.9))
            .cornerRadius(10)
            .onChange(of: selectedChartCoin) { _ in
                fetchChartData(false)
            }
            
            if chartData.isEmpty {
                Text("Loading chart for \(coins.first { $1 == selectedChartCoin }?.0 ?? "coin")...")
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(isDarkMode ? Color(hex: "#D9E6F2").opacity(0.3) : Color(hex: "#F5F5F5").opacity(0.3))
                    .cornerRadius(10)
            } else {
                Chart {
                    ForEach(chartData, id: \.time) { dataPoint in
                        LineMark(
                            x: .value("Time", Date(timeIntervalSince1970: dataPoint.time)),
                            y: .value("Price", dataPoint.price)
                        )
                        .foregroundStyle(Color(hex: "#00C2A8"))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 4)) { value in
                        AxisValueLabel()
                            .foregroundStyle(isDarkMode ? .white : .black)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel()
                            .foregroundStyle(isDarkMode ? .white : .black)
                    }
                }
                .frame(height: 200)
                .padding()
                .background(isDarkMode ? Color(hex: "#D9E6F2").opacity(0.9) : Color(hex: "#F5F5F5").opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 5)
                .overlay(
                    Text("24h Price: \(coins.first { $1 == selectedChartCoin }?.0 ?? "Coin")")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding(5),
                    alignment: .topLeading
                )
                .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: chartData)
    }
}

struct FullscreenChartView: View {
    let chartData: [ChartDataPoint]
    let coinName: String
    let isDarkMode: Bool
    @Environment(\.dismiss) var dismiss // Added to dismiss the sheet
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(isDarkMode ? Color(hex: "#0D1B2A") : Color(hex: "#F8F1E9")).ignoresSafeArea()
                
                Chart {
                    ForEach(chartData, id: \.time) { dataPoint in
                        LineMark(
                            x: .value("Time", Date(timeIntervalSince1970: dataPoint.time)),
                            y: .value("Price", dataPoint.price)
                        )
                        .foregroundStyle(Color(hex: "#00C2A8"))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .hour, count: 4)) { value in
                        AxisValueLabel()
                            .foregroundStyle(isDarkMode ? .white : .black)
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { value in
                        AxisValueLabel()
                            .foregroundStyle(isDarkMode ? .white : .black)
                    }
                }
                .padding()
                .background(isDarkMode ? Color(hex: "#D9E6F2").opacity(0.9) : Color(hex: "#F5F5F5").opacity(0.9))
                .cornerRadius(12)
                .shadow(radius: 5)
                
                VStack {
                    Text("Fullscreen Chart: \(coinName)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss() // Dismiss the fullscreen sheet
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(isDarkMode ? .white : .black)
                            .padding()
                            .background(Color(hex: "#FF6B6B"))
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ConfettiView: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50) { _ in
                Circle()
                    .foregroundColor([Color(hex: "#FFEE58"), Color(hex: "#FF6B6B"), Color(hex: "#00C2A8")].randomElement()!)
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

struct SettingsAndExtrasView: View {
    @Binding var isDarkMode: Bool
    let checkStreak: Int
    let tipAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Toggle("Dark Mode", isOn: $isDarkMode)
                .padding()
                .background(isDarkMode ? Color(hex: "#D9E6F2").opacity(0.9) : Color(hex: "#F5F5F5").opacity(0.9))
                .cornerRadius(10)
                .foregroundColor(isDarkMode ? .black : .white)
                .font(.system(size: 16, design: .rounded))
            
            Text("Check Streak: \(checkStreak) Days")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(isDarkMode ? .white : .black)
                .padding()
                .background(Color(hex: "#FFEE58").opacity(0.7))
                .cornerRadius(10)
                .shadow(radius: 3)
            
            Button(action: tipAction) {
                Text("Support the Dev")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#00C2A8"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
            }
        }
    }
}

struct ControlButtons: View {
    @Binding var isChecking: Bool
    let checkAction: () -> Void
    let toggleChecking: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                toggleChecking(isChecking)
            }) {
                Text(isChecking ? "Stop Checking" : "Start Checking")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isChecking ? Color(hex: "#FF6B6B") : Color(hex: "#FFEE58"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .scaleEffect(isChecking ? 1.05 : 1.0)
            .animation(.spring(), value: isChecking)
            
            Button(action: checkAction) {
                Text("Check Prices Now")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "#00C2A8"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
            }
        }
    }
}

struct ChartResponse: Codable {
    let prices: [[Double]]
    let marketCaps: [[Double]]?
    let totalVolumes: [[Double]]?
    
    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }
}

struct ErrorResponse: Codable {
    let status: ErrorStatus
    
    struct ErrorStatus: Codable {
        let errorCode: Int
        let errorMessage: String
        
        enum CodingKeys: String, CodingKey {
            case errorCode = "error_code"
            case errorMessage = "error_message"
        }
    }
}

struct CoinData: Codable {
    let id: String
    let symbol: String?
    let name: String?
    let currentPrice: Double?
    let priceChangePercentage24h: Double?
    let priceChangePercentage1h: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case symbol
        case name
        case currentPrice = "current_price"
        case priceChangePercentage24h = "price_change_percentage_24h"
        case priceChangePercentage1h = "price_change_percentage_1h_in_currency"
    }
}

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

struct CoinPriceData: Equatable {
    let price: Double
    let change: Double
}

struct ChartDataPoint: Equatable {
    let time: Double
    let price: Double
}
