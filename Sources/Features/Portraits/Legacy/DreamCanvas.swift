import SwiftUI

struct DreamCanvas: View {
  var seed: Double
  var feeling: DreamFeeling
  var intensity: Double
  var motif: DreamMotif
  var time: Double = 0
  var heartRate: Double?

  var body: some View {
    Canvas { context, size in
      let dimension = min(size.width, size.height)
      let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
      let chaos = feeling.turbulence * (0.25 + intensity * 0.75)
      let pulse = 1 + sin(time * (heartRate ?? 48) / 60 * .pi * 2) * 0.008
      let radius = dimension * 0.36 * pulse
      let colors = feeling.artColors
      let shade = GraphicsContext.Shading.linearGradient(
        Gradient(colors: colors), startPoint: CGPoint(x: 0, y: size.height),
        endPoint: CGPoint(x: size.width, y: 0))

      for strand in 0..<96 {
        let fraction = Double(strand) / 96
        var path = Path()
        for step in 0...240 {
          let t = Double(step) / 240
          let angle = t * .pi * 2
          let twist = sin(angle * motif.frequency + seed * 0.02 + fraction * 7)
          let wave = cos(angle * 3 - fraction * 11 + seed * 0.1)
          let deformation = twist * wave * (0.07 + chaos * 0.38)
          let drift = time * 0.025
          var x: Double
          var y: Double
          switch motif {
          case .orbit:
            let r = radius * (0.18 + fraction * 0.85) * (1 + deformation)
            let spin = angle + fraction * chaos * 2.3 + drift
            x = cos(spin) * r
            y = sin(spin) * r * 1.10
          case .flow:
            let theta = angle + sin(fraction * .pi) * 1.7 + drift
            let r = radius * (0.15 + fraction * 0.95)
            x = cos(theta) * r + sin(angle * 2 + fraction * 6) * radius * chaos * 0.24
            y = sin(theta) * r * 0.78 + cos(angle * 3 + seed) * radius * 0.16
          case .fragment:
            let r = radius * (0.20 + fraction * 0.80) * (1 + deformation)
            let slice = floor(angle * 5) / 5
            x =
              cos(angle + fraction * 1.3 + drift) * r + sin(slice * 9 + seed) * radius * chaos
              * 0.20
            y =
              sin(angle + fraction * 1.3 + drift) * r + cos(slice * 13 + seed) * radius * chaos
              * 0.20
          }
          let point = CGPoint(x: center.x + x, y: center.y + y)
          if step == 0 || (motif == .fragment && step % 48 == 0) {
            path.move(to: point)
          } else {
            path.addLine(to: point)
          }
        }
        if motif != .fragment { path.closeSubpath() }
        context.opacity = 0.28 + fraction * 0.52
        context.stroke(
          path, with: shade,
          style: StrokeStyle(
            lineWidth: strand % 8 == 0 ? 2.1 : 1, lineCap: .round, lineJoin: .round))
      }
      context.opacity = 1
      for index in 0..<Int(900 + intensity * 1800) {
        let n = Double(index)
        let x = fractional(sin(n * 127.1 + seed) * 43758.5453) * size.width
        let y = fractional(sin(n * 311.7 + seed) * 43758.5453) * size.height
        let d = hypot(x - center.x, y - center.y) / dimension
        guard d < 0.49 else { continue }
        let dot = 0.45 + fractional(sin(n + seed) * 1653) * 1.25
        context.fill(
          Path(ellipseIn: CGRect(x: x, y: y, width: dot, height: dot)),
          with: .color(colors[index % colors.count].opacity((0.5 - d) * 0.65)))
      }
    }
    .accessibilityHidden(true)
  }

  private func fractional(_ value: Double) -> Double { value - floor(value) }
}
