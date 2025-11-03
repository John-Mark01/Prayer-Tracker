import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    private let totalPages = 5

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
                .padding(.top, 60)
                .padding(.horizontal, 24)
            
            // Pages
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                OnboardingPageView(
                    icon: "Onboarding/happy",
                    title: "Hello There! 👋",
                    message: "Welcome to Prayer Tracker. An app designed for christians to help them build the habit of Prayer."
                )
                .tag(0)
                
                // Page 2: Problem Identification
                OnboardingPageView(
                    icon: "Onboarding/struggle",
                    title: "Struggling to Pray Daily?",
                    message: "In a world full of distractions we sometimes forget what is most important for christians — Prayer!"
                )
                .tag(1)
                
                // Page 3: Social Proof
                OnboardingPageView(
                    icon: "Onboarding/depressed",
                    title: "You are not alone",
                    message: "Did you know that only 16% of pastors in the US are NOT satisfied with their prayer life, and more than 35% of christians don't pray daily!"
                )
                .tag(2)
                
                // Page 4: Core Features
                OnboardingPageView(
                    icon: "Onboarding/support",
                    title: "Stay on Track",
                    message: "Prayer Tracker will help you track your prayer life, set reminders, and help you stay focused on what's most important to you."
                )
                .tag(3)
                
                // Page 5: Advanced Features
                OnboardingPageView(
                    icon: "Onboarding/praying_woman",
                    title: "Prayer Made Easy",
                    message: "Get Live Activity notifications, add Widgets to your home screen, and share your data across all of your devices."
                )
                .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.bouncy, value: currentPage)
            .padding(.horizontal, 16)
            
            // Bottom buttons
            bottomButtons
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
        .background(Color("Onboarding/background"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Progress Bar
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("Onboarding/backgroundSecondary"))
                    .frame(height: 8)

                // Progress
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.appTint.opacity(0.5), .appTint],
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
                        colors: [.appTint.opacity(0.5), .appTint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
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
