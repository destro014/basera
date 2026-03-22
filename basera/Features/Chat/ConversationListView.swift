import SwiftUI
import VroxalDesign

struct ConversationListView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: ConversationListViewModel

    init(userID: String) {
        _viewModel = StateObject(wrappedValue: ConversationListViewModel(userID: userID))
    }

    var body: some View {
        List {
            if viewModel.conversations.isEmpty {
                VdEmptyState(
                    title: "No conversations yet",
                    message: "Chat is available only after owner approval in the interest flow.",
                    systemImage: "bubble.left.and.bubble.right"
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.conversations) { conversation in
                    NavigationLink {
                        ChatScreenView(conversation: conversation, currentUserID: viewModel.userID)
                    } label: {
                        ConversationRowView(conversation: conversation)
                    }
                    .listRowBackground(Color.vdBackgroundDefaultSecondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .baseraListBackground()
        .navigationTitle("Messages")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
    }
}

private struct ConversationRowView: View {
    let conversation: ChatConversation

    var body: some View {
        VStack(alignment: .leading, spacing: VdSpacing.xs) {
            Text(conversation.participantName)
                .vdFont(VdFont.titleSmall)
            Text(conversation.listingTitle)
                .vdFont(VdFont.bodySmall)
                .foregroundStyle(Color.vdContentDefaultSecondary)
            Text(conversation.lastMessagePreview)
                .lineLimit(1)
                .vdFont(VdFont.bodySmall)
            if conversation.unreadCount > 0 {
                VdBadge("\(conversation.unreadCount) unread", color: .primary, style: .solid, rounded: true)
            }
        }
        .padding(.vertical, VdSpacing.xs)
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
