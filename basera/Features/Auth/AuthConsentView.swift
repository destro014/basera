import SwiftUI

struct AuthConsentView: View {
    @Binding var acceptsTerms: Bool
    @Binding var acceptsPrivacy: Bool

    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            BaseraInlineMessageView(
                tone: .info,
                message: "Basera is a digital rental record platform. It helps both sides stay aligned, but it is not a legal enforcement service."
            )

            consentCard(
                title: "Basera Terms of Service",
                description: "I agree to use Basera for truthful rental records, approvals, agreements, billing, payments, and move-out actions.",
                isAccepted: $acceptsTerms
            )

            consentCard(
                title: "Basera Privacy Policy",
                description: "I allow Basera to store my phone number, role selection, agreements, invoices, payments, and move-out history for account use.",
                isAccepted: $acceptsPrivacy
            )

            BaseraButton(title: "Continue", style: .primary, action: onContinue)
        }
    }

    private func consentCard(title: String, description: String, isAccepted: Binding<Bool>) -> some View {
        Toggle(isOn: isAccepted) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                Text(title)
                    .font(AppTheme.Typography.subtitle)
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Text(description)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .toggleStyle(.switch)
        .padding(AppTheme.Spacing.large)
        .background(AppTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
    }
}

#Preview("Empty") {
    AuthConsentView(
        acceptsTerms: .constant(false),
        acceptsPrivacy: .constant(false),
        onContinue: {}
    )
    .padding()
}

#Preview("Accepted") {
    AuthConsentView(
        acceptsTerms: .constant(true),
        acceptsPrivacy: .constant(true),
        onContinue: {}
    )
    .padding()
}
