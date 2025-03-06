//
//  SettingsView.swift
//  CryptoTrade
//
//  Created by Said Zaripov on 2025-03-06.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isDarkMode: Bool
    @Binding var alertThreshold: Double
    @Binding var isChecking: Bool
    let checkStreak: Int
    @State private var showingResetAlert = false
    @State private var showingDonationInfo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Direct background instead of using BackgroundView
                if isDarkMode {
                    AppColors.darkBackground.ignoresSafeArea()
                } else {
                    AppColors.lightBackground.ignoresSafeArea()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Appearance settings
                        SettingsSection(title: "Appearance", isDarkMode: isDarkMode) {
                            Toggle("Dark Mode", isOn: $isDarkMode)
                                .padding(.vertical, 5)
                        }
                        
                        // Alert settings
                        SettingsSection(title: "Alerts", isDarkMode: isDarkMode) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Price Change Alert Threshold: \(Int(alertThreshold))%")
                                    .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                
                                Slider(value: $alertThreshold, in: 1...20, step: 1)
                                    .accentColor(AppColors.primary)
                                
                                Toggle("Auto-check Prices", isOn: $isChecking)
                                    .padding(.vertical, 5)
                            }
                        }
                        
                        // Account Stats
                        SettingsSection(title: "Stats", isDarkMode: isDarkMode) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Check Streak")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                    Text("\(checkStreak) days")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "flame.fill")
                                    .foregroundColor(AppColors.highlight)
                                    .font(.system(size: 24))
                            }
                        }
                        
                        // Support
                        SettingsSection(title: "Support", isDarkMode: isDarkMode) {
                            Button(action: {
                                showingDonationInfo = true
                            }) {
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(AppColors.alert)
                                    Text("Support the Developer")
                                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                }
                            }
                            
                            Divider()
                                .padding(.vertical, 5)
                            
                            Button(action: {
                                // Rate app action
                            }) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(AppColors.highlight)
                                    Text("Rate the App")
                                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                                }
                            }
                        }
                        
                        // About
                        SettingsSection(title: "About", isDarkMode: isDarkMode) {
                            HStack {
                                Text("Version")
                                    .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                                Spacer()
                                Text("2.0.0")
                                    .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                            }
                            
                            Divider()
                                .padding(.vertical, 5)
                            
                            Button(action: {
                                showingResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                        .foregroundColor(AppColors.alert)
                                    Text("Reset App Data")
                                        .foregroundColor(AppColors.alert)
                                    Spacer()
                                }
                            }
                        }
                        
                        Text("CryptoTrade © 2025")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                            .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingResetAlert) {
                Alert(
                    title: Text("Reset App Data"),
                    message: Text("This will reset all your settings and data. This action cannot be undone."),
                    primaryButton: .destructive(Text("Reset")) {
                        // Reset app data action
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $showingDonationInfo) {
                DonationView(isDarkMode: isDarkMode)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let isDarkMode: Bool
    let content: Content
    
    init(title: String, isDarkMode: Bool, @ViewBuilder content: () -> Content) {
        self.title = title
        self.isDarkMode = isDarkMode
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.primary)
                .padding(.bottom, 5)
            
            content
        }
        .padding()
        .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
        .cornerRadius(15)
        .shadow(color: isDarkMode ? .black.opacity(0.3) : .gray.opacity(0.2), radius: 3)
    }
}

struct DonationView: View {
    let isDarkMode: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var showingCopiedAlert = false
    
    let walletAddress = "bc1qx75gmtrrzscahrgl9rcvllpke5fallsaxvskmc"
    
    var body: some View {
        NavigationView {
            ZStack {
                // Direct background instead of using BackgroundView
                if isDarkMode {
                    AppColors.darkBackground.ignoresSafeArea()
                } else {
                    AppColors.lightBackground.ignoresSafeArea()
                }
                
                VStack(spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.alert)
                        .padding()
                    
                    Text("Support the Developer")
                        .font(.title)
                        .bold()
                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                    
                    Text("If you enjoy using CryptoTrade, please consider supporting future development with a small cryptocurrency donation.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                        .padding()
                    
                    VStack(spacing: 15) {
                        Text("Bitcoin (BTC)")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                        
                        Text(walletAddress)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(isDarkMode ? Color.black.opacity(0.3) : Color.black.opacity(0.05))
                            .cornerRadius(10)
                            .foregroundColor(AppColors.textPrimary(isDark: isDarkMode))
                        
                        Button(action: {
                            UIPasteboard.general.string = walletAddress
                            showingCopiedAlert = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showingCopiedAlert = false
                            }
                        }) {
                            Text("Copy Address")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(AppColors.primary)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(isDarkMode ? AppColors.darkSurface : AppColors.lightSurface)
                    .cornerRadius(15)
                    
                    Spacer()
                    
                    Text("Thank you for your support!")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary(isDark: isDarkMode))
                }
                .padding()
                .overlay(
                    Group {
                        if showingCopiedAlert {
                            Text("Address copied!")
                                .font(.headline)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                    },
                    alignment: .center
                )
            }
            .navigationTitle("Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
