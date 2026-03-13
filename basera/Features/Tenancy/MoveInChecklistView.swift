import SwiftUI

struct MoveInChecklistView: View {
    @EnvironmentObject private var environment: AppEnvironment
    @StateObject private var viewModel = MoveInChecklistViewModel()

    let tenancy: TenancyRecord
    let userID: String

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                Section {
                    Toggle(isOn: Binding(
                        get: { item.isCompleted },
                        set: { _ in viewModel.toggleComplete(itemID: item.id) }
                    )) {
                        Text(item.title)
                    }

                    TextField("Add note", text: Binding(
                        get: { viewModel.draftNotes[item.id, default: ""] },
                        set: { viewModel.updateNote(itemID: item.id, note: $0) }
                    ))

                    ForEach(item.photoPlaceholders, id: \.self) { placeholder in
                        HStack {
                            Image(systemName: "photo")
                            Text(placeholder)
                                .foregroundStyle(AppTheme.Colors.textSecondary)
                        }
                    }
                } header: {
                    Text(item.category.title)
                }
            }
        }
        .baseraListBackground()
        .navigationTitle("Move-in Checklist")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                        await viewModel.save(tenancyID: tenancy.id, userID: userID, tenancyRepository: environment.tenancyRepository)
                    }
                }
            }
        }
        .onAppear {
            viewModel.bind(tenancy)
        }
    }
}

#Preview {
    NavigationView {
        MoveInChecklistView(tenancy: PreviewData.mockTenancies[0], userID: "preview-user-001")
            .environmentObject(AppEnvironment.bootstrap())
    }
}
