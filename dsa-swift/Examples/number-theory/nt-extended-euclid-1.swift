// Generated from src/dsa/content/lessons/number-theory/nt-extended-euclid.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Recursive extended Euclid: returns (g, x, y) with a·x + b·y = g = gcd(a, b)
func extendedGCD(_ a: Int, _ b: Int) -> (g: Int, x: Int, y: Int) {
    if b == 0 {
        return (a, 1, 0)
    }
    let (g, x1, y1) = extendedGCD(b, a % b)
    return (g, y1, x1 - (a / b) * y1)
}

let (g, x, y) = extendedGCD(240, 46)
print(g, x, y)
print(240 * x + 46 * y)
print(extendedGCD(46, 240))
print(extendedGCD(17, 5))
