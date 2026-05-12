import SwiftUI

struct PitchLines: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            Canvas { ctx, _ in
                let stroke = GraphicsContext.Shading.color(.white.opacity(0.30))
                let lw: CGFloat = 1.5
                let inset: CGFloat = 10
                let fw = w - 2 * inset
                let fh = h - 2 * inset

                // Outer border
                var border = Path()
                border.addRoundedRect(in: CGRect(x: inset, y: inset, width: fw, height: fh),
                                      cornerSize: CGSize(width: 8, height: 8))
                ctx.stroke(border, with: stroke, lineWidth: lw)

                // Center line
                var cl = Path()
                cl.move(to: CGPoint(x: inset, y: h / 2))
                cl.addLine(to: CGPoint(x: w - inset, y: h / 2))
                ctx.stroke(cl, with: stroke, lineWidth: lw)

                // Center circle
                let ccR = fw * 0.135
                var circle = Path()
                circle.addEllipse(in: CGRect(x: w / 2 - ccR, y: h / 2 - ccR,
                                             width: ccR * 2, height: ccR * 2))
                ctx.stroke(circle, with: stroke, lineWidth: lw)

                // Center spot
                var centerSpot = Path()
                centerSpot.addEllipse(in: CGRect(x: w / 2 - 2.5, y: h / 2 - 2.5, width: 5, height: 5))
                ctx.fill(centerSpot, with: stroke)

                // Shared dimensions
                let pbW   = fw * 0.593   // penalty box width
                let pbH   = fh * 0.157   // penalty box depth
                let sixW  = fw * 0.269   // 6-yard box width
                let sixH  = fh * 0.052   // 6-yard box depth
                let arcR  = fw * 0.135   // penalty arc radius
                let spotD = fh * 0.105   // penalty spot distance from goal line

                // ── Top half ──────────────────────────────────────────────
                var topBox = Path()
                topBox.addRect(CGRect(x: (w - pbW) / 2, y: inset, width: pbW, height: pbH))
                ctx.stroke(topBox, with: stroke, lineWidth: lw)

                var topSix = Path()
                topSix.addRect(CGRect(x: (w - sixW) / 2, y: inset, width: sixW, height: sixH))
                ctx.stroke(topSix, with: stroke, lineWidth: lw)

                let topSpotY = inset + spotD
                var topSpot = Path()
                topSpot.addEllipse(in: CGRect(x: w / 2 - 2.5, y: topSpotY - 2.5, width: 5, height: 5))
                ctx.fill(topSpot, with: stroke)

                let topBoxBottom = inset + pbH
                let topDy = topBoxBottom - topSpotY
                if topDy < arcR {
                    let halfAngleDeg = acos(topDy / arcR) * 180 / .pi
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: w / 2, y: topSpotY),
                               radius: arcR,
                               startAngle: .degrees(90 - halfAngleDeg),
                               endAngle: .degrees(90 + halfAngleDeg),
                               clockwise: false)
                    ctx.stroke(arc, with: stroke, lineWidth: lw)
                }

                // ── Bottom half ───────────────────────────────────────────
                var botBox = Path()
                botBox.addRect(CGRect(x: (w - pbW) / 2, y: h - inset - pbH, width: pbW, height: pbH))
                ctx.stroke(botBox, with: stroke, lineWidth: lw)

                var botSix = Path()
                botSix.addRect(CGRect(x: (w - sixW) / 2, y: h - inset - sixH, width: sixW, height: sixH))
                ctx.stroke(botSix, with: stroke, lineWidth: lw)

                let botSpotY = h - inset - spotD
                var botSpot = Path()
                botSpot.addEllipse(in: CGRect(x: w / 2 - 2.5, y: botSpotY - 2.5, width: 5, height: 5))
                ctx.fill(botSpot, with: stroke)

                let botBoxTop = h - inset - pbH
                let botDy = botSpotY - botBoxTop
                if botDy < arcR {
                    let halfAngleDeg = acos(botDy / arcR) * 180 / .pi
                    var arc = Path()
                    arc.addArc(center: CGPoint(x: w / 2, y: botSpotY),
                               radius: arcR,
                               startAngle: .degrees(270 - halfAngleDeg),
                               endAngle: .degrees(270 + halfAngleDeg),
                               clockwise: false)
                    ctx.stroke(arc, with: stroke, lineWidth: lw)
                }
            }
        }
    }
}
