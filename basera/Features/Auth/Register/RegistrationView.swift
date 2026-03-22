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
        AuthFormScreenLayout(
            headerContent: { headerContainer },
            inputContent: { inputContainer },
            noticeContent: { noticeSection },
            actionContent: { buttonContainer },
            footerContent: { loginSection }
        )
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

    @ViewBuilder
    private var noticeSection: some View {
        if let notice {
            Spacer()
                .frame(height: VdSpacing.md)

            noticeContainer(notice)

            Spacer()
                .frame(height: VdSpacing.md)
        } else {
            Spacer()
                .frame(height: VdSpacing.xl)
        }
    }

    private var loginSection: some View {
        VStack(alignment: .leading, spacing: VdSpacing.none) {
            Spacer()
                .frame(height: VdSpacing.md)

            HStack(spacing: VdSpacing.xs) {
                Text("Already have an account?")
                    .vdFont(VdFont.bodyMedium)
                    .foregroundStyle(Color.vdContentDefaultSecondary)

                Button(action: onNavigateToLogin) {
                    Text("Login")
                        .vdFont(VdFont.labelMedium)
                        .foregroundStyle(Color.vdContentPrimaryBase)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func noticeContainer(_ notice: AuthStepNotice) -> some View {
        VdAlert(
            color: notice.style.authAlertColor,
            title: notice.style.authAlertTitle,
            description: notice.message
        )
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
