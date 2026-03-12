import SwiftUI

struct NotificationCenterView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: NotificationCenterViewModel

    let onRoute: (NotificationRoute) -> Void

    init(userID: String, onRoute: @escaping (NotificationRoute) -> Void) {
        _viewModel = StateObject(wrappedValue: NotificationCenterViewModel(userID: userID))
        self.onRoute = onRoute
    }

    var body: some View {
        List {
            if viewModel.notifications.isEmpty {
                BaseraEmptyStateView(
                    title: "No notifications yet",
                    message: "Important updates about interests, agreements, billing, payments, move-out, and reviews will appear here.",
                    systemImage: "bell.slash",
                    actionTitle: "Refresh",
                    action: {
                        Task { await viewModel.load(repository: environment.notificationsRepository) }
                    }
                )
                .listRowSeparator(.hidden)
            } else {
                Section {
                    ForEach(viewModel.notifications) { notification in
                        NavigationLink {
                            NotificationDetailView(notification: notification) {
                                onRoute(notification.route)
                            }
                            .task {
                                await viewModel.markAsRead(notification.id, repository: environment.notificationsRepository)
                            }
                        } label: {
                            NotificationRowView(notification: notification)
                        }
                    }
                } header: {
                    HStack {
                        Text("Updates")
                            .baseraTextStyle(AppTheme.Typography.titleSmall)
                        Spacer()
                        if viewModel.badgeState.unreadCount > 0 {
                            Button("Mark all read") {
                                Task {
                                    await viewModel.markAllAsRead(repository: environment.notificationsRepository)
                                }
                            }
                            .baseraTextStyle(AppTheme.Typography.labelMedium)
                        }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .task {
            await environment.notificationsRepository.registerForPushNotifications()
            await viewModel.load(repository: environment.notificationsRepository)
        }
    }
}

private struct NotificationRowView: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
            Image(systemName: notification.type.systemImageName)
                .foregroundStyle(notification.isUnread ? AppTheme.Colors.brandPrimary : AppTheme.Colors.textSecondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
                HStack {
                    Text(notification.title)
                        .baseraTextStyle(AppTheme.Typography.titleSmall)
                    if notification.isUnread {
                        Circle()
                            .fill(AppTheme.Colors.brandPrimary)
                            .frame(width: 8, height: 8)
                    }
                }
                Text(notification.message)
                    .baseraTextStyle(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                Text(notification.createdAt, style: .relative)
                    .baseraTextStyle(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xSmall)
    }
}

#Preview("iPhone") {
    NavigationView {
        NotificationCenterView(userID: "preview-user-001", onRoute: { _ in })
    }
    .environmentObject(AppEnvironment.bootstrap())
}

#Preview("iPad") {
    NavigationView {
        NotificationCenterView(userID: "preview-user-001", onRoute: { _ in })
    }
    .frame(width: 1024, height: 768)
    .environmentObject(AppEnvironment.bootstrap())
}
