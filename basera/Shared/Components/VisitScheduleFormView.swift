import SwiftUI
import VroxalDesign

struct VisitScheduleFormView: View {
    @Binding var scheduledAt: Date
    @Binding var note: String
    let isSubmitting: Bool
    let onSubmit: () -> Void

    var body: some View {
        BaseraCard {
            VStack(alignment: .leading, spacing: VdSpacing.smMd) {
                Text("Schedule Property Visit")
                    .vdFont(VdFont.titleMedium)

                DatePicker("Date & Time", selection: $scheduledAt)
                    .datePickerStyle(.graphical)

                VdTextField(
                    title: "Note (optional)",
                    prompt: "Parking instructions, landmark, etc.",
                    text: $note,
                    keyboardType: .default,
                    textContentType: nil
                )

                VdButton(title: "Send Visit Proposal", style: .primary, isLoading: isSubmitting) {
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
