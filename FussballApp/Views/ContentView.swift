import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var store: LineupStore
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.displayScale) private var displayScale
    private let lineupName: String
    @State private var selectedSlot: Int? = nil
    @State private var showNotes = false
    @State private var showSetPieces = false
    @State private var pendingFormation: Formation? = nil
    @State private var showFormationAlert = false
    @State private var shareImage: UIImage? = nil
    @State private var showShareSheet = false

    private var formationBinding: Binding<Formation> {
        Binding(
            get: { store.formation },
            set: { newFormation in
                if !store.lineup.isEmpty {
                    pendingFormation = newFormation
                    showFormationAlert = true
                } else {
                    store.formation = newFormation
                }
            }
        )
    }

    init(team: Team, lineupIndex: Int, appStore: AppStore) {
        let name = lineupIndex < team.lineups.count ? team.lineups[lineupIndex].name : "Lineup"
        self.lineupName = name
        _store = StateObject(wrappedValue: LineupStore(team: team, lineupIndex: lineupIndex, appStore: appStore))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text(settings.t("formation"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Picker(settings.t("formation"), selection: formationBinding) {
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
        .navigationTitle(lineupName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: store.formation) { _ in selectedSlot = nil }
        .alert(settings.t("change_formation_title"), isPresented: $showFormationAlert) {
            Button(settings.t("change"), role: .destructive) {
                if let f = pendingFormation { store.formation = f }
                pendingFormation = nil
            }
            Button(settings.t("cancel"), role: .cancel) { pendingFormation = nil }
        } message: {
            Text(settings.t("reset_warning"))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let v = ShareableLineupView(store: store, lineupName: lineupName)
                    let r = ImageRenderer(content: v)
                    r.scale = displayScale
                    r.proposedSize = ProposedViewSize(width: 358, height: nil)
                    if let img = r.uiImage {
                        shareImage = img
                        showShareSheet = true
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showSetPieces = true } label: {
                        Label(settings.t("set_pieces"), systemImage: "figure.soccer")
                    }
                    Button { showNotes = true } label: {
                        Label(settings.t("tactic_notes"), systemImage: "note.text")
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
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ActivityViewController(activityItems: [img])
                    .ignoresSafeArea()
            }
        }
    }
}
