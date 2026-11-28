// Generated from src/dsa/content/lessons/math-basics/math-floor-ceil-overflow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func floorDiv(_ a: Int, _ b: Int) -> Int {
    var q = a / b
    if a % b != 0 && (a < 0) != (b < 0) {
        q -= 1
    }
    return q
}

func ceilDiv(_ a: Int, _ b: Int) -> Int {
    var q = a / b
    if a % b != 0 && (a < 0) == (b < 0) {
        q += 1
    }
    return q
}

for (a, b) in [(7, 2), (-7, 2), (7, -2), (-7, -2), (-6, 3)] {
    print(a, b, a / b, floorDiv(a, b), ceilDiv(a, b))
}
