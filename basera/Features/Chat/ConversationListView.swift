import SwiftUI

struct ConversationListView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: ConversationListViewModel

    init(userID: String) {
        _viewModel = StateObject(wrappedValue: ConversationListViewModel(userID: userID))
    }

    var body: some View {
        List(viewModel.conversations) { conversation in
            NavigationLink {
                ChatScreenView(conversation: conversation, currentUserID: viewModel.userID)
            } label: {
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
        .navigationTitle("Conversations")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
    }
}

#Preview {
    NavigationView {
        ConversationListView(userID: "preview-user-001")
    }
    .environmentObject(AppEnvironment.bootstrap())
}
