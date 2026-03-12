import Foundation

@MainActor
final class ChatScreenViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var draftMessage = ""

    let conversation: ChatConversation
    let currentUserID: String

    init(conversation: ChatConversation, currentUserID: String) {
        self.conversation = conversation
        self.currentUserID = currentUserID
    }

    func load(using repository: InterestsRepositoryProtocol) async {
        messages = (try? await repository.fetchMessages(conversationID: conversation.id, userID: currentUserID)) ?? []
    }

    func send(using repository: InterestsRepositoryProtocol) async {
        let text = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        try? await repository.sendMessage(conversationID: conversation.id, senderID: currentUserID, body: text)
        draftMessage = ""
        await load(using: repository)
    }
}
