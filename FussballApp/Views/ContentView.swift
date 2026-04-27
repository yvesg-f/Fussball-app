import SwiftUI

struct ContentView: View {
    @StateObject private var store: LineupStore
    private let teamName: String
    @State private var selectedSlot: Int? = nil
    @State private var activeZones: Set<PitchZone> = []
    @State private var showNotes = false
    @State private var showSetPieces = false

    init(team: Team, appStore: AppStore) {
        self.teamName = team.name
        _store = StateObject(wrappedValue: LineupStore(team: team, appStore: appStore))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // Plan A / Plan B picker
                Picker("Plan", selection: Binding(
                    get: { store.activeLineupIndex },
                    set: { store.switchLineup(to: $0) }
                )) {
                    ForEach(store.lineupNames.indices, id: \.self) { i in
                        Text(store.lineupNames[i]).tag(i)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Formation picker
                HStack {
                    Text("Formation")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Picker("Formation", selection: $store.formation) {
                        ForEach(Formation.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)

                PitchView(store: store, selectedSlot: $selectedSlot, activeZones: activeZones)

                // Zone toggle bar
                ZoneToggleBar(activeZones: $activeZones)

                BenchView(store: store, selectedSlot: $selectedSlot)
            }
            .padding(.vertical)
        }
        .navigationTitle(teamName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.formation) { _ in selectedSlot = nil }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showSetPieces = true
                    } label: {
                        Label("Standards", systemImage: "figure.soccer")
                    }
                    Button {
                        showNotes = true
                    } label: {
                        Label("Taktiknotizen", systemImage: "note.text")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showNotes) {
            TacticNotesView(store: store)
        }
        .sheet(isPresented: $showSetPieces) {
            SetPieceListView(store: store)
        }
    }
}

// MARK: - Zone toggle bar

private struct ZoneToggleBar: View {
    @Binding var activeZones: Set<PitchZone>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(PitchZone.allCases, id: \.self) { zone in
                    let isOn = activeZones.contains(zone)
                    Button {
                        if isOn { activeZones.remove(zone) }
                        else     { activeZones.insert(zone) }
                    } label: {
                        Text(zone.label)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                isOn ? zone.color.opacity(0.25) : Color(.secondarySystemBackground),
                                in: Capsule()
                            )
                            .foregroundStyle(isOn ? zone.color : .secondary)
                            .overlay(Capsule().strokeBorder(isOn ? zone.color.opacity(0.6) : .clear, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.15), value: isOn)
                }
            }
            .padding(.horizontal)
        }
    }
}
