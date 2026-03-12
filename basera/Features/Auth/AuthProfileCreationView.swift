import SwiftUI

struct AuthProfileCreationView: View {
    @Binding var fullName: String
    @Binding var password: String

    let nameValidationMessage: String?
    let passwordValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            VStack(spacing: AppTheme.Spacing.medium) {
                BaseraTextField(
                    title: "Full Name",
                    prompt: "Full Name",
                    text: $fullName,
                    textContentType: .name,
                    errorMessage: nameValidationMessage
                )
                
                BaseraTextField(
                    title: "Password",
                    prompt: "Password",
                    text: $password,
                    textContentType: .newPassword,
                    isSecure: true,
                    errorMessage: passwordValidationMessage
                )
            }

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
    AuthProfileCreationView(
        fullName: .constant(""),
        password: .constant(""),
        nameValidationMessage: nil,
        passwordValidationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
    .padding()
}
