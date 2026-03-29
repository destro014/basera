import SwiftUI
import VroxalDesign

struct PasswordRecoveryEmailView: View {
    @Binding var email: String

    let notice: AuthStepNotice?
    let emailValidationMessage: String?
    let isLoading: Bool
    let onSubmit: () -> Void
    let onBackToLogin: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let contentHorizontalPadding =
                proxy.size.width >= 520 ? VdSpacing.lg : VdSpacing.md

            VStack(alignment: .leading, spacing: VdSpacing.none) {
                Spacer()
                    .frame(height: VdSpacing.xxl)

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
                backToLoginSection(
                    horizontalPadding: contentHorizontalPadding,
                    bottomSafeAreaInset: proxy.safeAreaInsets.bottom
                )
            }
            .baseraScreenBackground()
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
            Text("Recover password")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Enter your email to receive and code and continue password recovery.")
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

    private func backToLoginSection(
        horizontalPadding: CGFloat,
        bottomSafeAreaInset: CGFloat
    ) -> some View {
        HStack(alignment: .center, spacing: VdSpacing.sm) {
            Text("Remember your password?")
                .vdFont(VdFont.bodyMedium)
                .foregroundStyle(Color.vdContentDefaultSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            VdButton(
                title: "Login",
                style: .subtle,
                isDisabled: isLoading,
                action: onBackToLogin
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
}

#Preview {
    PasswordRecoveryEmailView(
        email: .constant(""),
        notice: nil,
        emailValidationMessage: nil,
        isLoading: false,
        onSubmit: {},
        onBackToLogin: {}
    )
}
