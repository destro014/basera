import SwiftUI

struct AuthPhoneEntryView: View {
    @Binding var phoneNumber: String

    let validationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            Text("We’ll use this number for OTP verification now, and for agreement signing and billing notifications later.")
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            BaseraTextField(
                title: "Phone number",
                prompt: "+977 98XXXXXXXX",
                text: $phoneNumber,
                keyboardType: .phonePad,
                textContentType: .telephoneNumber,
                textInputAutocapitalization: .never,
                errorMessage: validationMessage
            )

            HStack(spacing: AppTheme.Spacing.small) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(AppTheme.Colors.info)

                Text("Nepal mobile numbers only for now.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }

            BaseraButton(
                title: "Send code",
                style: .primary,
                isLoading: isLoading,
                action: onSubmit
            )
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
        phoneNumber: .constant("+977 9800000000"),
        validationMessage: nil,
        isLoading: true,
        onSubmit: {}
    )
    .padding()
}

#Preview("Error") {
    AuthPhoneEntryView(
        phoneNumber: .constant("9812"),
        validationMessage: "Enter a valid Nepal mobile number. Example: +977 98XXXXXXXX.",
        isLoading: false,
        onSubmit: {}
    )
    .padding()
}
