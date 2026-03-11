import SwiftUI

struct BasraTextField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            TextField("Enter \(title)", text: $text)
                .padding(AppTheme.Spacing.medium)
                .background(AppTheme.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                        .stroke(AppTheme.Colors.border, lineWidth: 1)
                }
        }
    }
}

#Preview {
    StatefulPreviewContainer("") { binding in
        BasraTextField(title: "Phone Number", text: binding)
            .padding()
    }
}
