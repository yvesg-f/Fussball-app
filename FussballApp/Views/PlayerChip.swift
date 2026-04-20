import SwiftUI

struct PlayerChip: View {
    let name: String?
    var isGoalkeeper: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(chipColor)
                .shadow(color: .black.opacity(0.22), radius: 2, y: 1)

            if let name = name {
                Text(name)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.6)
                    .padding(4)
            } else {
                Image(systemName: "plus")
                    .foregroundStyle(Color.white.opacity(0.55))
                    .font(.system(size: 16, weight: .light))
            }
        }
        .frame(width: 68, height: 50)
    }

    private var chipColor: Color {
        if name == nil { return .white.opacity(0.18) }
        return isGoalkeeper ? .yellow : .white
    }
}
