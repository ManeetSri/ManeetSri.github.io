// Generated from src/dsa/content/lessons/number-theory/nt-primality.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func gcd(_ a: Int, _ b: Int) -> Int { b == 0 ? a : gcd(b, a % b) }

// Pollard's rho on n = 8051 with f(x) = x² + 1, tortoise moving one step, hare moving two
let n = 8051
func f(_ x: Int) -> Int { (x * x + 1) % n }
var tortoise = 2
var hare = 2
var step = 0
while true {
    tortoise = f(tortoise)
    hare = f(f(hare))
    step += 1
    let d = gcd(abs(tortoise - hare), n)
    print("step \(step): tortoise = \(tortoise), hare = \(hare), gcd = \(d)")
    if d != 1 { break }
}
print(8051 / 97, 83 * 97)
// the sequence modulo the hidden factor 97
var x = 2
var mod97: [Int] = []
for _ in 0..<10 { mod97.append(x % 97); x = f(x) }
print(mod97)
