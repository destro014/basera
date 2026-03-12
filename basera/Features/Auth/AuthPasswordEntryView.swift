import SwiftUI

struct AuthPasswordEntryView: View {
    @Binding var password: String

    let validationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            BaseraTextField(
                title: "Password",
                prompt: "Password",
                text: $password,
                isSecure: true,
                errorMessage: validationMessage
            )

            Button(action: {
                // Forgot password action
            }) {
                Text("Forgot Password?")
                    .baseraTextStyle(AppTheme.Typography.labelLarge)
                    .foregroundStyle(AppTheme.Colors.brandPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, -AppTheme.Spacing.small)

            BaseraButton(
                title: "Continue",
                style: .primary,
                isLoading: isLoading,
                action: onSubmit
            )
        }
    }
}

#Preview("Ready") {
    AuthPasswordEntryView(
        password: .constant(""),
        validationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
    .padding()
}

#Preview("Error") {
    AuthPasswordEntryView(
        password: .constant("123"),
        validationMessage: "Incorrect password. Please try again.",
        isLoading: false,
        onSubmit: {}
    )
    .padding()
}
