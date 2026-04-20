import SwiftUI

struct PlayerPickerSheet: View {
    @ObservedObject var store: LineupStore
    let slot: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.benchPlayers.isEmpty {
                    ContentUnavailableView(
                        "Keine Spieler verfügbar",
                        systemImage: "person.slash",
                        description: Text("Alle Spieler sind bereits eingeteilt.")
                    )
                } else {
                    List(store.benchPlayers, id: \.self) { name in
                        Button {
                            store.assign(name: name, toSlot: slot)
                            dismiss()
                        } label: {
                            Label(name, systemImage: "person.fill")
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
            .navigationTitle("Spieler wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}
