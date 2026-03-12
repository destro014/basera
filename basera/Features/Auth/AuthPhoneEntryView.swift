import SwiftUI

struct AuthPhoneEntryView: View {
    @Binding var phoneNumber: String

    let validationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            BaseraTextField(
                title: "Phone number",
                prompt: "98XXXXXXXX",
                text: $phoneNumber,
                keyboardType: .phonePad,
                textContentType: .telephoneNumber,
                textInputAutocapitalization: .never,
                errorMessage: validationMessage
            )

            VStack(spacing: AppTheme.Spacing.medium) {
                BaseraButton(
                    title: "Continue",
                    style: .primary,
                    isLoading: isLoading,
                    action: onSubmit
                )

                Text("By tapping continue, you agree to Terms and Conditions and Privacy Policy")
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview("Empty") {
    StatefulPreviewContainer("") { binding in
        AuthPhoneEntryView(
            phoneNumber: binding,
            validationMessage: nil,
            isLoading: false,
            onSubmit: {}
        )
        .padding()
    }
}

#Preview("Loading") {
    AuthPhoneEntryView(
        phoneNumber: .constant("9800000000"),
        validationMessage: nil,
        isLoading: true,
        onSubmit: {}
    )
    .padding()
}

#Preview("Error") {
    AuthPhoneEntryView(
        phoneNumber: .constant("9812"),
        validationMessage: "Enter a valid Nepal mobile number. Example: 98XXXXXXXX.",
        isLoading: false,
        onSubmit: {}
    )
    .padding()
}
