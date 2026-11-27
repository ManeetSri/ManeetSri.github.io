// Generated from src/dsa/content/lessons/math-basics/math-divisors.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 1_000_000
var brute = 0
for _ in 1...n {
    brute += 1
}
var smart = 0
var i = 1
while i * i <= n {
    smart += 1
    i += 1
}
print(brute, smart)
