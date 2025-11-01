import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    private let totalPages = 5

    var body: some View {
        ZStack {
            // Background
            Color(white: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                progressBar
                    .padding(.top, 60)
                    .padding(.horizontal, 24)

                // Pages
                TabView(selection: $currentPage) {
                    // Page 1: Welcome
                    OnboardingPageView(
                        icon: "hands.sparkles",
                        title: "Welcome to Prayer Tracker",
                        message: "Build a lasting habit of daily prayer"
                    )
                    .tag(0)

                    // Page 2: Problem Identification
                    OnboardingPageView(
                        icon: "calendar.badge.exclamationmark",
                        title: "Struggling to Pray Daily?",
                        message: "Life gets busy and it's easy to forget what matters most. You're not alone."
                    )
                    .tag(1)

                    // Page 3: Social Proof
                    OnboardingPageView(
                        icon: "chart.bar.fill",
                        title: "You're Not Alone",
                        message: "Only 20% of Christians pray every day. The others struggle to find time because of digital distractions."
                    )
                    .tag(2)

                    // Page 4: Core Features
                    OnboardingPageView(
                        icon: "checkmark.circle.fill",
                        title: "Stay on Track",
                        message: "Set prayer needs, create alarms, focus on priorities, and track your daily progress."
                    )
                    .tag(3)

                    // Page 5: Advanced Features
                    OnboardingPageView(
                        icon: "bell.badge.fill",
                        title: "Prayer Made Easy",
                        message: "Get Live Activity notifications and add widgets to your home screen for quick access."
                    )
                    .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                .padding(.horizontal, 16)

                // Bottom buttons
                bottomButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 8)

                // Progress
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FF9F80"), Color(hex: "#FF7B5F")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(currentPage + 1) / CGFloat(totalPages), height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentPage)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Bottom Buttons
    private var bottomButtons: some View {
        VStack(spacing: 12) {
            // Next / Get Started button
            Button {
                if currentPage < totalPages - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    // Complete onboarding
                    completeOnboarding()
                }
            } label: {
                Text(currentPage == totalPages - 1 ? "Get Started" : "Next")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#FF9F80"), Color(hex: "#FF7B5F")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // Skip button (only on last page)
            if currentPage == totalPages - 1 {
                Button {
                    completeOnboarding()
                } label: {
                    Text("Skip for Now")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    // MARK: - Actions
    private func completeOnboarding() {
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
}
