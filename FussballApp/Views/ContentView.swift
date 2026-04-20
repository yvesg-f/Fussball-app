import SwiftUI

struct ContentView: View {
    @StateObject private var store = LineupStore()
    @State private var selectedSlot: Int? = nil

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

                    PitchView(store: store, selectedSlot: $selectedSlot)

                    BenchView(store: store, selectedSlot: $selectedSlot)
                }
                .padding(.vertical)
            }
            .navigationTitle("Aufstellung")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: store.formation) { _ in selectedSlot = nil }
        }
    }
}
