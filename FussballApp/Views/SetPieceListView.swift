import SwiftUI

struct SetPieceListView: View {
    @ObservedObject var store: LineupStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var editingPiece: SetPiece? = nil
    @State private var showTypePicker = false
    @State private var showUpgrade = false

    private var grouped: [(SetPieceType, [SetPiece])] {
        SetPieceType.allCases.compactMap { type in
            let pieces = store.setPieces.filter { $0.type == type }
            return pieces.isEmpty ? nil : (type, pieces)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.setPieces.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.soccer")
                            .font(.system(size: 52))
                            .foregroundStyle(.secondary)
                        Text("Keine Standards gespeichert")
                            .font(.headline)
                        Text("Tippe auf + um einen Standard zu erstellen.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(grouped, id: \.0) { type, pieces in
                            Section(type.rawValue) {
                                ForEach(pieces) { piece in
                                    Button {
                                        editingPiece = piece
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: type.symbol)
                                                .foregroundStyle(.green)
                                                .frame(width: 24)
                                            Text(piece.name.isEmpty ? "Unbenannt" : piece.name)
                                                .foregroundStyle(.primary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                                .onDelete { offsets in
                                    offsets.forEach { i in store.deleteSetPiece(id: pieces[i].id) }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Standards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if purchaseManager.isPro || store.setPieces.count < PurchaseManager.freePieceLimit {
                            showTypePicker = true
                        } else {
                            showUpgrade = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingPiece) { piece in
                SetPieceEditorView(store: store, piece: piece)
            }
            .sheet(isPresented: $showUpgrade) {
                ProUpgradeView()
            }
            .confirmationDialog("Art des Standards", isPresented: $showTypePicker, titleVisibility: .visible) {
                ForEach(SetPieceType.allCases, id: \.self) { type in
                    Button(type.rawValue) {
                        editingPiece = SetPiece(type: type)
                    }
                }
                Button("Abbrechen", role: .cancel) {}
            }
        }
    }
}
