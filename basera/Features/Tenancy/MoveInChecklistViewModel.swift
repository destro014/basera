import Foundation

@MainActor
final class MoveInChecklistViewModel: ObservableObject {
    @Published private(set) var items: [TenancyRecord.MoveInChecklistItem] = []
    @Published var draftNotes: [String: String] = [:]

    func bind(_ tenancy: TenancyRecord) {
        items = tenancy.moveInChecklist
        draftNotes = Dictionary(uniqueKeysWithValues: tenancy.moveInChecklist.map { ($0.id, $0.note) })
    }

    func toggleComplete(itemID: String) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[idx].isCompleted.toggle()
    }

    func updateNote(itemID: String, note: String) {
        draftNotes[itemID] = note
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        items[idx].note = note
    }

    func save(tenancyID: String, userID: String, tenancyRepository: TenancyRepositoryProtocol) async {
        guard let updated = try? await tenancyRepository.updateMoveInChecklist(tenancyID: tenancyID, userID: userID, items: items) else { return }
        bind(updated)
    }
}
