// Generated from src/dsa/content/lessons/math-basics/math-modular-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var power = 1
for _ in 1...100 {
    power = power * 2 % 1000
}
print(power)
