import SwiftUI

struct ProfileCreationView: View {
    @Binding var fullName: String
    @Binding var phoneNumber: String

    let notice: AuthStepNotice?
    let fullNameValidationMessage: String?
    let phoneNumberValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    headerContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    inputContainer
                    if let notice {
                        Spacer()
                            .frame(height: AppTheme.Spacing.large)

                        BaseraInlineMessageView(
                            tone: tone(for: notice.style),
                            message: notice.message
                        )

                        Spacer()
                            .frame(height: AppTheme.Spacing.large)
                    } else {
                        Spacer()
                            .frame(height: AppTheme.Spacing.xxLarge)
                    }
                    buttonContainer
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
        }
    }

    private var logoContainer: some View {
        Image("logo-horizontal")
            .resizable()
            .scaledToFit()
            .frame(height: 40)
            .accessibilityHidden(true)
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text("Complete profile setup")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Tell us your full name and phone number so owners and renters can trust account records.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            BaseraTextField(
                title: "Full Name",
                prompt: "Full Name",
                text: $fullName,
                textContentType: .name,
                errorMessage: fullNameValidationMessage
            )

            BaseraTextField(
                title: "Phone Number",
                prompt: "+97798XXXXXXXX",
                text: $phoneNumber,
                keyboardType: .phonePad,
                textContentType: .telephoneNumber,
                textInputAutocapitalization: .never,
                errorMessage: phoneNumberValidationMessage
            )
        }
    }

    private var buttonContainer: some View {
        BaseraButton(
            title: "Complete Profile",
            style: .primary,
            isLoading: isLoading,
            action: onSubmit
        )
    }

    private func tone(for style: AuthStepNotice.Style) -> BaseraInlineMessageView.Tone {
        switch style {
        case .info:
            .info
        case .success:
            .success
        case .error:
            .error
        }
    }
}

#Preview {
    ProfileCreationView(
        fullName: .constant(""),
        phoneNumber: .constant(""),
        notice: AuthStepNotice(style: .error, message: "Enter your full name to continue."),
        fullNameValidationMessage: nil,
        phoneNumberValidationMessage: nil,
        isLoading: false,
        onSubmit: {}
    )
}
