import Foundation

/// Renderer 2: authored pressure, dry nib repeats and clipped graphite hatching.
/// Renderer 1 remains available unchanged for every previously saved recipe.
struct HandDrawnRenderer {
    static func makePlan(recipe:DreamVisualRecipe) throws -> RenderPlan {
        let base = try ProceduralRenderEngine.makeBasePlan(recipe:recipe,pen:true)
        let noise = SeededNoise(seed:recipe.seed ^ 0x7E11)
        let graphite = recipe.palette.background.luminance > 0.5 ? VisualRGBA(0x29252C) : VisualRGBA(0xE7E1D3)
        var marks:[RenderMark] = []
        for (index,mark) in base.marks.enumerated() {
            switch mark.kind {
            case .line:
                guard mark.points.count >= 2 else { continue }
                // Pressure is coherent along a stroke, rather than random per point.
                let strideLength = mark.points.count > 30 ? 11 : mark.points.count-1
                for start in stride(from:0,to:mark.points.count-1,by:max(1,strideLength)) {
                    let end = min(mark.points.count-1,start+strideLength)
                    let t = Double(start)/Double(mark.points.count-1)
                    let pressure = 0.65+0.35*sin(t*Double.pi)+noise.value(t*5,Double(index%31))*0.32
                    var stroke = mark
                    stroke.points = Array(mark.points[start...end]).map { point in
                        let n = noise.value(point.x*95+Double(index%7),point.y*95)*0.00065
                        return RenderPoint(point.x+n,point.y+n*0.6)
                    }
                    stroke.width = max(0.00035,mark.width*pressure*(1+recipe.finish.inkBleed*0.3))
                    stroke.color = mark.color.opacity(0.78+0.2*max(0,noise.value(t*3,Double(index))))
                    stroke.closed = mark.closed && start == 0 && end == mark.points.count-1
                    marks.append(stroke)
                }
                // A faint second pass leaves the small misregistration of pencil.
                if index%4 == 0 && mark.points.count > 12 {
                    var ghost = mark
                    ghost.points = mark.points.map { point in
                        let n = noise.value(point.x*9,point.y*9)*0.0015
                        return RenderPoint(point.x+n,point.y-n*0.8)
                    }
                    ghost.width = 0.0006; ghost.color = graphite.opacity(mark.color.a*0.18)
                    marks.append(ghost)
                }
            case .polygon:
                let detailedSurface = [.fracturedCells,.spiralImprint,.layeredCollage,.thresholdRooms].contains(recipe.layers[0].family)
                var wash = mark
                if detailedSurface { wash.color = mark.color.opacity(0.12+0.35*abs(noise.value(Double(index)*0.23,0))) }
                marks.append(wash)
                if mark.color.a > 0.2 && mark.points.count >= 3 {
                    let strokeColor = graphite.opacity(0.3+mark.color.a*0.4)
                    marks.append(RenderMark(kind:.line,points:mark.points,color:strokeColor,width:0.0007,closed:true))
                    // Surface-specific shadow planes, not an all-over noise filter.
                    if detailedSurface || (index%3 == 0 && recipe.layers[0].family != .chromaticHaze) {
                        marks += hatching(polygon:mark.points,seed:recipe.seed &+ UInt64(index),color:graphite.opacity(detailedSurface ? 0.45 : 0.2),spacing:0.0045+0.002*(1-recipe.finish.grain))
                    }
                }
            case .ellipse:
                if mark.radiusX > 0.025 && mark.radiusY > 0.025 && mark.color != recipe.palette.background {
                    var wash = mark; wash.color = mark.color.opacity(0.1); marks.append(wash)
                    let polygon = (0..<96).map { step -> RenderPoint in
                        let angle = Double(step)/96*Double.pi*2
                        let variation = 1+noise.value(cos(angle)*4+Double(index),sin(angle)*4)*0.045
                        return RenderPoint(mark.points[0].x+cos(angle)*mark.radiusX*variation,mark.points[0].y+sin(angle)*mark.radiusY*variation)
                    }
                    marks += hatching(polygon:polygon,seed:recipe.seed &+ UInt64(index),color:graphite.opacity(0.7),spacing:0.0025)
                    marks.append(RenderMark(kind:.line,points:polygon,color:graphite.opacity(0.8),width:0.0013,closed:true))
                } else { marks.append(mark) }
            case .glow:
                marks.append(mark)
            }
        }
        let plan = RenderPlan(rendererVersion:2,background:base.background,marks:marks)
        guard plan.isFiniteAndBounded else { throw CocoaError(.coderInvalidValue) }
        return plan
    }

    static func hatching(polygon:[RenderPoint],seed:UInt64,color:VisualRGBA,spacing:Double) -> [RenderMark] {
        guard polygon.count >= 3 else { return [] }
        var random = SeededRandom(seed:seed)
        let angle = 0.55+random.unit()*0.5, c = cos(angle), s = sin(angle)
        let points = polygon.map { RenderPoint($0.x*c+$0.y*s,-$0.x*s+$0.y*c) }
        let minimum = points.map(\.y).min() ?? 0, maximum = points.map(\.y).max() ?? 0
        guard maximum > minimum else { return [] }
        let count = min(240,Int((maximum-minimum)/spacing)+1)
        var result:[RenderMark] = []
        for row in 0..<count {
            let v = minimum+Double(row)*spacing
            var intersections:[Double] = []
            for index in points.indices {
                let a = points[index], b = points[(index+1)%points.count]
                if (a.y > v) != (b.y > v) {
                    intersections.append(a.x+(b.x-a.x)*(v-a.y)/(b.y-a.y))
                }
            }
            intersections.sort()
            for index in stride(from:0,to:max(0,intersections.count-1),by:2) {
                let a = intersections[index], b = intersections[index+1]
                guard b-a > 0.002 else { continue }
                let overshoot = random.signed()*0.0007
                let p = RenderPoint(a*c-v*s-overshoot,a*s+v*c)
                let q = RenderPoint(b*c-v*s+overshoot,b*s+v*c)
                result.append(RenderMark(kind:.line,points:[p,q],color:color.opacity(0.55+random.unit()*0.45),width:0.00065+random.unit()*0.00055))
            }
        }
        return result
    }
}
