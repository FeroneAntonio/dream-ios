import SwiftUI

struct DreamcatcherMark: View {
  var body: some View {
    Canvas { context, size in
      let side = min(size.width, size.height * 0.65)
      var web = Path()
      for i in 0...100 {
        let a = Double(i) / 100 * .pi * 1.8 - .pi * 0.35
        let r = side * (0.42 + sin(a * 3) * 0.015)
        let point = CGPoint(x: side / 2 + cos(a) * r, y: side / 2 + sin(a) * r)
        if i == 0 { web.move(to: point) } else { web.addLine(to: point) }
      }
      web.addCurve(
        to: CGPoint(x: side * 0.60, y: size.height * 0.95),
        control1: CGPoint(x: side * 0.20, y: side * 1.25),
        control2: CGPoint(x: side * 0.85, y: side))
      context.stroke(web, with: .foreground, style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
      context.fill(
        Path(
          ellipseIn: CGRect(x: side * 0.60, y: side * 0.30, width: side * 0.10, height: side * 0.10)
        ), with: .foreground)
    }
  }
}
