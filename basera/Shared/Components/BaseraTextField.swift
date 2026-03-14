import SwiftUI

struct BaseraTextField: View {
    let title: String
    var prompt: String? = nil
    var systemImage: String? = nil
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var textInputAutocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false
    var allowsSecureTextToggle: Bool = false
    var errorMessage: String? = nil
    var isDisabled: Bool = false
    var submitLabel: SubmitLabel = .done
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool
    @State private var isSecureTextVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack(spacing: AppTheme.Spacing.large) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconColor)
                        .frame(width: 20, height: 20)
                }

                HStack(spacing: AppTheme.Spacing.small) {
                    ZStack(alignment: .leading) {
                        if shouldShowPrompt, let prompt {
                            Text(prompt)
                                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                                .foregroundStyle(AppTheme.Colors.textDisabled)
                                .offset(y: 12)
                        }

                        Group {
                            if shouldUseSecureEntry {
                                SecureField("", text: $text)
                            } else {
                                TextField("", text: $text)
                            }
                        }
                        .textFieldStyle(.plain)
                        .background(Color.clear)
                        .textInputAutocapitalization(textInputAutocapitalization)
                        .autocorrectionDisabled()
                        .keyboardType(keyboardType)
                        .textContentType(textContentType)
                        .submitLabel(submitLabel)
                        .focused($isFocused)
                        .onSubmit {
                            onSubmit?()
                        }
                        .disabled(isDisabled)
                        .baseraTextStyle(AppTheme.Typography.bodyLarge)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .tint(AppTheme.Colors.brandPrimary)
                        .offset(y: isLabelFloating ? 12 : 0)
                        .frame(height: 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(alignment: .leading) {
                        Text(title)
                            .baseraTextStyle(AppTheme.Typography.bodyMedium)
                            .foregroundStyle(labelColor)
                            .offset(y: isLabelFloating ? -12 : 0)
                    }

                    if showsSecureToggle {
                        Button {
                            isSecureTextVisible.toggle()
                        } label: {
                            Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(iconColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(isDisabled)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.vertical, AppTheme.Spacing.medium)
            .background(containerBackground)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous)
                    .stroke(borderColor, lineWidth: 2)
            }
            .contentShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
            .onTapGesture {
                if isDisabled == false {
                    isFocused = true
                }
            }
            .animation(.easeInOut(duration: 0.2), value: isLabelFloating)

            if let errorMessage {
                Text(errorMessage)
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.errorPrimary)
            }
        }
    }

    private var isLabelFloating: Bool {
        isFocused || text.isEmpty == false
    }

    private var shouldUseSecureEntry: Bool {
        isSecure && !(allowsSecureTextToggle && isSecureTextVisible)
    }

    private var showsSecureToggle: Bool {
        isSecure && allowsSecureTextToggle
    }

    private var shouldShowPrompt: Bool {
        isLabelFloating && text.isEmpty
    }

    private var hasError: Bool {
        errorMessage?.isEmpty == false
    }

    private var containerBackground: Color {
        isDisabled ? AppTheme.Colors.surfaceDisabled : AppTheme.Colors.surfacePrimary
    }

    private var borderColor: Color {
        if hasError {
            return AppTheme.Colors.errorPrimary
        }

        return isFocused ? AppTheme.Colors.brandPrimary : AppTheme.Colors.borderSecondary
    }

    private var labelColor: Color {
        if hasError {
            return AppTheme.Colors.errorPrimary
        }

        return isLabelFloating ? AppTheme.Colors.textSecondary : AppTheme.Colors.textDisabled
    }

    private var iconColor: Color {
        if hasError {
            return AppTheme.Colors.errorPrimary
        }

        return isFocused ? AppTheme.Colors.brandPrimary : AppTheme.Colors.textSecondary
    }
}

#Preview {
    VStack(spacing: 20) {
        StatefulPreviewContainer("") { binding in
            BaseraTextField(
                title: "Phone Number",
                prompt: "98XXXXXXXX",
                systemImage: "phone.fill",
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
                systemImage: "number",
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
