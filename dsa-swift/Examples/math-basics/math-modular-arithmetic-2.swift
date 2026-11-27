// Generated from src/dsa/content/lessons/math-basics/math-modular-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let a = 17, b = 25, m = 12
print((a + b) % m, ((a % m) + (b % m)) % m)
print((a * b) % m, ((a % m) * (b % m)) % m)
