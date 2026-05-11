import SwiftUI

struct PitchView: View {
    @ObservedObject var store: LineupStore
    @Binding var selectedSlot: Int?

    @State private var pickerSlot: Int? = nil
    @State private var draggingSlot: Int? = nil
    @State private var dragStartPos: CGPoint = .zero

    var body: some View {
        ZStack {
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
                            selectedSlot: $selectedSlot,
                            pickerSlot: $pickerSlot,
                            draggingSlot: $draggingSlot,
                            dragStartPos: $dragStartPos
                        )
                    }
                }
                .coordinateSpace(name: "pitch")
                .onTapGesture { selectedSlot = nil }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .frame(height: 440)
        .padding(.horizontal)
        .sheet(item: Binding(
            get: { pickerSlot.map { PickerID(id: $0) } },
            set: { pickerSlot = $0?.id }
        )) { p in
            EmptySlotPickerSheet(store: store, slot: p.id)
        }
    }
}

private struct PickerID: Identifiable { let id: Int }

// MARK: - Per-slot chip

private struct SlotChipView: View {
    let slot: Int
    @ObservedObject var store: LineupStore
    let pitchSize: CGSize
    @Binding var selectedSlot: Int?
    @Binding var pickerSlot: Int?
    @Binding var draggingSlot: Int?
    @Binding var dragStartPos: CGPoint

    private var name: String? { store.playerName(forSlot: slot) }
    private var isGK: Bool { store.isGoalkeeper(slot: slot) }
    private var isSelected: Bool { selectedSlot == slot }
    private var isDraggingMe: Bool { draggingSlot == slot }
    private var isCaptain: Bool {
        guard let n = name else { return false }
        return store.captainName == n
    }

    private var chipPos: CGPoint {
        let rel = store.position(for: slot)
        return CGPoint(x: rel.x * pitchSize.width, y: rel.y * pitchSize.height)
    }

    var body: some View {
        PlayerChip(name: name, isGoalkeeper: isGK, isCaptain: isCaptain)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.cyan : .clear, lineWidth: 3)
            )
            .scaleEffect(isDraggingMe ? 1.18 : (isSelected ? 1.08 : 1.0))
            .shadow(color: isDraggingMe ? .black.opacity(0.45) : (isSelected ? .cyan.opacity(0.5) : .clear), radius: 10)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDraggingMe)
            .position(chipPos)
            .onTapGesture {
                guard draggingSlot == nil else { return }
                if name != nil {
                    selectedSlot = isSelected ? nil : slot
                } else {
                    if selectedSlot == nil { pickerSlot = slot }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 6, coordinateSpace: .named("pitch"))
                    .onChanged { drag in
                        guard name != nil else { return }
                        if draggingSlot != slot {
                            draggingSlot = slot
                            dragStartPos = store.position(for: slot)
                            selectedSlot = nil
                        }
                        let newX = (dragStartPos.x * pitchSize.width + drag.translation.width) / pitchSize.width
                        let newY = (dragStartPos.y * pitchSize.height + drag.translation.height) / pitchSize.height
                        store.setPosition(for: slot, point: CGPoint(
                            x: max(0.04, min(0.96, newX)),
                            y: max(0.04, min(0.96, newY))
                        ))
                    }
                    .onEnded { _ in draggingSlot = nil }
            )
    }
}

// MARK: - Sheet for assigning a player to an empty slot

private struct EmptySlotPickerSheet: View {
    @ObservedObject var store: LineupStore
    @EnvironmentObject private var settings: AppSettings
    let slot: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if store.playersNotInLineup.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "person.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text(settings.t("all_players_assigned"))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(store.playersNotInLineup, id: \.self) { name in
                        Button {
                            store.assign(name: name, toSlot: slot)
                            dismiss()
                        } label: {
                            Label(name, systemImage: "person.fill")
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
            }
            .navigationTitle(settings.t("select_player"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(settings.t("cancel")) { dismiss() }
                }
            }
        }
    }
}
