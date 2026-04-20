import SwiftUI

struct BenchView: View {
    @ObservedObject var store: LineupStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
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
        .padding(.bottom, 24)
    }
}
