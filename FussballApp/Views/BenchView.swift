import SwiftUI

struct BenchView: View {
    @ObservedObject var store: LineupStore
    @EnvironmentObject private var settings: AppSettings
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
                        Text(String(format: settings.t("selected_player"), name))
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
                        Button {
                            store.toggleCaptain(for: name)
                        } label: {
                            Label(isCaptain ? settings.t("remove_captain") : settings.t("set_captain"),
                                  systemImage: isCaptain ? "crown" : "crown.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(isCaptain ? .secondary : .yellow)

                        Button(role: .destructive) {
                            store.remove(fromSlot: slot)
                            selectedSlot = nil
                        } label: {
                            Label(settings.t("remove"), systemImage: "person.fill.xmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                    .padding(.horizontal)

                    if !store.benchPlayers.isEmpty {
                        Text(settings.t("swap_with"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        PlayerGrid(names: store.benchPlayers) { benchName in
                            store.assign(name: benchName, toSlot: slot)
                            selectedSlot = nil
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 8)
                .background(.cyan.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

            } else {
                // --- Bank ---
                SectionHeader(
                    title: settings.t("bench"),
                    count: store.benchPlayers.count,
                    emptyLabel: settings.t("no_bench_players")
                )

                if !store.benchPlayers.isEmpty {
                    TagGrid(names: store.benchPlayers, symbol: "minus.circle.fill", tint: .cyan) { name in
                        store.removeFromBench(name)
                    }
                    .padding(.horizontal)
                }

                // --- Nicht dabei ---
                SectionHeader(
                    title: settings.t("not_available"),
                    count: store.unselectedPlayers.count,
                    emptyLabel: nil
                )

                if store.unselectedPlayers.isEmpty {
                    Label(settings.t("all_assigned_or_bench"), systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.subheadline)
                        .padding(.horizontal)
                } else {
                    TagGrid(names: store.unselectedPlayers, symbol: "plus.circle.fill", tint: .secondary) { name in
                        store.addToBench(name)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 24)
    }
}

// MARK: - Helpers

private struct SectionHeader: View {
    @EnvironmentObject private var settings: AppSettings
    let title: String
    let count: Int
    let emptyLabel: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(String(format: settings.t("player_count"), count))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
}

private struct TagGrid: View {
    let names: [String]
    let symbol: String
    let tint: Color
    let onTap: (String) -> Void

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 90), spacing: 8)],
            spacing: 8
        ) {
            ForEach(names, id: \.self) { name in
                Button { onTap(name) } label: {
                    HStack(spacing: 4) {
                        Text(name)
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Image(systemName: symbol)
                            .font(.system(size: 11))
                            .foregroundStyle(tint)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(tint.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct PlayerGrid: View {
    let names: [String]
    let onTap: (String) -> Void

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 90), spacing: 8)],
            spacing: 8
        ) {
            ForEach(names, id: \.self) { name in
                Button { onTap(name) } label: {
                    Text(name)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(.cyan.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
                        .foregroundStyle(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.cyan.opacity(0.4), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
