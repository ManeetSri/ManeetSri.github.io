// Generated from src/dsa/content/lessons/math-basics/math-digits.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 4721
var place = 1
while place <= n / 10 {
    place *= 10
}
while place > 0 {
    print(n / place % 10, terminator: " ")
    place /= 10
}
print()
