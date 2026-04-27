import SwiftUI

struct TacticNotesView: View {
    @ObservedObject var store: LineupStore
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""

    var body: some View {
        NavigationStack {
            TextEditor(text: $draft)
                .padding()
                .navigationTitle("Taktiknotizen")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Speichern") {
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
