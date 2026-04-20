import SwiftUI

private struct SlotID: Identifiable { let id: Int }

struct PitchView: View {
    @ObservedObject var store: LineupStore
    @State private var pickerSlot: SlotID?

    private var rowsWithOffsets: [(row: Formation.Row, offset: Int)] {
        var result: [(row: Formation.Row, offset: Int)] = []
        var offset = 0
        for row in store.formation.rows {
            result.append((row: row, offset: offset))
            offset += row.count
        }
        result.reverse()
        return result
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.17, green: 0.54, blue: 0.20))
                .overlay(PitchLines().clipShape(RoundedRectangle(cornerRadius: 14)))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.white.opacity(0.25), lineWidth: 1))

            VStack(spacing: 0) {
                ForEach(Array(rowsWithOffsets.enumerated()), id: \.offset) { _, pair in
                    Spacer(minLength: 6)
                    PositionRowView(row: pair.row, slotOffset: pair.offset,
                                   store: store, pickerSlot: $pickerSlot)
                }
                Spacer(minLength: 6)
            }
            .padding(.horizontal, 12)
        }
        .frame(height: 440)
        .padding(.horizontal)
        .sheet(item: $pickerSlot) { slot in
            PlayerPickerSheet(store: store, slot: slot.id)
        }
    }
}

private struct PositionRowView: View {
    let row: Formation.Row
    let slotOffset: Int
    @ObservedObject var store: LineupStore
    @Binding var pickerSlot: SlotID?

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<row.count, id: \.self) { i in
                let slot = slotOffset + i
                let name = store.playerName(forSlot: slot)
                PlayerChip(name: name, isGoalkeeper: row.label == "TW")
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        if name != nil {
                            store.remove(fromSlot: slot)
                        } else {
                            pickerSlot = SlotID(id: slot)
                        }
                    }
            }
        }
    }
}
