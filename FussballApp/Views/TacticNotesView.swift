import SwiftUI

struct TacticNotesView: View {
    @ObservedObject var store: LineupStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""

    var body: some View {
        NavigationStack {
            TextEditor(text: $draft)
                .padding()
                .navigationTitle(settings.t("tactic_notes_title"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(settings.t("cancel")) { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(settings.t("save")) {
                            store.saveTacticNotes(draft)
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
        }
        .onAppear { draft = store.tacticNotes }
    }
}
