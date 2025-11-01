import SwiftUI

struct OnboardingPageView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: icon)
                .font(.system(size: 90))
                .foregroundStyle(.orange.opacity(0.9))
                .symbolEffect(.bounce, value: icon)

            // Title
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            // Message
            Text(message)
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingPageView(
        icon: "hands.sparkles",
        title: "Welcome to Prayer Tracker",
        message: "Build a lasting habit of daily prayer"
    )
    .background(Color(white: 0.05))
}
