import SwiftUI

struct ConversationListView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: ConversationListViewModel

    init(userID: String) {
        _viewModel = StateObject(wrappedValue: ConversationListViewModel(userID: userID))
    }

    var body: some View {
        List {
            if viewModel.conversations.isEmpty {
                BaseraEmptyStateView(
                    title: "No conversations yet",
                    message: "Chat is available only after owner approval in the interest flow.",
                    systemImage: "bubble.left.and.bubble.right"
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.conversations) { conversation in
                    NavigationLink {
                        ChatScreenView(conversation: conversation, currentUserID: viewModel.userID)
                    } label: {
                        ConversationRowView(conversation: conversation)
                    }
                }
            }
        }
        .navigationTitle("Conversations")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
    }
}

private struct ConversationRowView: View {
    let conversation: ChatConversation

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xSmall) {
            Text(conversation.participantName)
                .baseraTextStyle(AppTheme.Typography.titleSmall)
            Text(conversation.listingTitle)
                .baseraTextStyle(AppTheme.Typography.bodySmall)
                .foregroundStyle(AppTheme.Colors.textSecondary)
            Text(conversation.lastMessagePreview)
                .lineLimit(1)
                .baseraTextStyle(AppTheme.Typography.bodySmall)
            if conversation.unreadCount > 0 {
                BaseraBadge(text: "\(conversation.unreadCount) unread", tone: AppTheme.Colors.brandPrimary)
            }
        }
        .padding(.vertical, AppTheme.Spacing.xSmall)
    }
}

#Preview("iPhone") {
    NavigationView {
        ConversationListView(userID: "preview-user-001")
    }
    .environmentObject(AppEnvironment.bootstrap())
}

#Preview("iPad") {
    NavigationView {
        ConversationListView(userID: "preview-user-001")
    }
    .frame(width: 1024, height: 768)
    .environmentObject(AppEnvironment.bootstrap())
}
