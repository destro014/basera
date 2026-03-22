import SwiftUI
import VroxalDesign

struct ChatScreenView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel: ChatScreenViewModel

    init(conversation: ChatConversation, currentUserID: String) {
        _viewModel = StateObject(wrappedValue: ChatScreenViewModel(conversation: conversation, currentUserID: currentUserID))
    }

    var body: some View {
        VStack(spacing: VdSpacing.sm) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: VdSpacing.sm) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.senderID == viewModel.currentUserID { Spacer() }
                            Text(message.body)
                                .padding(VdSpacing.sm)
                                .background(message.senderID == viewModel.currentUserID ? Color.vdBackgroundPrimaryBase.opacity(0.2) : Color.vdBackgroundDefaultSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: VdRadius.md, style: .continuous))
                            if message.senderID != viewModel.currentUserID { Spacer() }
                        }
                    }
                }
                .padding(.horizontal)
            }

            HStack {
                VdTextField(title: "Message", prompt: "Type your message", text: $viewModel.draftMessage)
                VdButton(title: "Send", style: .primary) {
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
