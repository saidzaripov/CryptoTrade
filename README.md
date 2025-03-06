
     MIT License

     Copyright (c) 2025 Said Zaripov

     Permission is hereby granted, free of charge, to any person obtaining a copy
     of this software and associated documentation files (the "Software"), to deal
     in the Software without restriction, including without limitation the rights
     to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
     copies of the Software, and to permit persons to whom the Software is
     furnished to do so, subject to the following conditions:

     The above copyright notice and this permission notice shall be included in all
     copies or substantial portions of the Software.

     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
     OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
     SOFTWARE.
     ```

#### Project Overview 
CryptoBot is a SwiftUI iOS app I built to make cryptocurrency tracking fun and engaging. It pulls real-time prices from the CoinGecko API for coins like Bitcoin, Ethereum, Solana,
and more, showing 24-hour charts and sending alerts when prices change significantly. What sets it apart is its modern, Apple-inspired design with dark/light mode, gamified streaks for daily checks, 
and a crypto tipping feature to support the developer. It’s perfect for crypto enthusiasts who want a sleek, interactive way to stay updated on the market.

#### Key Highlights
- **Purpose:** I created CryptoBot to solve the problem of tracking multiple cryptocurrencies in a visually appealing, user-friendly way. Unlike bulky apps, it focuses on simplicity and engagement.
- **Core Features:** It offers real-time price tracking, interactive charts, price alerts with sound and confetti, a dark/light mode toggle, daily check streaks, and a crypto tipping option.
- **Design:** The UI is inspired by apps like Shakepay and Robinhood, with a clean, Apple-like aesthetic—rounded corners, subtle shadows, and vibrant colors (coral, yellow, teal).
- **Tech Stack:** Built with SwiftUI for a modern iOS experience, using the CoinGecko API for data, AVFoundation for sound, and SwiftUI Charts for visualizations.
- **Challenges:** One challenge was handling CoinGecko API rate limits, which I mitigated by adding retry logic and a 120-second update interval. Another was ensuring a smooth UI with animations, which SwiftUI made easy.
- **Future Plans:** I’d like to add a premium subscription for faster updates, integrate ads, and include social sharing for price alerts.

#### Why It’s Special
CryptoBot isn’t just a price tracker—it’s an experience. The gamified streaks keep users coming back, the confetti animations make alerts exciting, and the design feels premium.
Plus, it supports smaller coins alongside majors like Bitcoin and Solana, catering to a wide audience.

#### Potential Use Cases
- **Crypto Enthusiasts:** Stay updated on your favorite coins with real-time prices and charts.
- **Casual Investors:** Set alerts to know when to buy or sell based on price changes.
- **Developers:** Learn how to build a SwiftUI app with API integration, animations, and notifications.

#### Technical Deep Dive (for Developers)
- **Architecture:** The app uses a single `ContentView` with modular sub-views (`CoinListView`, `ChartView`, etc.) for maintainability. State is managed using `@State` and `@Binding`.
- **API Integration:** Fetches data from CoinGecko using `URLSession`, with retry logic for rate limits.
- **Animations:** Leverages SwiftUI’s `.spring()` animations for interactive taps and transitions.
- **Challenges:** Handling API rate limits required careful throttling, and ensuring smooth chart rendering needed efficient data mapping

---
