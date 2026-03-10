import SwiftUI

struct BaseraTextField: View {
    let title: String
    var prompt: String? = nil
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var textInputAutocapitalization: TextInputAutocapitalization = .sentences
    var errorMessage: String? = nil
    var isDisabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            TextField(prompt ?? "Enter \(title)", text: $text)
                .textInputAutocapitalization(textInputAutocapitalization)
                .autocorrectionDisabled()
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .disabled(isDisabled)
                .padding(AppTheme.Spacing.medium)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                        .stroke(errorMessage == nil ? AppTheme.Colors.borderLight : AppTheme.Colors.danger, lineWidth: 1)
                }

            if let errorMessage {
                Text(errorMessage)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.danger)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StatefulPreviewContainer("") { binding in
            BaseraTextField(
                title: "Phone Number",
                prompt: "+977 98XXXXXXXX",
                text: binding,
                keyboardType: .phonePad,
                textContentType: .telephoneNumber,
                textInputAutocapitalization: .never
            )
        }

        StatefulPreviewContainer("123") { binding in
            BaseraTextField(
                title: "Verification Code",
                prompt: "6-digit code",
                text: binding,
                keyboardType: .numberPad,
                textContentType: .oneTimeCode,
                textInputAutocapitalization: .never,
                errorMessage: "That OTP did not match."
            )
        }
    }
    .padding()
}
