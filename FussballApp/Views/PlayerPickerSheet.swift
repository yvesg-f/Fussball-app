import SwiftUI

struct PlayerPickerSheet: View {
    @ObservedObject var store: LineupStore
    let slot: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.benchPlayers.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Keine Spieler verfügbar")
                            .font(.headline)
                        Text("Alle Spieler sind bereits eingeteilt.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
