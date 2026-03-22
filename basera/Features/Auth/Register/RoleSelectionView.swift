import SwiftUI
import VroxalDesign

struct RoleSelectionView: View {
    @Binding var selectedRole: UserRole

    let isLoading: Bool
    let onContinue: () -> Void

    var body: some View {
        AuthFormScreenLayout(
            headerContent: { headerContainer },
            inputContent: { optionsContainer },
            noticeContent: {
                Spacer()
                    .frame(height: VdSpacing.xl)
            },
            actionContent: { buttonContainer },
            footerContent: { EmptyView() }
        )
    }

    private var headerContainer: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text("How will you use Basera?")
                .vdFont(VdFont.headlineLarge)
                .foregroundStyle(Color.vdContentDefaultBase)
        }
    }

    private var optionsContainer: some View {
        VStack(spacing: VdSpacing.smMd) {
            VdSelectionCard(
                selectionStyle: .radio,
                isSelected: roleBinding(for: .renter),
                icon: "house.fill",
                title: "Find a place to rent",
                description: "I am looking for properties."
            )

            VdSelectionCard(
                selectionStyle: .radio,
                isSelected: roleBinding(for: .owner),
                icon: "building.2.fill",
                title: "List my property",
                description: "I want to rent out my property."
            )
        }
    }

    private var buttonContainer: some View {
        VdButton("Continue", fullWidth: true, isLoading: isLoading, action: onContinue)
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
