import SwiftUI

struct ChatScreenView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: ChatScreenViewModel

    init(conversation: ChatConversation, currentUserID: String) {
        _viewModel = StateObject(wrappedValue: ChatScreenViewModel(conversation: conversation, currentUserID: currentUserID))
    }

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.senderID == viewModel.currentUserID { Spacer() }
                            Text(message.body)
                                .padding(AppTheme.Spacing.small)
                                .background(message.senderID == viewModel.currentUserID ? AppTheme.Colors.brandPrimary.opacity(0.2) : AppTheme.Colors.surfacePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
                            if message.senderID != viewModel.currentUserID { Spacer() }
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                BaseraTextField(title: "Message", prompt: "Type your message", text: $viewModel.draftMessage)
                BaseraButton(title: "Send", style: .primary) {
                    Task { await viewModel.send(using: environment.interestsRepository) }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Chat")
        .task {
            await viewModel.load(using: environment.interestsRepository)
        }
    }
}

#Preview("Chat approved") {
    NavigationView {
        ChatScreenView(conversation: PreviewData.mockConversations[0], currentUserID: "preview-user-001")
    }
    .environmentObject(AppEnvironment.bootstrap())
}
