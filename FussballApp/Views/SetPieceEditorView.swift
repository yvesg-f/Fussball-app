import SwiftUI

private extension ArrowColor {
    var color: Color {
        switch self {
        case .blue:   return .cyan
        case .orange: return .orange
        case .red:    return .red
        }
    }
}

struct SetPieceEditorView: View {
    @ObservedObject var store: LineupStore
    @Environment(\.dismiss) private var dismiss

    @State private var piece: SetPiece
    @State private var isDrawMode = false
    @State private var selectedArrowColor: ArrowColor = .blue
    @State private var pendingPlayer: String? = nil
    @State private var currentArrowPoints: [[Double]] = []

    init(store: LineupStore, piece: SetPiece) {
        self.store = store
        _piece = State(initialValue: piece)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Name field
                TextField("Name des Standards…", text: $piece.name)
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    .background(Color(.secondarySystemBackground))

                // Mode + arrow color toolbar
                HStack(spacing: 12) {
                    Button {
                        isDrawMode.toggle()
                        pendingPlayer = nil
                    } label: {
                        Label(isDrawMode ? "Zeichnen" : "Bewegen",
                              systemImage: isDrawMode ? "pencil.circle.fill" : "hand.point.up.left.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                    .tint(isDrawMode ? .purple : .secondary)

                    if isDrawMode {
                        ForEach(ArrowColor.allCases, id: \.self) { c in
                            Button {
                                selectedArrowColor = c
                            } label: {
                                ZStack {
                                    Circle().fill(c.color).frame(width: 26, height: 26)
                                    if selectedArrowColor == c {
                                        Circle().strokeBorder(.white, lineWidth: 2).frame(width: 26, height: 26)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        Button {
                            if !piece.arrows.isEmpty { piece.arrows.removeLast() }
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .foregroundStyle(piece.arrows.isEmpty ? .quaternary : .secondary)
                        }
                        .buttonStyle(.plain)
                        .disabled(piece.arrows.isEmpty)
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Half pitch
                HalfPitchEditorView(
                    piece: $piece,
                    pendingPlayer: $pendingPlayer,
                    currentArrowPoints: $currentArrowPoints,
                    isDrawMode: isDrawMode,
                    selectedArrowColor: selectedArrowColor
                )
                .frame(height: 310)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Player strip
                PlayerStripView(
                    players: store.allPlayerNames,
                    placedPlayers: Set(piece.playerPositions.keys),
                    pendingPlayer: $pendingPlayer,
                    isDrawMode: isDrawMode
                )
                .frame(height: 70)

                Spacer()
            }
            .navigationTitle(piece.type.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        store.saveSetPiece(piece)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Half pitch editor

private struct HalfPitchEditorView: View {
    @Binding var piece: SetPiece
    @Binding var pendingPlayer: String?
    @Binding var currentArrowPoints: [[Double]]
    let isDrawMode: Bool
    let selectedArrowColor: ArrowColor

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.17, green: 0.54, blue: 0.20))
                .overlay(HalfPitchLines().clipShape(RoundedRectangle(cornerRadius: 14)))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.25), lineWidth: 1))

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                ZStack {
                    // Background interaction layer
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { drag in
                                    if isDrawMode {
                                        currentArrowPoints.append(
                                            [drag.location.x / w, drag.location.y / h]
                                        )
                                    }
                                }
                                .onEnded { drag in
                                    if isDrawMode {
                                        if currentArrowPoints.count > 1 {
                                            piece.arrows.append(DrawnArrow(
                                                points: currentArrowPoints,
                                                color: selectedArrowColor
                                            ))
                                        }
                                        currentArrowPoints = []
                                    } else if let player = pendingPlayer {
                                        piece.playerPositions[player] = [
                                            max(0.02, min(0.98, drag.startLocation.x / w)),
                                            max(0.02, min(0.98, drag.startLocation.y / h))
                                        ]
                                        pendingPlayer = nil
                                    }
                                }
                        )

                    // Saved arrows
                    ForEach(piece.arrows) { arrow in
                        ArrowShape(points: arrow.points, size: CGSize(width: w, height: h))
                            .stroke(arrow.color.color,
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        ArrowHead(points: arrow.points, size: CGSize(width: w, height: h))
                            .fill(arrow.color.color)
                    }

                    // Live arrow being drawn
                    if !currentArrowPoints.isEmpty {
                        ArrowShape(points: currentArrowPoints, size: CGSize(width: w, height: h))
                            .stroke(selectedArrowColor.color.opacity(0.7),
                                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }

                    // Ball marker
                    if piece.ballPosition.count == 2 {
                        BallMarker()
                            .position(x: piece.ballPosition[0] * w, y: piece.ballPosition[1] * h)
                            .gesture(
                                DragGesture(minimumDistance: 2)
                                    .onChanged { drag in
                                        guard !isDrawMode else { return }
                                        piece.ballPosition = [
                                            max(0.02, min(0.98, drag.location.x / w)),
                                            max(0.02, min(0.98, drag.location.y / h))
                                        ]
                                    }
                            )
                    }

                    // Placed player chips
                    ForEach(Array(piece.playerPositions.keys), id: \.self) { name in
                        if let pos = piece.playerPositions[name], pos.count == 2 {
                            MiniChip(name: name)
                                .position(x: pos[0] * w, y: pos[1] * h)
                                .gesture(
                                    DragGesture(minimumDistance: 0)
                                        .onChanged { drag in
                                            guard !isDrawMode else { return }
                                            piece.playerPositions[name] = [
                                                max(0.02, min(0.98, drag.location.x / w)),
                                                max(0.02, min(0.98, drag.location.y / h))
                                            ]
                                        }
                                        .onEnded { drag in
                                            guard !isDrawMode else { return }
                                            // Tap (minimal movement) removes the chip
                                            let moved = hypot(drag.translation.width, drag.translation.height)
                                            if moved < 5 {
                                                piece.playerPositions.removeValue(forKey: name)
                                            }
                                        }
                                )
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

// MARK: - Player strip

private struct PlayerStripView: View {
    let players: [String]
    let placedPlayers: Set<String>
    @Binding var pendingPlayer: String?
    let isDrawMode: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(players, id: \.self) { name in
                    let isPending = pendingPlayer == name
                    let isPlaced  = placedPlayers.contains(name)
                    Button {
                        guard !isDrawMode else { return }
                        pendingPlayer = isPending ? nil : name
                    } label: {
                        Text(name)
                            .font(.system(size: 11, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(
                                isPending ? Color.cyan.opacity(0.3) :
                                isPlaced  ? Color.green.opacity(0.15) :
                                            Color(.tertiarySystemBackground),
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                            .foregroundStyle(
                                isDrawMode ? .tertiary :
                                isPending  ? .cyan :
                                isPlaced   ? .green :
                                             .primary
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(isPending ? Color.cyan : .clear, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .animation(.easeInOut(duration: 0.12), value: isPending)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Shapes

private struct ArrowShape: Shape {
    let points: [[Double]]
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        guard points.count > 1 else { return Path() }
        var p = Path()
        p.move(to: CGPoint(x: points[0][0] * size.width, y: points[0][1] * size.height))
        for pt in points.dropFirst() {
            p.addLine(to: CGPoint(x: pt[0] * size.width, y: pt[1] * size.height))
        }
        return p
    }
}

private struct ArrowHead: Shape {
    let points: [[Double]]
    let size: CGSize

    func path(in rect: CGRect) -> Path {
        guard points.count >= 2 else { return Path() }
        let last   = points[points.count - 1]
        let second = points[max(0, points.count - 5)]
        let tip  = CGPoint(x: last[0]   * size.width, y: last[1]   * size.height)
        let base = CGPoint(x: second[0] * size.width, y: second[1] * size.height)
        let angle = atan2(tip.y - base.y, tip.x - base.x)
        let len: CGFloat = 10
        let spread: CGFloat = 0.5
        let l = CGPoint(x: tip.x - len * cos(angle - spread),
                        y: tip.y - len * sin(angle - spread))
        let r = CGPoint(x: tip.x - len * cos(angle + spread),
                        y: tip.y - len * sin(angle + spread))
        var p = Path()
        p.move(to: tip)
        p.addLine(to: l)
        p.addLine(to: r)
        p.closeSubpath()
        return p
    }
}

private struct BallMarker: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 20, height: 20)
                .shadow(color: .black.opacity(0.35), radius: 2)
            Image(systemName: "soccerball")
                .font(.system(size: 13))
                .foregroundStyle(.black)
        }
    }
}

private struct MiniChip: View {
    let name: String
    var body: some View {
        Text(name)
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.black)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(.white, in: RoundedRectangle(cornerRadius: 6))
            .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
    }
}
