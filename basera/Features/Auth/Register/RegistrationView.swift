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
            let contentHorizontalPadding =
                proxy.size.width >= 520 ? VdSpacing.lg : VdSpacing.md

            VStack(alignment: .leading, spacing: VdSpacing.none) {
                Spacer()
                    .frame(height: VdSpacing.xxl)

                logoContainer

                Spacer()
                    .frame(height: VdSpacing.lg)

                headerContainer

                Spacer()
                    .frame(height: VdSpacing.xl)

                inputContainer

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

                buttonContainer

                Spacer(minLength: VdSpacing.xl)
            }
            .frame(
                maxWidth: 420,
                minHeight: max(proxy.size.height - 32, 0),
                alignment: .top
            )
            .padding(.horizontal, contentHorizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .safeAreaInset(edge: .bottom, spacing: VdSpacing.none) {
                loginSection(
                    horizontalPadding: contentHorizontalPadding,
                    bottomSafeAreaInset: proxy.safeAreaInsets.bottom
                )
            }
            .baseraScreenBackground()
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
            .frame(height: 44)
            .accessibilityHidden(true)
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("Create your account")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter your email to receive a code and continue registration.")
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
            .textContentType(.username)
        }
    }

    private var buttonContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.md) {
            VdButton(
                "Continue",
                size: .large,
                fullWidth: true,
                isLoading: isLoading,
                action: onSubmit
            )

            Text("By tapping continue, you agree to Terms and Conditions and Privacy Policy")
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func loginSection(
        horizontalPadding: CGFloat,
        bottomSafeAreaInset: CGFloat
    ) -> some View {
        HStack(alignment: .center, spacing: VdSpacing.sm) {
            Text("Already have an account?")
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VdButton(
                title: "Login",
                style: .subtle,
                isDisabled: isLoading,
                action: onNavigateToLogin
            )
            .frame(width: 87)
        }
        .frame(maxWidth: 420, alignment: .leading)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, VdSpacing.md)
        .padding(
            .bottom,
            max(bottomSafeAreaInset + VdSpacing.xs, VdSpacing.lg)
        )
        .background(
            TopRoundedRectangle(radius: VdRadius.xl)
                .fill(Color.vdBackgroundDefaultSecondary)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func noticeContainer(_ notice: AuthStepNotice) -> some View {
        AuthNoticeBanner(notice: notice)
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
            VdButton("Go to Login", size: .medium, fullWidth: true, action: onContinueToLoginFromExistingAccount)
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
