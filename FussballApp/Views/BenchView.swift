import SwiftUI

struct BenchView: View {
    @ObservedObject var store: LineupStore
    @Binding var selectedSlot: Int?

    private var selectedName: String? {
        selectedSlot.flatMap { store.playerName(forSlot: $0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // --- Selection action bar ---
            if let name = selectedName, let slot = selectedSlot {
                let isCaptain = store.captainName == name

                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "person.fill.checkmark")
                            .foregroundStyle(.cyan)
                        Text("\(name) ausgewählt")
                            .font(.headline)
                        Spacer()
                        Button {
                            selectedSlot = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 22))
                        }
                    }
                    .padding(.horizontal)

                    HStack(spacing: 10) {
                        // Captain toggle
                        Button {
                            store.toggleCaptain(for: name)
                        } label: {
                            Label(isCaptain ? "Kein Kapitän" : "Kapitän",
                                  systemImage: isCaptain ? "crown" : "crown.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(isCaptain ? .secondary : .yellow)

                        // Remove from pitch
                        Button(role: .destructive) {
                            store.remove(fromSlot: slot)
                            selectedSlot = nil
                        } label: {
                            Label("Entfernen", systemImage: "person.fill.xmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.horizontal)

                    if !store.benchPlayers.isEmpty {
                        Text("Tauschen mit:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 90), spacing: 8)],
                            spacing: 8
                        ) {
                            ForEach(store.benchPlayers, id: \.self) { benchName in
                                Button {
                                    store.assign(name: benchName, toSlot: slot)
                                    selectedSlot = nil
                                } label: {
                                    Text(benchName)
                                        .font(.system(size: 12, weight: .medium))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(.cyan.opacity(0.15),
                                                    in: RoundedRectangle(cornerRadius: 8))
                                        .foregroundStyle(.primary)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(.cyan.opacity(0.4), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(.cyan.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

            } else {
                // --- Normal bench view ---
                HStack {
                    Text("Bank")
                        .font(.headline)
                    Spacer()
                    Text("\(store.benchPlayers.count) Spieler")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                if store.benchPlayers.isEmpty {
                    Label("Alle Spieler eingeteilt", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                        .padding(.horizontal)
                } else {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 90), spacing: 8)],
                        spacing: 8
                    ) {
                        ForEach(store.benchPlayers, id: \.self) { name in
                            Text(name)
                                .font(.system(size: 12, weight: .medium))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(.secondary.opacity(0.15),
                                            in: RoundedRectangle(cornerRadius: 8))
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 24)
    }
}
