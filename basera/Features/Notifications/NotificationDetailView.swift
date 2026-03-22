import SwiftUI
import VroxalDesign

struct NotificationDetailView: View {
    let notification: AppNotification
    let onOpenDestination: () -> Void

    var body: some View {
        ScrollView {
            BaseraPageContainer {
                VStack(alignment: .leading, spacing: VdSpacing.md) {
                    HStack(spacing: VdSpacing.sm) {
                        Image(systemName: notification.type.systemImageName)
                            .foregroundStyle(Color.vdContentPrimaryBase)
                        Text(notification.type.title)
                            .vdFont(VdFont.titleLarge)
                    }

                    Text(notification.message)
                        .vdFont(VdFont.bodyMedium)

                    BaseraCard {
                        VStack(alignment: .leading, spacing: VdSpacing.sm) {
                            Text("Notification metadata")
                                .vdFont(VdFont.titleSmall)
                            Text("Created: \(notification.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .vdFont(VdFont.bodySmall)
                                .foregroundStyle(Color.vdContentDefaultSecondary)
                            if notification.metadata.isEmpty == false {
                                ForEach(notification.metadata.keys.sorted(), id: \.self) { key in
                                    Text("\(key): \(notification.metadata[key] ?? "")")
                                        .font(.caption)
                                        .foregroundStyle(Color.vdContentDefaultSecondary)
                                }
                            }
                        }
                    }

                    VdButton(title: notification.route.destinationLabel, style: .primary) {
                        onOpenDestination()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .baseraScreenBackground()
        .navigationTitle("Notification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        NotificationDetailView(notification: PreviewData.mockNotificationsByUserID["preview-user-001"]!.first!) {}
    }
}
