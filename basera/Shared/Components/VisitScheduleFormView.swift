import SwiftUI

struct VisitScheduleFormView: View {
    @Binding var scheduledAt: Date
    @Binding var note: String
    let isSubmitting: Bool
    let onSubmit: () -> Void

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Schedule Property Visit")
                    .baseraTextStyle(AppTheme.Typography.titleMedium)

                DatePicker("Date & Time", selection: $scheduledAt)
                    .datePickerStyle(.graphical)

                BaseraTextField(
                    title: "Note (optional)",
                    text: $note,
                    prompt: "Parking instructions, landmark, etc.",
                    keyboardType: .default,
                    textContentType: nil
                )

                BaseraButton(title: "Send Visit Proposal", style: .primary, isLoading: isSubmitting) {
                    onSubmit()
                }
            }
        }
    }
}

#Preview {
    VisitScheduleFormView(
        scheduledAt: .constant(.now),
        note: .constant("Call before arrival"),
        isSubmitting: false,
        onSubmit: {}
    )
    .padding()
}
