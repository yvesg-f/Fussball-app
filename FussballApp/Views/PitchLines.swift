import SwiftUI

struct PitchLines: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Canvas { ctx, _ in
                let stroke = GraphicsContext.Shading.color(.white.opacity(0.30))
                let lw: CGFloat = 1.5

                // Outer border (inset)
                var border = Path()
                border.addRoundedRect(in: CGRect(x: 10, y: 10, width: w - 20, height: h - 20),
                                      cornerSize: CGSize(width: 8, height: 8))
                ctx.stroke(border, with: stroke, lineWidth: lw)

                // Center line
                var cl = Path()
                cl.move(to: CGPoint(x: 10, y: h / 2))
                cl.addLine(to: CGPoint(x: w - 10, y: h / 2))
                ctx.stroke(cl, with: stroke, lineWidth: lw)

                // Center circle
                let r: CGFloat = 38
                var circle = Path()
                circle.addEllipse(in: CGRect(x: w / 2 - r, y: h / 2 - r, width: r * 2, height: r * 2))
                ctx.stroke(circle, with: stroke, lineWidth: lw)

                // Top penalty box
                let pbW = w * 0.50
                let pbH = h * 0.16
                var topBox = Path()
                topBox.addRect(CGRect(x: (w - pbW) / 2, y: 10, width: pbW, height: pbH))
                ctx.stroke(topBox, with: stroke, lineWidth: lw)

                // Bottom penalty box
                var botBox = Path()
                botBox.addRect(CGRect(x: (w - pbW) / 2, y: h - 10 - pbH, width: pbW, height: pbH))
                ctx.stroke(botBox, with: stroke, lineWidth: lw)
            }
        }
    }
}
