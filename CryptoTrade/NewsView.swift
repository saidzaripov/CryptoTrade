//
//  NewsView.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//

import SwiftUI

struct NewsView: View {
    let isDarkMode: Bool
    @State private var newsItems: [NewsItem] = []
    @State private var isLoading = true
    
    // Simulated news data
    let sampleNews = [
        NewsItem(
            title: "Bitcoin Surges Past $60,000 as Institutional Adoption Grows",
            source: "CryptoNews",
            date: Date().addingTimeInterval(-3600 * 2),
            imageUrl: "btc",
            url: "https://example.com/news/1",
            sentiment: .positive
        ),
        NewsItem(
            title: "Ethereum Upgrade Planned for Q3, Promises Lower Gas Fees",
            source: "BlockchainToday",
            date: Date().addingTimeInterval(-3600 * 5),
            imageUrl: "eth",
            url: "https://example.com/news/2",
            sentiment: .positive
        ),
        NewsItem(
            title: "Regulatory Concerns Grow as Countries Consider Crypto Restrictions",
            source: "CryptoInsider",
            date: Date().addingTimeInterval(-3600 * 8),
            imageUrl: "btc",
            url: "https://example.com/news/3",
            sentiment: .negative
        ),
        NewsItem(
            title: "NFT Market Showing Signs of Recovery After Months of Decline",
            source: "NFTDaily",
            date: Date().addingTimeInterval(-3600 * 12),
            imageUrl: "eth",
            url: "https://example.com/news/4",
            sentiment: .neutral
        ),
        NewsItem(
            title: "Dogecoin Community Funds New Development Initiative",
            source: "MemeCoins",
            date: Date().addingTimeInterval(-3600 * 24),
            imageUrl: "doge",
            url: "https://example.com/news/5",
            sentiment: .positive
        )
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView(isDarkMode: isDarkMode)
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading news...")
                            .padding()
                            .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(newsItems) { item in
                                NewsItemView(item: item, isDarkMode: isDarkMode)
                            }
                            
                            Button(action: {
                                // Load more news
                            }) {
                                Text("Load More")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primary)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Crypto News")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Simulate loading news
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    newsItems = sampleNews
                    isLoading = false
                }
            }
        }
    }
}

struct NewsItemView: View {
    let item: NewsItem
    let isDarkMode: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(item.imageUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading) {
                    Text(item.source)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                    
                    Text(item.date.timeAgoDisplay())
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                }
                
                Spacer()
                
                // Sentiment indicator
                Circle()
                    .fill(sentimentColor(item.sentiment))
                    .frame(width: 10, height: 10)
            }
            
            Text(item.title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            Button(action: {
                // Open the URL - in a real app, use Safari or webview
                if let url = URL(string: item.url) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Read more")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
        }
        .padding()
        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
        .cornerRadius(15)
        .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 5)
    }
    
    func sentimentColor(_ sentiment: NewsItem.NewsSentiment) -> Color {
        switch sentiment {
        case .positive:
            return AppColors.success
        case .neutral:
            return AppColors.highlight
        case .negative:
            return AppColors.alert
        }
    }
}
