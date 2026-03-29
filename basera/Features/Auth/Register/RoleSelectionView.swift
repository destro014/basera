import SwiftUI
import VroxalDesign

struct RoleSelectionView: View {
    @Binding var selectedRole: UserRole

    let isLoading: Bool
    let onContinue: () -> Void

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: VdSpacing.none) {
                    Spacer()
                        .frame(height: VdSpacing.xxl)

                    
                    headerContainer

                    Spacer()
                        .frame(height: VdSpacing.xl)

                    optionsContainer

                    Spacer()
                        .frame(height: VdSpacing.xl)

                    buttonContainer
                }
                .frame(
                    maxWidth: 420,
                    minHeight: max(proxy.size.height - 32, 0),
                    alignment: .top
                )
                .padding(.horizontal, proxy.size.width >= 520 ? VdSpacing.lg : VdSpacing.md)
                .padding(.bottom, VdSpacing.sm)
                .frame(maxWidth: .infinity)
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
            Text("How would you like to use Basera")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)

            Text("Please select how would you like to use basera.")
                .vdFont(VdFont.bodyLarge)
                .foregroundStyle(Color.vdContentDefaultSecondary)
        }
    }

    private var optionsContainer: some View {
        VStack(spacing: VdSpacing.smMd) {
            VdSelectionCard(
                selectionStyle: .radio,
                isSelected: roleBinding(for: .renter),
                icon: "house.fill",
                title: "I am a renter",
                description: "Description for the control group goes here"
            )

            VdSelectionCard(
                selectionStyle: .radio,
                isSelected: roleBinding(for: .owner),
                icon: "building.2.fill",
                title: "I am a owner",
                description: "Description for the control group goes here"
            )
        }
    }

    private var buttonContainer: some View {
        VdButton(
            "Continue",
            size: .large,
            fullWidth: true,
            isLoading: isLoading,
            action: onContinue
        )
            .frame(maxWidth: .infinity)
    }

    private func roleBinding(for role: UserRole) -> Binding<Bool> {
        Binding(
            get: { selectedRole == role },
            set: { isSelected in
                if isSelected {
                    selectedRole = role
                }
            }
        )
    }
}

#Preview {
    RoleSelectionView(
        selectedRole: .constant(.renter),
        isLoading: false,
        onContinue: {}
    )
}
