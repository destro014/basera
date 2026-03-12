import SwiftUI

struct NotificationDetailView: View {
    let notification: AppNotification
    let onOpenDestination: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                HStack(spacing: AppTheme.Spacing.small) {
                    Image(systemName: notification.type.systemImageName)
                        .foregroundStyle(AppTheme.Colors.brandPrimary)
                    Text(notification.type.title)
                        .baseraTextStyle(AppTheme.Typography.titleLarge)
                }

                Text(notification.message)
                    .baseraTextStyle(AppTheme.Typography.bodyMedium)

                BaseraCard {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Notification metadata")
                            .baseraTextStyle(AppTheme.Typography.titleSmall)
                        Text("Created: \(notification.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .baseraTextStyle(AppTheme.Typography.bodySmall)
                            .foregroundStyle(AppTheme.Colors.textSecondary)
                        if notification.metadata.isEmpty == false {
                            ForEach(notification.metadata.keys.sorted(), id: \.self) { key in
                                Text("\(key): \(notification.metadata[key] ?? "")")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }

                BaseraButton(title: notification.route.destinationLabel, style: .primary) {
                    onOpenDestination()
                }
            }
            .padding()
        }
        .navigationTitle("Notification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        NotificationDetailView(notification: PreviewData.mockNotificationsByUserID["preview-user-001"]!.first!) {}
    }
}
