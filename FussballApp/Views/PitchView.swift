import SwiftUI
import UIKit

private struct PickerSlot: Identifiable { let id: Int }

struct PitchView: View {
    @ObservedObject var store: LineupStore
    @State private var pickerSlot: PickerSlot?
    @State private var draggingSlot: Int? = nil
    @State private var dragStartPos: CGPoint = .zero

    var body: some View {
        ZStack {
            // Pitch background
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.17, green: 0.54, blue: 0.20))
                .overlay(PitchLines().clipShape(RoundedRectangle(cornerRadius: 14)))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.25), lineWidth: 1))

            GeometryReader { geo in
                let pw = geo.size.width
                let ph = geo.size.height

                ZStack {
                    ForEach(0..<store.formation.totalSlots, id: \.self) { slot in
                        SlotChipView(
                            slot: slot,
                            store: store,
                            pitchSize: CGSize(width: pw, height: ph),
                            draggingSlot: $draggingSlot,
                            dragStartPos: $dragStartPos,
                            pickerSlot: $pickerSlot
                        )
                    }
                }
                .coordinateSpace(name: "pitch")
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .frame(height: 440)
        .padding(.horizontal)
        .sheet(item: $pickerSlot) { slot in
            PlayerPickerSheet(store: store, slot: slot.id)
        }
    }
}

// MARK: - Per-slot chip with gesture

private struct SlotChipView: View {
    let slot: Int
    @ObservedObject var store: LineupStore
    let pitchSize: CGSize
    @Binding var draggingSlot: Int?
    @Binding var dragStartPos: CGPoint
    @Binding var pickerSlot: PickerSlot?

    private var name: String? { store.playerName(forSlot: slot) }
    private var isGK: Bool { store.isGoalkeeper(slot: slot) }
    private var isDraggingMe: Bool { draggingSlot == slot }

    private var chipPos: CGPoint {
        let rel = store.position(for: slot)
        return CGPoint(x: rel.x * pitchSize.width, y: rel.y * pitchSize.height)
    }

    var body: some View {
        PlayerChip(name: name, isGoalkeeper: isGK)
            .scaleEffect(isDraggingMe ? 1.18 : 1.0)
            .shadow(color: isDraggingMe ? .black.opacity(0.45) : .clear, radius: 10)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDraggingMe)
            .position(chipPos)
            .onTapGesture {
                guard draggingSlot == nil else { return }
                if name != nil {
                    store.remove(fromSlot: slot)
                } else {
                    pickerSlot = PickerSlot(id: slot)
                }
            }
            .gesture(
                LongPressGesture(minimumDuration: 0.35)
                    .sequenced(before: DragGesture(minimumDistance: 0,
                                                   coordinateSpace: .named("pitch")))
                    .onChanged { value in
                        guard name != nil else { return }
                        switch value {
                        case .first(true):
                            draggingSlot = slot
                            dragStartPos = store.position(for: slot)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        case .second(true, let drag?):
                            guard draggingSlot == slot else { return }
                            let newX = (dragStartPos.x * pitchSize.width + drag.translation.width) / pitchSize.width
                            let newY = (dragStartPos.y * pitchSize.height + drag.translation.height) / pitchSize.height
                            store.setPosition(for: slot, point: CGPoint(
                                x: max(0.04, min(0.96, newX)),
                                y: max(0.04, min(0.96, newY))
                            ))
                        default: break
                        }
                    }
                    .onEnded { _ in
                        draggingSlot = nil
                    }
            )
    }
}
