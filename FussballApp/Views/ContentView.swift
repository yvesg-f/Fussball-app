import SwiftUI

struct ContentView: View {
    @StateObject private var store: LineupStore
    private let teamName: String
    @State private var selectedSlot: Int? = nil

    init(team: Team, appStore: AppStore) {
        self.teamName = team.name
        _store = StateObject(wrappedValue: LineupStore(team: team, appStore: appStore))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
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

                PitchView(store: store, selectedSlot: $selectedSlot)

                BenchView(store: store, selectedSlot: $selectedSlot)
            }
            .padding(.vertical)
        }
        .navigationTitle(teamName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.formation) { _ in selectedSlot = nil }
    }
}
