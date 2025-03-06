//
//  Models.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//

import SwiftUI

// MARK: - Data Models

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

struct CoinPriceData: Equatable {
    let price: Double
    let change: Double
}

struct ChartDataPoint: Equatable {
    let time: Double
    let price: Double
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

// New Data Models for Portfolio
struct PortfolioEntry: Identifiable {
    let id = UUID()
    let coinId: String
    var amount: Double
    var purchasePrice: Double
    var purchaseDate: Date
    
    var currentValue: Double = 0
    var profitLoss: Double = 0
    var profitLossPercentage: Double = 0
    
    mutating func updateValues(with currentPrice: Double) {
        currentValue = amount * currentPrice
        profitLoss = currentValue - (amount * purchasePrice)
        profitLossPercentage = ((currentPrice / purchasePrice) - 1) * 100
    }
}

struct PerformanceDataPoint {
    let date: Date
    let value: Double
}

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let date: Date
    let imageUrl: String
    let url: String
    let sentiment: NewsSentiment
    
    enum NewsSentiment {
        case positive
        case neutral
        case negative
    }
}

enum TimeFrame: String, CaseIterable, Identifiable {
    case hour = "1H"
    case day = "24H"
    case week = "7D"
    case month = "30D"
    case year = "1Y"
    case all = "ALL"
    
    var id: String { self.rawValue }
    
    var days: String {
        switch self {
        case .hour: return "0.042" // 1h = 0.042 days
        case .day: return "1"
        case .week: return "7"
        case .month: return "30"
        case .year: return "365"
        case .all: return "max"
        }
    }
}
