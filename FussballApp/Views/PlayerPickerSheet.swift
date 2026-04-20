import SwiftUI

struct PlayerPickerSheet: View {
    @ObservedObject var store: LineupStore
    let slot: Int
    @Environment(\.dismiss) private var dismiss

    private var currentName: String? { store.playerName(forSlot: slot) }

    var body: some View {
        NavigationStack {
            List {
                // Remove option — only shown when slot is occupied
                if currentName != nil {
                    Section {
                        Button(role: .destructive) {
                            store.remove(fromSlot: slot)
                            dismiss()
                        } label: {
                            Label("Spieler entfernen", systemImage: "person.fill.xmark")
                        }
                    }
                }

                // Bench players to assign or swap in
                if store.benchPlayers.isEmpty {
                    if currentName == nil {
                        // Slot empty, nobody on bench
                        VStack(spacing: 12) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            Text("Keine Spieler auf der Bank")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                    // If slot is occupied + bench empty: only the remove button is shown above
                } else {
                    Section(currentName != nil ? "Tauschen mit" : "Spieler wählen") {
                        ForEach(store.benchPlayers, id: \.self) { name in
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
            }
            .navigationTitle(currentName != nil ? currentName! : "Spieler wählen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}
