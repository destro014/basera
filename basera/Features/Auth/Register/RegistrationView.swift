import SwiftUI

struct RegistrationView: View {
    @Binding var email: String
    @State private var existingAccountSheetHeight: CGFloat = 280

    let notice: AuthStepNotice?
    let emailValidationMessage: String?
    let isLoading: Bool
    let existingAccountEmail: String?
    let onSubmit: () -> Void
    let onDismissExistingAccountSheet: () -> Void
    let onContinueToLoginFromExistingAccount: () -> Void
    let onNavigateToLogin: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                        .frame(height: AppTheme.Spacing.xxLarge)
                    logoContainer
                    Spacer()
                        .frame(height: AppTheme.Spacing.xLarge)
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
                    Spacer()
                        .frame(height: AppTheme.Spacing.large)
                    loginContainer
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(AppTheme.Colors.backgroundPrimary.ignoresSafeArea())
            .sheet(isPresented: existingAccountSheetBinding) {
                accountAlreadyExistsSheet
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(
                                    key: SheetHeightPreferenceKey.self,
                                    value: geometry.size.height
                                )
                        }
                    )
                    .onPreferenceChange(SheetHeightPreferenceKey.self) { contentHeight in
                        existingAccountSheetHeight = min(max(contentHeight + 1, 220), 520)
                    }
                    .presentationDetents([.height(existingAccountSheetHeight)])
                    .presentationDragIndicator(.visible)
            }
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
            Text("Create your account")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("Enter your email to receive an OTP and continue registration.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            BaseraTextField(
                title: "Email",
                prompt: "you@example.com",
                text: $email,
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                textInputAutocapitalization: .never,
                errorMessage: emailValidationMessage
            )
        }
    }

    private var buttonContainer: some View {
        BaseraButton(
            title: "Continue",
            style: .primary,
            isLoading: isLoading,
            action: onSubmit
        )
    }

    private var loginContainer: some View {
        HStack(spacing: AppTheme.Spacing.xSmall) {
            Text("Already have an account?")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Button(action: onNavigateToLogin) {
                Text("Login")
                    .baseraTextStyle(AppTheme.Typography.labelLarge)
                    .foregroundStyle(AppTheme.Colors.brandPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
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

    private var existingAccountSheetBinding: Binding<Bool> {
        Binding(
            get: { existingAccountEmail != nil },
            set: { isPresented in
                if isPresented == false && existingAccountEmail != nil {
                    onDismissExistingAccountSheet()
                }
            }
        )
    }

    private var accountAlreadyExistsSheet: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Spacer()
                .frame(height: AppTheme.Spacing.xLarge)
            Text("Account already exists")
                .baseraTextStyle(AppTheme.Typography.headlineLarge)
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text("There is already an account associated with \(existingAccountEmail ?? "this email"). Please proceed to login.")
                .baseraTextStyle(AppTheme.Typography.bodyLarge)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
                .frame(height: AppTheme.Spacing.xLarge)
            BaseraButton(
                title: "Go to Login",
                style: .primary,
                action: onContinueToLoginFromExistingAccount
            )
        }
        .padding(.horizontal, AppTheme.Spacing.large)
        .padding(.vertical, AppTheme.Spacing.xLarge)
    }
}

private struct SheetHeightPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

#Preview {
    RegistrationView(
        email: .constant(""),
        notice: AuthStepNotice(style: .info, message: "Create your account to continue."),
        emailValidationMessage: nil,
        isLoading: false,
        existingAccountEmail: nil,
        onSubmit: {},
        onDismissExistingAccountSheet: {},
        onContinueToLoginFromExistingAccount: {},
        onNavigateToLogin: {}
    )
}
