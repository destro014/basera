import SwiftUI
import VroxalDesign

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
                        .frame(height: VdSpacing.xxl)
                    logoContainer
                    Spacer()
                        .frame(height: VdSpacing.lg)
                    headerContainer
                    Spacer()
                        .frame(height: VdSpacing.lg)
                    inputContainer
                    if let notice {
                        Spacer()
                            .frame(height: VdSpacing.md)
                        noticeContainer(notice)
                        Spacer()
                            .frame(height: VdSpacing.md)
                    } else {
                        Spacer()
                            .frame(height: VdSpacing.xxl)
                    }
                    buttonContainer
                    Spacer()
                        .frame(height: VdSpacing.md)
                    loginContainer
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(Color.vdBackgroundDefaultBase.ignoresSafeArea())
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
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Create your account")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter your email to receive an OTP and continue registration.")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var inputContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            VdTextField(
                "Email",
                text: $email,
                placeholder: "you@example.com",
                state: inputState(for: emailValidationMessage),
                leadingIcon: "envelope",
                helperText: emailValidationMessage
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
        }
    }

    private var buttonContainer: some View {
        VdButton("Continue", fullWidth: true, isLoading: isLoading, action: onSubmit)
    }

    private var loginContainer: some View {
        HStack(spacing: VdSpacing.xs) {
            Text("Already have an account?")
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)

            Button(action: onNavigateToLogin) {
                Text("Login")
                    .vdFont(VdFont.labelMedium)
                    .foregroundStyle(Color.vdContentPrimaryBase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func noticeContainer(_ notice: AuthStepNotice) -> some View {
        VdAlert(
            color: alertColor(for: notice.style),
            title: alertTitle(for: notice.style),
            description: notice.message
        )
    }

    private func alertColor(for style: AuthStepNotice.Style) -> VdAlertColor {
        switch style {
        case .info:
            return .info
        case .success:
            return .success
        case .error:
            return .error
        }
    }

    private func alertTitle(for style: AuthStepNotice.Style) -> String {
        switch style {
        case .info:
            return "Info"
        case .success:
            return "Success"
        case .error:
            return "Please Check"
        }
    }

    private func inputState(for validationMessage: String?) -> VdInputState {
        validationMessage?.isEmpty == false ? .error : .default
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
        VStack(alignment: .leading, spacing: VdSpacing.smMd) {
            Spacer()
                .frame(height: VdSpacing.lg)
            Text("Account already exists")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("There is already an account associated with \(existingAccountEmail ?? "this email"). Please proceed to login.")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
                .frame(height: VdSpacing.lg)
            VdButton("Go to Login", action: onContinueToLoginFromExistingAccount)
        }
        .padding(.horizontal, VdSpacing.md)
        .padding(.vertical, VdSpacing.lg)
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
