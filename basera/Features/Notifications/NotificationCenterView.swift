import SwiftUI
import VroxalDesign

struct NotificationCenterView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: NotificationCenterViewModel

    let onRoute: (NotificationRoute) -> Void

    init(userID: String, onRoute: @escaping (NotificationRoute) -> Void) {
        _viewModel = StateObject(
            wrappedValue: NotificationCenterViewModel(userID: userID)
        )
        self.onRoute = onRoute
    }

    var body: some View {
        Group {
            if viewModel.notifications.isEmpty {
                ScrollView {
                    BaseraPageContainer {
                        VdEmptyState(
                            title: "No notifications yet",
                            description:
                                "Important updates about interests, agreements, billing, payments, move-out, and reviews will appear here.",
                            icon: "bell.slash",
                            boxed: true,
                            actions: true,
                            primaryAction: true,
                            secondaryAction: false,
                            primaryActionTitle: "Refresh",
                            onPrimaryAction: {
                                Task {
                                    await viewModel.load(
                                        repository: environment.notificationsRepository
                                    )
                                }
                            }
                        )
                        .padding(.top, VdSpacing.huge)
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                List {
                    Section {
                        ForEach(viewModel.notifications) { notification in
                            NavigationLink {
                                NotificationDetailView(
                                    notification: notification
                                ) {
                                    onRoute(notification.route)
                                }
                                .task {
                                    await viewModel.markAsRead(
                                        notification.id,
                                        repository: environment
                                            .notificationsRepository
                                    )
                                }
                            } label: {
                                NotificationRowView(notification: notification)
                            }
                            .listRowBackground(Color.vdBackgroundDefaultSecondary)
                        }
                    } header: {
                        HStack {
                            Text("Updates")
                                .vdFont(VdFont.titleSmall)
                            Spacer()
                            if viewModel.badgeState.unreadCount > 0 {
                                Button("Mark all read") {
                                    Task {
                                        await viewModel.markAllAsRead(
                                            repository: environment
                                                .notificationsRepository
                                        )
                                    }
                                }
                                .vdFont(VdFont.labelMedium)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .baseraListBackground()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .baseraScreenBackground()
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await environment.notificationsRepository
                .registerForPushNotifications()
            await viewModel.load(
                repository: environment.notificationsRepository
            )
        }
    }
}

private struct NotificationRowView: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: VdSpacing.smMd) {
            Image(systemName: notification.type.systemImageName)
                .foregroundStyle(
                    notification.isUnread
                        ? Color.vdBackgroundPrimaryBase
                        : Color.vdContentDefaultSecondary
                )
                .frame(width: 28)

            VStack(alignment: .leading, spacing: VdSpacing.xs) {
                HStack {
                    Text(notification.title)
                        .vdFont(VdFont.titleSmall)
                    if notification.isUnread {
                        Circle()
                            .fill(Color.vdBackgroundPrimaryBase)
                            .frame(width: 8, height: 8)
                    }
                }
                Text(notification.message)
                    .vdFont(VdFont.bodySmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
                Text(notification.createdAt, style: .relative)
                    .vdFont(VdFont.labelSmall)
                    .foregroundStyle(Color.vdContentDefaultSecondary)
            }
        }
        .padding(.vertical, VdSpacing.xs)
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
