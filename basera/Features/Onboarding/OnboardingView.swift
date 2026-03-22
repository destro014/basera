import SwiftUI
import VroxalDesign

struct OnboardingView: View {
    let notice: AuthStepNotice?
    let onLogin: () -> Void
    let onRegister: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VdSpacing.smMd) {

                    Image("logo-horizontal")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .accessibilityHidden(true)
                    Spacer()
                        .frame(height: VdSpacing.lg)


                    VStack(alignment: .leading, spacing: VdSpacing.xs) {
                        Text("Welcome to Basera")
                            .vdFont(VdFont.headlineLarge)
                            .foregroundStyle(Color.vdContentDefaultBase)

                        Text("Manage the rental journey in one place, from discovery and approvals to agreements, monthly invoices, and move-out records.")
                            .vdFont(VdFont.bodyLarge)
                            .foregroundStyle(Color.vdContentDefaultSecondary)
                    }
                    Spacer()
                        .frame(height: VdSpacing.xxl)


                        introPoint(
                            iconName: "person.2.fill",
                            title: "Single role account setup",
                            message: "Choose renter or owner during registration. Each account keeps one role for clear workflows."
                        )

                        introPoint(
                            iconName: "lock.shield.fill",
                            title: "Privacy-first listing flow",
                            message: "Public listings keep the exact property address hidden until an owner reviews and approves the renter."
                        )

                        introPoint(
                            iconName: "doc.text.fill",
                            title: "Records that stay accessible",
                            message: "Track agreements, monthly invoices, partial payments, advance payments, and the formal move-out flow in one place."
                        )

                        Spacer()

                        HStack(spacing: VdSpacing.smMd) {
                            VdButton(title: "Register", style: .primary, action: onRegister)
                                .frame(maxWidth: .infinity)
                            VdButton(title: "Login", style: .secondary, action: onLogin)
                                .frame(maxWidth: .infinity)
                        }
                    
                
                }
                .frame(maxWidth: 402, minHeight: max(proxy.size.height - 32, 0), alignment: .top)
                .padding(.horizontal, proxy.size.width >= 520 ? 24 : 16)
                .padding(.top, 24)
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity)
            }
            .background(Color.vdBackgroundDefaultBase.ignoresSafeArea())
        }
    }


    private func tone(for style: AuthStepNotice.Style) -> BaseraVdAlertTone {
        switch style {
        case .info:
            .info
        case .success:
            .success
        case .error:
            .error
        }
    }

    private func introPoint(iconName: String, title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: VdSpacing.smMd) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Color.vdContentDefaultBase)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: VdSpacing.xs) {
                Text(title)
                    .vdFont(VdFont.titleMedium)
                    .foregroundStyle(Color.vdContentDefaultBase)

                Text(message)
                    .vdFont(VdFont.bodyMedium)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(VdSpacing.md)
        .background(Color.vdBackgroundDefaultSecondary)
        .clipShape(RoundedRectangle(cornerRadius: VdRadius.lg, style: .continuous))
    }
}

#Preview {
    OnboardingView(
        notice: nil,
        onLogin: {},
        onRegister: {}
    )
}
