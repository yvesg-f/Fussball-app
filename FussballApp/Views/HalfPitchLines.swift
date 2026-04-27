import SwiftUI

struct HalfPitchLines: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Canvas { ctx, _ in
                let stroke = GraphicsContext.Shading.color(.white.opacity(0.35))
                let lw: CGFloat = 1.5

                // Outer border
                var border = Path()
                border.addRoundedRect(in: CGRect(x: 10, y: 10, width: w - 20, height: h - 20),
                                      cornerSize: CGSize(width: 8, height: 8))
                ctx.stroke(border, with: stroke, lineWidth: lw)

                // Goal (top center)
                let goalW = w * 0.22
                let goalH = h * 0.05
                var goal = Path()
                goal.addRect(CGRect(x: (w - goalW) / 2, y: 10 - goalH, width: goalW, height: goalH))
                ctx.stroke(goal, with: stroke, lineWidth: lw)

                // 6-yard box
                let sixW = w * 0.36
                let sixH = h * 0.10
                var sixBox = Path()
                sixBox.addRect(CGRect(x: (w - sixW) / 2, y: 10, width: sixW, height: sixH))
                ctx.stroke(sixBox, with: stroke, lineWidth: lw)

                // Penalty area
                let penW = w * 0.60
                let penH = h * 0.30
                var penBox = Path()
                penBox.addRect(CGRect(x: (w - penW) / 2, y: 10, width: penW, height: penH))
                ctx.stroke(penBox, with: stroke, lineWidth: lw)

                // Penalty spot
                let spotY = h * 0.22
                var spot = Path()
                spot.addEllipse(in: CGRect(x: w / 2 - 2.5, y: spotY - 2.5, width: 5, height: 5))
                ctx.fill(spot, with: stroke)

                // Penalty arc (outside penalty area)
                let arcR = w * 0.14
                let arcCY = spotY
                var arc = Path()
                arc.addArc(center: CGPoint(x: w / 2, y: arcCY),
                           radius: arcR,
                           startAngle: .degrees(35),
                           endAngle: .degrees(145),
                           clockwise: false)
                // Only draw the part below the penalty area
                ctx.stroke(arc, with: stroke, lineWidth: lw)

                // Center line (bottom = halfway line)
                var cl = Path()
                cl.move(to: CGPoint(x: 10, y: h - 10))
                cl.addLine(to: CGPoint(x: w - 10, y: h - 10))
                ctx.stroke(cl, with: stroke, lineWidth: lw)

                // Center circle arc at bottom edge
                let ccR: CGFloat = w * 0.18
                var ccArc = Path()
                ccArc.addArc(center: CGPoint(x: w / 2, y: h - 10),
                             radius: ccR,
                             startAngle: .degrees(200),
                             endAngle: .degrees(340),
                             clockwise: false)
                ctx.stroke(ccArc, with: stroke, lineWidth: lw)
            }
        }
    }
}
