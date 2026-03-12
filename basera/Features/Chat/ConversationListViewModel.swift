import Combine
import Foundation

@MainActor
final class ConversationListViewModel: ObservableObject {
    @Published private(set) var conversations: [ChatConversation] = []
    let userID: String

    init(userID: String) {
        self.userID = userID
    }

    func load(using repository: InterestsRepositoryProtocol) async {
        conversations = (try? await repository.fetchConversations(for: userID)) ?? []
    }
}
