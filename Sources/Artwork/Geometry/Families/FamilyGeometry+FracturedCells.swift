import Foundation

extension FamilyGeometry {
  mutating func cells() {
    let count = 18 + Int(layer.density * 28)
    let sites = (0..<count).map { _ in (0.06 + random.unit() * 0.88, 0.06 + random.unit() * 0.88) }
    for index in sites.indices {
      let site = sites[index]
      var cell: [(Double, Double)] = [(0, 0), (1, 0), (1, 1), (0, 1)]
      for other in sites.indices where other != index {
        let q = sites[other]
        let nx = q.0 - site.0
        let ny = q.1 - site.1
        let limit = (q.0 * q.0 + q.1 * q.1 - site.0 * site.0 - site.1 * site.1) * 0.5
        var clipped: [(Double, Double)] = []
        guard !cell.isEmpty else { break }
        for i in cell.indices {
          let a = cell[i]
          let b = cell[(i + 1) % cell.count]
          let da = a.0 * nx + a.1 * ny - limit
          let db = b.0 * nx + b.1 * ny - limit
          if da <= 0 { clipped.append(a) }
          if (da <= 0) != (db <= 0) {
            let t = da / (da - db)
            clipped.append((a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t))
          }
        }
        cell = clipped
      }
      let shiftX = random.signed() * 0.009
      let shiftY = random.signed() * 0.009
      let polygonPoints = cell.map {
        (site.0 + ($0.0 - site.0) * 0.91 + shiftX, site.1 + ($0.1 - site.1) * 0.91 + shiftY)
      }
      polygon(polygonPoints, ink(index, opacity: 0.7 + random.unit() * 0.3))
      if index % 3 == 0 { line(polygonPoints, paper.opacity(0.65), width: 0.001, closed: true) }
    }
  }
}
