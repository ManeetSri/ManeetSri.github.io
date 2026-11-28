// Generated from src/dsa/content/lessons/math-basics/math-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? a : gcd(b, a % b)
}

func fraction(_ top: Int, _ bottom: Int) -> String {
    let g = gcd(top, bottom)
    return "\(top / g)/\(bottom / g)"
}

let faces = Array(1...6)
print(fraction(faces.reduce(0, +), faces.count))
