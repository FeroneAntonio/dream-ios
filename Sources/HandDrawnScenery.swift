import Foundation

extension HandDrawnGeometry {
    static func rooms(recipe:DreamVisualRecipe,layer:VisualLayer) -> [RenderMark] {
        let converter = FamilyGeometry(recipe:recipe,layer:layer)
        let noise = SeededNoise(seed:recipe.seed &+ layer.seedOffset)
        let count = max(3,min(12,layer.primitiveCount))
        let ink = recipe.palette.inks[0].opacity(layer.opacity)
        var marks:[RenderMark] = []
        var previous:[RenderPoint]?
        for index in 0..<count {
            let t = Double(index)/Double(count)
            let radius = 0.46*pow(1-t,0.8)+0.045
            let cx = 0.46+sin(t*4.8)*0.10, cy = 0.5-t*0.13
            let slant = 0.07*cos(t*3)
            let corners:[(Double,Double)] = [(cx-radius*0.85,cy+radius),(cx-radius,cy-radius*0.91+slant),(cx+radius*0.88,cy-radius),(cx+radius,cy+radius*0.87)]
            var points:[RenderPoint] = []
            for edge in 0..<3 {
                let a = corners[edge], b = corners[edge+1]
                for step in 0...35 {
                    let p = Double(step)/35
                    let warp = noise.value(p*3,Double(index)*0.3)*0.008
                    points.append(converter.point(a.0+(b.0-a.0)*p+warp,a.1+(b.1-a.1)*p+warp*0.7))
                }
            }
            if let previous, index%2 == 1 {
                let wall = [previous[previous.count/3],previous.last!,points.last!,points[points.count/3]]
                marks.append(RenderMark(kind:.polygon,points:wall,color:ink.opacity(0.22+0.07*Double(index%3)),closed:true))
            }
            marks.append(RenderMark(kind:.line,points:points,color:ink,width:0.0037*(1-t*0.65)))
            previous = points
        }
        return marks
    }

    static func constellation(recipe:DreamVisualRecipe,layer:VisualLayer) -> [RenderMark] {
        let converter = FamilyGeometry(recipe:recipe,layer:layer)
        var random = SeededRandom(seed:recipe.seed &+ layer.seedOffset)
        let noise = SeededNoise(seed:recipe.seed &+ layer.seedOffset)
        let count = min(8,max(2,layer.primitiveCount))
        var centers:[(Double,Double)] = [(0.29+random.signed()*0.04,0.57),(0.73,0.35+random.signed()*0.06)]
        if count > 2 {
            centers = []
            for index in 0..<count {
                let angle = Double(index)*2.399
                let radius = 0.13+Double(index)*0.035
                centers.append((0.5+cos(angle)*radius,0.5+sin(angle)*radius))
            }
        }
        let ink = recipe.palette.inks[0].opacity(layer.opacity)
        var marks:[RenderMark] = []
        for index in 0..<count-1 {
            let a = centers[index], b = centers[index+1]
            for strand in 0..<38 {
                let f = Double(strand)/37
                let points = (0...100).map { step -> RenderPoint in
                    let t = Double(step)/100
                    let arch = sin(t*Double.pi)*(0.035+f*0.10)
                    return converter.point(a.0+(b.0-a.0)*t,a.1+(b.1-a.1)*t+arch)
                }
                marks.append(RenderMark(kind:.line,points:points,color:ink.opacity(0.28+f*0.3),width:strand%11 == 0 ? 0.002 : 0.00065))
            }
        }
        for (index,center) in centers.enumerated() {
            let size = index == 0 ? 0.15 : 0.11
            for contour in 0..<43 {
                let t = Double(contour)/43
                let radius = size*(0.20+pow(t,1.7)*0.8)
                let points = (0...130).map { step -> RenderPoint in
                    let a = Double(step)/130*Double.pi*2
                    let form = 1+0.13*sin(a*3+Double(index))+noise.value(cos(a)*2+Double(index),sin(a)*2)*0.09
                    let x = center.0+cos(a)*radius*form
                    let y = center.1+sin(a)*radius*form*1.17
                    return converter.point(x,y)
                }
                marks.append(RenderMark(kind:.line,points:points,color:ink.opacity(0.55+0.4*(1-t)),width:contour%9 == 0 ? 0.0026 : 0.0008,closed:true))
            }
        }
        return marks
    }

    static func echoes(recipe:DreamVisualRecipe,layer:VisualLayer) -> [RenderMark] {
        let converter = FamilyGeometry(recipe:recipe,layer:layer)
        let noise = SeededNoise(seed:recipe.seed &+ layer.seedOffset)
        let ink = recipe.palette.inks[0].opacity(layer.opacity)
        var marks:[RenderMark] = []
        let count = 35+Int(layer.density*25)
        for index in 0..<count {
            let t = Double(index)/Double(count-1)
            let radius = 0.025+pow(t,1.15)*0.66
            let cx = 0.43+sin(t*3.8)*0.095, cy = 0.34+t*0.18
            let points = (0...190).map { step -> RenderPoint in
                let a = Double(step)/190*Double.pi*2
                let c = cos(a), s = sin(a)
                let form = 1+0.08*sin(a*3+t*4)+noise.value(c*3+t,s*3)*0.035
                let x = (c >= 0 ? 1.0 : -1.0)*pow(abs(c),0.72)
                let y = (s >= 0 ? 1.0 : -1.0)*pow(abs(s),0.72)
                return converter.point(cx+x*radius*form,cy+y*radius*form)
            }
            marks.append(RenderMark(kind:.line,points:points,color:ink.opacity(0.75),width:index%9 == 0 ? 0.0033 : 0.0011,closed:true))
        }
        return marks
    }
}
