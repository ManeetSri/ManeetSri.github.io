// Generated from src/dsa/content/lessons/math-basics/math-divisors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 36
var found: [Int] = []
for d in 1...n where n % d == 0 {
    found.append(d)
}
print(found)
