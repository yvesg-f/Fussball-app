import SwiftUI
import UIKit

// MARK: - Share sheet wrapper

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Lineup snapshot view (pitch + bench)

struct ShareableLineupView: View {
    let store: LineupStore
    let lineupName: String

    private let W: CGFloat = 358
    private let H: CGFloat = 420

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(lineupName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    Text(store.formation.rawValue)
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.75))
                }
                Spacer()
                Text("Tactix")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(red: 0.10, green: 0.36, blue: 0.12))

            // Pitch
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.17, green: 0.54, blue: 0.20))
                    .overlay(PitchLines())

                ForEach(0..<store.formation.totalSlots, id: \.self) { slot in
                    let pos = store.position(for: slot)
                    let name = store.playerName(forSlot: slot)
                    PlayerChip(
                        name: name,
                        isGoalkeeper: store.isGoalkeeper(slot: slot),
                        isCaptain: name != nil && name == store.captainName
                    )
                    .position(x: pos.x * W, y: pos.y * H)
                }
            }
            .frame(width: W, height: H)

            // Bench strip
            let benched = store.benchPlayers
            if !benched.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Bank")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.top, 8)

                    let chunks = stride(from: 0, to: benched.count, by: 5)
                        .map { Array(benched[$0..<min($0 + 5, benched.count)]) }

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(chunks.indices, id: \.self) { i in
                            HStack(spacing: 6) {
                                ForEach(chunks[i], id: \.self) { name in
                                    Text(name)
                                        .font(.system(size: 11, weight: .medium))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(Color(.systemGray5),
                                                    in: RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .background(Color(.secondarySystemBackground))
            }
        }
        .frame(width: W)
        .background(Color(.systemBackground))
    }
}

// MARK: - Set piece snapshot view

struct SetPieceShareView: View {
    let piece: SetPiece

    private let W: CGFloat = 358
    private var H: CGFloat { piece.type.usesFullPitch ? 400 : 300 }

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack(spacing: 8) {
                Image(systemName: piece.type.symbol)
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.8))
                Text(piece.name.isEmpty ? piece.type.rawValue : piece.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("Tactix")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(red: 0.10, green: 0.36, blue: 0.12))

            // Pitch
            ZStack {
                Rectangle()
                    .fill(Color(red: 0.17, green: 0.54, blue: 0.20))
                    .overlay(
                        Group {
                            if piece.type.usesFullPitch {
                                PitchLines()
                            } else {
                                HalfPitchLines()
                            }
                        }
                    )

                ForEach(piece.arrows) { arrow in
                    ArrowShape(points: arrow.points, size: CGSize(width: W, height: H))
                        .stroke(arrow.color.color,
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    ArrowHead(points: arrow.points, size: CGSize(width: W, height: H))
                        .fill(arrow.color.color)
                }

                if piece.ballPosition.count == 2 {
                    BallMarker()
                        .position(x: piece.ballPosition[0] * W, y: piece.ballPosition[1] * H)
                }

                ForEach(Array(piece.playerPositions.keys), id: \.self) { name in
                    if let pos = piece.playerPositions[name], pos.count == 2 {
                        MiniChip(name: name)
                            .position(x: pos[0] * W, y: pos[1] * H)
                    }
                }

                ForEach(Array(piece.opponentPositions.enumerated()), id: \.offset) { _, pos in
                    if pos.count == 2 {
                        OpponentMarker()
                            .position(x: pos[0] * W, y: pos[1] * H)
                    }
                }
            }
            .frame(width: W, height: H)
        }
        .frame(width: W)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
