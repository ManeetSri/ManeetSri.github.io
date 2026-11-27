// Generated from src/dsa/content/lessons/math-basics/math-probability.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? a : gcd(b, a % b)
}

func fraction(_ top: Int, _ bottom: Int) -> String {
    let g = gcd(top, bottom)
    return "\(top / g)/\(bottom / g)"
}

var sevens = 0
var total = 0
for first in 1...6 {
    for second in 1...6 {
        total += 1
        if first + second == 7 {
            sevens += 1
        }
    }
}
print(sevens, total, fraction(sevens, total))
