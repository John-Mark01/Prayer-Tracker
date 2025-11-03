import SwiftUI

struct OnboardingPageView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(icon)
                .resizable()
                .frame(width: 300, height: 300)
                .clipShape(Circle())

            // Title
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Color("Onboarding/textPrimary"))
                .multilineTextAlignment(.center)

            // Message
            Text(message)
                .font(.system(size: 20, weight: .regular, design: .rounded))
                .foregroundStyle(Color("Onboarding/textSecondary"))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
//                .padding(.horizontal, 40)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    OnboardingPageView(
        icon: "hands.sparkles",
        title: "Welcome to Prayer Tracker",
        message: "Build a lasting habit of daily prayer"
    )
    .background(Color("Onboarding/background"))
}
