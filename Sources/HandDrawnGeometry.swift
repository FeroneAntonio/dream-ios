import Foundation

/// A branch is a gesture that opens into three (or more) etched ribbons, not
/// a diagrammatic stem with decorative twigs. Counts still come from the story.
struct HandDrawnGeometry {
    static func branching(recipe:DreamVisualRecipe,layer:VisualLayer) -> [RenderMark] {
        let noise = SeededNoise(seed:recipe.seed &+ layer.seedOffset)
        let converter = FamilyGeometry(recipe:recipe,layer:layer)
        let branches = min(5,max(2,layer.primitiveCount))
        let strands = 34+Int(layer.density*22)
        let color = recipe.palette.inks[0].opacity(layer.opacity)
        let join = (0.46+noise.value(0,0)*0.02,0.67)
        func bezier(_ a:(Double,Double),_ b:(Double,Double),_ c:(Double,Double),_ d:(Double,Double),_ t:Double) -> (Double,Double) {
            let u = 1-t
            return (u*u*u*a.0+3*u*u*t*b.0+3*u*t*t*c.0+t*t*t*d.0,u*u*u*a.1+3*u*u*t*b.1+3*u*t*t*c.1+t*t*t*d.1)
        }
        var marks:[RenderMark] = []
        for branch in 0..<branches {
            let f = Double(branch)/Double(branches-1), side = f*2-1
            let end = (0.10+f*0.79+(abs(side)<0.1 ? 0.08 : 0),0.10+f*0.17+noise.value(Double(branch),2)*0.025)
            let c1 = (join.0+side*0.34+(abs(side)<0.1 ? 0.18 : 0),join.1-0.12)
            let c2 = (end.0+side*0.22-(abs(side)<0.1 ? 0.23 : 0),end.1+0.25+f*0.06)
            for strand in 0..<strands {
                let across = Double(strand)/Double(strands-1)-0.5
                var points:[RenderPoint] = []
                for index in 0...170 {
                    let t = Double(index)/170
                    let p = bezier(join,c1,c2,end,t)
                    let q = bezier(join,c1,c2,end,min(1,t+0.004))
                    let dx = q.0-p.0, dy = q.1-p.1, length = max(0.00001,hypot(dx,dy))
                    let opening = pow(max(0,sin(t*Double.pi)),0.8)*(0.08+0.065*abs(side))
                    let drift = noise.value(t*3,Double(branch))*0.008*sin(t*Double.pi)
                    let offset = across*opening+drift
                    points.append(converter.point(p.0-dy/length*offset,p.1+dx/length*offset))
                }
                let edge = strand == 0 || strand == strands-1
                marks.append(RenderMark(kind:.line,points:points,color:color.opacity(edge ? 0.95 : 0.38+0.43*abs(across)*2),width:edge ? 0.0032 : 0.00075+0.0007*abs(across)))
            }
        }
        for strand in 0..<28 {
            let across = Double(strand)/27-0.5
            let points = (0...90).map { index -> RenderPoint in
                let t = Double(index)/90
                let p = bezier((0.53,0.95),(0.55,0.85),(join.0-0.08,0.82),join,t)
                return converter.point(p.0+across*0.023*(1-t),p.1)
            }
            marks.append(RenderMark(kind:.line,points:points,color:color.opacity(0.6),width:0.00085))
        }
        return marks
    }
}
