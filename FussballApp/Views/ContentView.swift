import SwiftUI

struct ContentView: View {
    @StateObject private var store = LineupStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("Formation", selection: $store.formation) {
                        ForEach(Formation.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    PitchView(store: store)

                    BenchView(store: store)
                }
                .padding(.vertical)
            }
            .navigationTitle("Aufstellung")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
