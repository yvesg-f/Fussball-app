import SwiftUI

struct HalfPitchLines: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Canvas { ctx, _ in
                let stroke = GraphicsContext.Shading.color(.white.opacity(0.35))
                let lw: CGFloat = 1.5
                let inset: CGFloat = 10
                let fw = w - 2 * inset
                let fh = h - 2 * inset

                // Outer border
                var border = Path()
                border.addRoundedRect(in: CGRect(x: inset, y: inset, width: fw, height: fh),
                                      cornerSize: CGSize(width: 8, height: 8))
                ctx.stroke(border, with: stroke, lineWidth: lw)

                // 6-yard box
                let sixW = fw * 0.269
                let sixH = fh * 0.105
                var sixBox = Path()
                sixBox.addRect(CGRect(x: (w - sixW) / 2, y: inset, width: sixW, height: sixH))
                ctx.stroke(sixBox, with: stroke, lineWidth: lw)

                // Penalty area
                let penW = fw * 0.593
                let penH = fh * 0.314
                var penBox = Path()
                penBox.addRect(CGRect(x: (w - penW) / 2, y: inset, width: penW, height: penH))
                ctx.stroke(penBox, with: stroke, lineWidth: lw)

                // Penalty spot
                let spotY = inset + fh * 0.210
                var spot = Path()
                spot.addEllipse(in: CGRect(x: w / 2 - 2.5, y: spotY - 2.5, width: 5, height: 5))
                ctx.fill(spot, with: stroke)

                // Penalty arc — only the part outside the penalty area
                let arcR = fw * 0.135
                let penBoxBottom = inset + penH
                let dy = penBoxBottom - spotY
                if dy < arcR {
                    let halfAngleDeg = acos(dy / arcR) * 180 / .pi
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: w / 2, y: spotY),
                               radius: arcR,
                               startAngle: .degrees(90 - halfAngleDeg),
                               endAngle: .degrees(90 + halfAngleDeg),
                               clockwise: false)
                    ctx.stroke(arc, with: stroke, lineWidth: lw)
                }

                // Halfway line
                var cl = Path()
                cl.move(to: CGPoint(x: inset, y: h - inset))
                cl.addLine(to: CGPoint(x: w - inset, y: h - inset))
                ctx.stroke(cl, with: stroke, lineWidth: lw)

                // Center circle arc — exactly a semicircle touching the halfway line
                let ccR = fw * 0.14
                var ccArc = Path()
                ccArc.addArc(center: CGPoint(x: w / 2, y: h - inset),
                             radius: ccR,
                             startAngle: .degrees(180),
                             endAngle: .degrees(360),
                             clockwise: false)
                ctx.stroke(ccArc, with: stroke, lineWidth: lw)
            }
        }
    }
}
